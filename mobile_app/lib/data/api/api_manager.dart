import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'auth_interceptor.dart';
import 'api_exceptions.dart';

class ApiManager {
  ApiManager._internal();
  static final ApiManager instance = ApiManager._internal();

  late final Dio dio;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  void init({required String baseUrl, bool enableLogs = false, Future<bool> Function()? onRefresh}) {
    final options = BaseOptions(baseUrl: baseUrl, connectTimeout: const Duration(seconds: 15), receiveTimeout: const Duration(seconds: 15));
    dio = Dio(options);

    dio.interceptors.add(AuthInterceptor(_secureStorage, onRefresh: onRefresh));
    if (enableLogs) dio.interceptors.add(LogInterceptor(requestBody: true, responseBody: true));
    dio.interceptors.add(InterceptorsWrapper(onError: (e, handler) {
      handler.next(e);
    }));
  }

  Future<Response<T>> get<T>(String path, {Map<String, dynamic>? queryParameters, Options? options}) async {
    try {
      return await dio.get<T>(path, queryParameters: queryParameters, options: options);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<Response<T>> post<T>(String path, {dynamic data, Map<String, dynamic>? queryParameters, Options? options}) async {
    try {
      return await dio.post<T>(path, data: data, queryParameters: queryParameters, options: options);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<Response<T>> put<T>(String path, {dynamic data, Map<String, dynamic>? queryParameters, Options? options}) async {
    try {
      return await dio.put<T>(path, data: data, queryParameters: queryParameters, options: options);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<Response<T>> delete<T>(String path, {dynamic data, Map<String, dynamic>? queryParameters, Options? options}) async {
    try {
      return await dio.delete<T>(path, data: data, queryParameters: queryParameters, options: options);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<Response<T>> uploadFile<T>(String path, String fileKey, List<int> bytes, String filename, {Map<String, dynamic>? extraFields}) async {
    final form = FormData.fromMap({
      if (extraFields != null) ...extraFields,
      fileKey: MultipartFile.fromBytes(bytes, filename: filename),
    });
    try {
      return await dio.post<T>(path, data: form, options: Options(contentType: 'multipart/form-data'));
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }
}
