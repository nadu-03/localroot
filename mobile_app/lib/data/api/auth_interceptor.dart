import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthInterceptor extends Interceptor {
  final FlutterSecureStorage storage;
  final Future<bool> Function()? onRefresh;
  final String accessTokenKey;

  AuthInterceptor(this.storage, {this.onRefresh, this.accessTokenKey = 'accessToken'});

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    try {
      final token = await storage.read(key: accessTokenKey);
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    } catch (_) {}
    return handler.next(options);
  }

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401 && onRefresh != null) {
      // try refresh flow once
      try {
        final refreshed = await onRefresh!();
        if (refreshed) {
          final requestOptions = err.requestOptions;
          final opts = Options(method: requestOptions.method, headers: requestOptions.headers);
          try {
            final dio = Dio();
            // copy baseUrl and extra options
            final response = await dio.request(requestOptions.path,
                data: requestOptions.data,
                queryParameters: requestOptions.queryParameters,
                options: opts);
            return handler.resolve(response);
          } on DioException catch (e) {
            return handler.next(e);
          }
        }
      } catch (_) {
        // fall through
      }
    }
    return handler.next(err);
  }
}
