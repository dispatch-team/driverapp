import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../core/constants/app_constants.dart';
import '../../core/services/api_client.dart';
import '../providers/auth_provider.dart';

class AuthRepository {
  final AuthProvider _provider;
  final ApiClient _apiClient;
  final FlutterSecureStorage _secureStorage;

  AuthRepository({
    required AuthProvider provider,
    required ApiClient apiClient,
    FlutterSecureStorage? secureStorage,
  })  : _provider = provider,
        _apiClient = apiClient,
        _secureStorage = secureStorage ?? const FlutterSecureStorage();

  /// Returns null on success or an error message string on failure.
  Future<String?> login(String username, String password) async {
    try {
      final data = await _provider.login(username, password);
      final token = data['access_token'] as String?;

      if (token == null || token.isEmpty) {
        return 'Unexpected response from server.';
      }

      await _secureStorage.write(key: AppConstants.tokenKey, value: token);
      _apiClient.setAuthToken(token);

      return null;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        return 'Invalid credentials.';
      }
      return 'Connection error. Please try again.';
    } catch (_) {
      return 'An unexpected error occurred.';
    }
  }

  Future<String?> getStoredToken() {
    return _secureStorage.read(key: AppConstants.tokenKey);
  }

  Future<void> logout() async {
    await _secureStorage.delete(key: AppConstants.tokenKey);
    _apiClient.clearAuthToken();
  }
}
