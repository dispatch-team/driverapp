import 'package:dio/dio.dart';

import '../../core/constants/api_constants.dart';
import '../../core/constants/app_constants.dart';
import '../../core/services/api_client.dart';

class AuthProvider {
  final ApiClient _client;

  AuthProvider(this._client);

  Future<Map<String, dynamic>> login(String username, String password) async {
    final response = await _client.post<Map<String, dynamic>>(
      '${AppConstants.apiPrefix}${ApiConstants.driversLogin}',
      data: {
        'username': username,
        'password': password,
      },
      options: Options(
        validateStatus: (status) => status != null && status < 500,
      ),
    );

    if (response.statusCode == 401) {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        type: DioExceptionType.badResponse,
      );
    }

    return response.data as Map<String, dynamic>;
  }
}
