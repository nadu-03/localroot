import 'package:dio/dio.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, {this.statusCode});

  @override
  String toString() => 'ApiException(status: $statusCode, message: $message)';

  factory ApiException.fromDioError(DioException error) {
    final response = error.response;
    if (response != null) {
      final status = response.statusCode;
      final data = response.data;
      String msg;
      if (data is Map && data['message'] != null) {
        msg = data['message'].toString();
      } else if (response.statusMessage != null) {
        msg = response.statusMessage!;
      } else {
        msg = error.message ?? 'Unknown API error';
      }
      return ApiException(msg, statusCode: status);
    }

    return ApiException(error.message ?? 'Network error');
  }
}
