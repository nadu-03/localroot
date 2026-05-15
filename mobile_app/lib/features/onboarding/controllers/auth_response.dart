import '../../../common/models/user_model.dart';
import '../../../data/api/api_exceptions.dart';

class AuthResponse {
  const AuthResponse({required this.token, this.user});

  final String token;
  final UserModel? user;
}

AuthResponse parseAuthResponse(dynamic responseBody) {
  if (responseBody is! Map) {
    throw ApiException('Incorrect response format from server');
  }

  final payload = responseBody['data'] is Map
      ? responseBody['data'] as Map
      : responseBody;

  final token = payload['token']?.toString();
  if (token == null || token.isEmpty) {
    throw ApiException(
      responseBody['message']?.toString() ??
          'Incorrect response format: missing auth token',
    );
  }

  UserModel? user;
  final userJson = payload['user'];
  if (userJson is Map) {
    user = UserModel.fromJson(Map<String, dynamic>.from(userJson));
  }

  return AuthResponse(token: token, user: user);
}

String authErrorMessage(Object error) {
  if (error is ApiException) return error.message;
  return 'Could not connect to the server. Please check your internet connection and try again.';
}
