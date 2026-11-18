/// A failure from the AdvocateMate backend, already mapped to something the UI can show.
class ApiException implements Exception {
  ApiException({required this.code, required this.message, this.statusCode, this.requestId});

  final String code;
  final String message;
  final int? statusCode;
  final String? requestId;

  bool get isNetwork => code == 'network_unavailable' || code == 'timeout';
  bool get isUnauthorized => statusCode == 401;
  bool get isNotFound => statusCode == 404;
  bool get isRateLimited => statusCode == 429;

  /// Errors where saved (offline) data should be shown instead.
  bool get allowsCachedFallback => isNetwork || (statusCode != null && statusCode! >= 500);

  static ApiException network() =>
      ApiException(code: 'network_unavailable', message: 'No internet connection. Please check your network.');

  static ApiException timeout() => ApiException(code: 'timeout', message: 'The server took too long to respond.');

  static ApiException unknown([String? message]) =>
      ApiException(code: 'unknown', message: message ?? 'Something went wrong. Please try again.');

  @override
  String toString() => 'ApiException($code, $statusCode): $message';
}
