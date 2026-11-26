package `in`.advocatemate.advocatemate

import android.Manifest
import android.annotation.TargetApi
import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.ContentUris
import android.content.ContentValues
import android.content.pm.PackageManager
import android.media.MediaScannerConnection
import android.os.Build
import android.os.Bundle
import android.os.Environment
import android.os.Handler
import android.os.Looper
import android.provider.MediaStore
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.util.concurrent.Executors

class MainActivity : FlutterActivity() {
    private val io = Executors.newSingleThreadExecutor()
    private val main = Handler(Looper.getMainLooper())
    private var pendingSave: Pair<MethodCall, MethodChannel.Result>? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        createNotificationChannel()
    }

    // Channel id must match the backend's FCM AndroidNotification.channel_id.
    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                "advocatemate_updates",
                "Court updates",
                NotificationManager.IMPORTANCE_HIGH,
            ).apply { description = "Cause-list publication, saved case and case-detail updates" }
            getSystemService(NotificationManager::class.java)?.createNotificationChannel(channel)
        }
    }

    // ---------------------------------------------------------------- PDF downloads
    // "savePdf" copies an already downloaded PDF into Downloads/AdvocateMate so it is visible in the
    // Files / Downloads apps. Android 10+ uses MediaStore (no permission needed); Android 7-9 writes the
    // public Downloads folder and asks for WRITE_EXTERNAL_STORAGE (declared with maxSdkVersion 28).
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, DOWNLOADS_CHANNEL).setMethodCallHandler { call, result ->
            if (call.method != "savePdf") {
                result.notImplemented()
                return@setMethodCallHandler
            }
            if (Build.VERSION.SDK_INT < Build.VERSION_CODES.Q &&
                checkSelfPermission(Manifest.permission.WRITE_EXTERNAL_STORAGE) != PackageManager.PERMISSION_GRANTED
            ) {
                pendingSave?.second?.error("failed", "Superseded by a newer save request", null)
                pendingSave = call to result
                requestPermissions(arrayOf(Manifest.permission.WRITE_EXTERNAL_STORAGE), STORAGE_REQUEST)
            } else {
                savePdf(call, result)
            }
        }
    }

    override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<out String>, grantResults: IntArray) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode != STORAGE_REQUEST) return
        val (call, result) = pendingSave ?: return
        pendingSave = null
        if (grantResults.firstOrNull() == PackageManager.PERMISSION_GRANTED) {
            savePdf(call, result)
        } else {
            result.error("permission_denied", "Storage permission was denied", null)
        }
    }

    private fun savePdf(call: MethodCall, result: MethodChannel.Result) {
        val path = call.argument<String>("path")
        val name = call.argument<String>("name")
        if (path.isNullOrBlank() || name.isNullOrBlank()) {
            result.error("failed", "Missing path or name", null)
            return
        }
        io.execute {
            try {
                val bytes = File(path).readBytes()
                val status = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                    saveWithMediaStore(name, bytes)
                } else {
                    saveToPublicDownloads(name, bytes)
                }
                main.post { result.success(mapOf("status" to status, "location" to "Downloads › $FOLDER")) }
            } catch (e: Exception) {
                main.post { result.error("failed", e.message, null) }
            }
        }
    }

    @TargetApi(Build.VERSION_CODES.Q)
    private fun saveWithMediaStore(name: String, bytes: ByteArray): String {
        val resolver = contentResolver
        val collection = MediaStore.Downloads.EXTERNAL_CONTENT_URI
        val relativePath = "${Environment.DIRECTORY_DOWNLOADS}/$FOLDER/"
        // The same file saved earlier by this app (same name, identical bytes) is not saved again.
        resolver.query(
            collection,
            arrayOf(MediaStore.Downloads._ID, MediaStore.Downloads.SIZE),
            "${MediaStore.Downloads.DISPLAY_NAME}=? AND ${MediaStore.Downloads.RELATIVE_PATH}=?",
            arrayOf(name, relativePath),
            null,
        )?.use { c ->
            while (c.moveToNext()) {
                if (c.getLong(1) != bytes.size.toLong()) continue
                val uri = ContentUris.withAppendedId(collection, c.getLong(0))
                val existing = resolver.openInputStream(uri)?.use { it.readBytes() }
                if (existing != null && existing.contentEquals(bytes)) return "exists"
            }
        }
        val values = ContentValues().apply {
            put(MediaStore.Downloads.DISPLAY_NAME, name)
            put(MediaStore.Downloads.MIME_TYPE, "application/pdf")
            put(MediaStore.Downloads.RELATIVE_PATH, relativePath)
            put(MediaStore.Downloads.IS_PENDING, 1)
        }
        val uri = resolver.insert(collection, values) ?: throw IllegalStateException("Could not create the download")
        try {
            resolver.openOutputStream(uri)?.use { it.write(bytes) } ?: throw IllegalStateException("Could not write")
            values.clear()
            values.put(MediaStore.Downloads.IS_PENDING, 0)
            resolver.update(uri, values, null, null)
        } catch (e: Exception) {
            resolver.delete(uri, null, null)
            throw e
        }
        return "saved"
    }

    private fun saveToPublicDownloads(name: String, bytes: ByteArray): String {
        @Suppress("DEPRECATION")
        val dir = File(Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOWNLOADS), FOLDER)
        if (!dir.exists() && !dir.mkdirs()) throw IllegalStateException("Could not create $dir")
        val stem = name.removeSuffix(".pdf")
        var target = File(dir, name)
        var n = 2
        while (target.exists()) {
            if (target.length() == bytes.size.toLong() && target.readBytes().contentEquals(bytes)) return "exists"
            target = File(dir, "$stem ($n).pdf")
            n++
        }
        target.writeBytes(bytes)
        MediaScannerConnection.scanFile(this, arrayOf(target.absolutePath), arrayOf("application/pdf"), null)
        return "saved"
    }

    private companion object {
        const val DOWNLOADS_CHANNEL = "in.advocatemate.app/downloads"
        const val STORAGE_REQUEST = 7301
        const val FOLDER = "AdvocateMate"
    }
}
