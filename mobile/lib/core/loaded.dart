/// Data plus its provenance, so every screen can show freshness honestly.
class Loaded<T> {
  const Loaded(this.data, {this.fromCache = false, this.savedAt, this.serverStale = false, this.fetchedAt});

  final T data;

  /// True when the network failed and this is the copy saved on the device.
  final bool fromCache;

  /// When the device saved the cached copy (only for [fromCache]).
  final DateTime? savedAt;

  /// Backend reported that it could not refresh from APHC and served its last copy.
  final bool serverStale;

  /// When the backend last fetched this from APHC.
  final DateTime? fetchedAt;

  bool get isCurrent => !fromCache && !serverStale;
}
