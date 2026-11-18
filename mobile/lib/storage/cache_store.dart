import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

/// A cached JSON payload and when it was saved on this device.
class CacheEntry {
  const CacheEntry(this.json, this.savedAt);
  final Object? json;
  final DateTime savedAt;
}

/// Offline cache of API responses (cause lists, case details, favourites...).
/// Data is stored as JSON files in the app's private support directory.
abstract class CacheStore {
  Future<CacheEntry?> read(String key, {Duration? maxAge});
  Future<void> write(String key, Object? json);
  Future<void> clear();
  Future<int> sizeBytes();
}

class FileCacheStore implements CacheStore {
  FileCacheStore([this._root]);
  Directory? _root;

  Future<Directory> _dir() async {
    _root ??= Directory('${(await getApplicationSupportDirectory()).path}/api_cache');
    if (!await _root!.exists()) await _root!.create(recursive: true);
    return _root!;
  }

  String _name(String key) => base64Url.encode(utf8.encode(key)).replaceAll('=', '');

  @override
  Future<CacheEntry?> read(String key, {Duration? maxAge}) async {
    try {
      final f = File('${(await _dir()).path}/${_name(key)}.json');
      if (!await f.exists()) return null;
      final decoded = jsonDecode(await f.readAsString()) as Map<String, dynamic>;
      final saved = DateTime.parse(decoded['saved_at'] as String);
      if (maxAge != null && DateTime.now().difference(saved) > maxAge) {
        await f.delete();
        return null;
      }
      return CacheEntry(decoded['data'], saved);
    } catch (_) {
      return null; // a corrupt cache entry is treated as missing
    }
  }

  @override
  Future<void> write(String key, Object? json) async {
    final dir = await _dir();
    final f = File('${dir.path}/${_name(key)}.json');
    final tmp = File('${f.path}.tmp');
    await tmp.writeAsString(jsonEncode({'saved_at': DateTime.now().toIso8601String(), 'data': json}));
    await tmp.rename(f.path);
  }

  @override
  Future<void> clear() async {
    final dir = await _dir();
    if (await dir.exists()) await dir.delete(recursive: true);
    _root = null;
  }

  @override
  Future<int> sizeBytes() async {
    final dir = await _dir();
    var total = 0;
    await for (final e in dir.list()) {
      if (e is File) total += await e.length();
    }
    return total;
  }
}

class MemoryCacheStore implements CacheStore {
  final Map<String, CacheEntry> entries = {};

  @override
  Future<void> clear() async => entries.clear();

  @override
  Future<CacheEntry?> read(String key, {Duration? maxAge}) async {
    final e = entries[key];
    if (e == null) return null;
    if (maxAge != null && DateTime.now().difference(e.savedAt) > maxAge) return null;
    return e;
  }

  @override
  Future<int> sizeBytes() async => entries.values.fold<int>(0, (n, e) => n + jsonEncode(e.json).length);

  @override
  Future<void> write(String key, Object? json) async => entries[key] = CacheEntry(json, DateTime.now());
}
