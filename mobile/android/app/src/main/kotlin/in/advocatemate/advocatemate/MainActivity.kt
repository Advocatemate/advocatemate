package `in`.advocatemate.advocatemate

import android.app.NotificationChannel
import android.app.NotificationManager
import android.os.Build
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
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
}
