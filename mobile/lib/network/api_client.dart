import 'dart:async';

import 'package:dio/dio.dart';

import '../config/env.dart';
import '../core/errors.dart';
import '../storage/token_store.dart';

typedef SessionExpiredCallback = void Function();

/// Thin wrapper over Dio:
/// * attaches the access token,
/// * on 401 performs ONE serialized refresh (rotation) and retries the request,
/// * maps every failure to [ApiException].
class ApiClient {
  ApiClient({required this.tokens, Dio? dio, String? baseUrl, this.onSessionExpired})
      : dio = dio ??
            Dio(BaseOptions(
              baseUrl: baseUrl ?? Env.apiPrefix,
              connectTimeout: const Duration(seconds: 15),
              receiveTimeout: const Duration(seconds: 45),
              headers: {'Accept': 'application/json'},
            )) {
    this.dio.interceptors.add(InterceptorsWrapper(onRequest: _attachToken, onError: _onError));
  }

  final Dio dio;
  final TokenStore tokens;
  SessionExpiredCallback? onSessionExpired;
  Completer<bool>? _refreshing;

  static const _noAuthPaths = ['/auth/register', '/auth/send-otp', '/auth/verify-otp', '/auth/refresh'];

  Future<void> _attachToken(RequestOptions options, RequestInterceptorHandler handler) async {
    if (!_noAuthPaths.contains(options.path)) {
      final t = await tokens.read();
      if (t != null) options.headers['Authorization'] = 'Bearer ${t.accessToken}';
    }
    handler.next(options);
  }

  Future<void> _onError(DioException err, ErrorInterceptorHandler handler) async {
    final req = err.requestOptions;
    final is401 = err.response?.statusCode == 401;
    if (!is401 || _noAuthPaths.contains(req.path) || req.extra['retried'] == true) {
      return handler.next(err);
    }
    final ok = await _refresh();
    if (!ok) {
      onSessionExpired?.call();
      return handler.next(err);
    }
    try {
      final t = await tokens.read();
      req.headers['Authorization'] = 'Bearer ${t?.accessToken}';
      req.extra['retried'] = true;
      handler.resolve(await dio.fetch(req));
    } on DioException catch (e) {
      handler.next(e);
    }
  }

  Future<bool> _refresh() async {
    if (_refreshing != null) return _refreshing!.future;
    final c = _refreshing = Completer<bool>();
    try {
      final current = await tokens.read();
      if (current == null) {
        c.complete(false);
      } else {
        final r = await dio.post('/auth/refresh', data: {'refresh_token': current.refreshToken});
        final data = r.data as Map<String, dynamic>;
        await tokens.write(StoredTokens(
            accessToken: data['access_token'] as String, refreshToken: data['refresh_token'] as String));
        c.complete(true);
      }
    } catch (_) {
      await tokens.clear();
      c.complete(false);
    } finally {
      _refreshing = null;
    }
    return c.future;
  }

  // ------------------------------------------------------------------ verbs
  Future<dynamic> get(String path, {Map<String, dynamic>? query}) =>
      _guard(() => dio.get(path, queryParameters: _clean(query)));

  Future<dynamic> post(String path, {Object? data, Map<String, dynamic>? query}) =>
      _guard(() => dio.post(path, data: data, queryParameters: _clean(query)));

  Future<dynamic> put(String path, {Object? data}) => _guard(() => dio.put(path, data: data));

  Future<dynamic> patch(String path, {Object? data}) => _guard(() => dio.patch(path, data: data));

  Future<dynamic> delete(String path) => _guard(() => dio.delete(path));

  /// Streams a file (PDF) to [savePath], reporting progress 0..1.
  Future<Headers> download(String path, String savePath,
      {Map<String, dynamic>? query, void Function(double progress)? onProgress, CancelToken? cancel}) async {
    final r = await _guardRaw(() => dio.download(path, savePath,
        queryParameters: _clean(query),
        cancelToken: cancel,
        onReceiveProgress: (rec, total) => onProgress?.call(total > 0 ? rec / total : 0)));
    return r.headers;
  }

  Map<String, dynamic>? _clean(Map<String, dynamic>? q) =>
      q == null ? null : (Map.of(q)..removeWhere((_, v) => v == null || (v is String && v.isEmpty)));

  Future<dynamic> _guard(Future<Response<dynamic>> Function() call) async => (await _guardRaw(call)).data;

  Future<Response<dynamic>> _guardRaw(Future<Response<dynamic>> Function() call) async {
    try {
      return await call();
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }
}

ApiException mapDioError(DioException e) {
  switch (e.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.receiveTimeout:
    case DioExceptionType.sendTimeout:
      return ApiException.timeout();
    case DioExceptionType.connectionError:
      return ApiException.network();
    default:
      break;
  }
  final res = e.response;
  if (res == null) return ApiException.network();
  final body = res.data;
  if (body is Map && body['error'] is Map) {
    final err = body['error'] as Map;
    return ApiException(
      code: (err['code'] ?? 'error').toString(),
      message: (err['message'] ?? 'Request failed').toString(),
      statusCode: res.statusCode,
      requestId: err['request_id']?.toString(),
    );
  }
  return ApiException(code: 'http_${res.statusCode}', message: 'Request failed (${res.statusCode})', statusCode: res.statusCode);
}
