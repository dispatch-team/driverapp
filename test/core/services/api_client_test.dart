import 'package:driverapp/core/constants/app_constants.dart';
import 'package:driverapp/core/services/api_client.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late ApiClient apiClient;

  setUp(() {
    apiClient = ApiClient();
  });

  group('ApiClient constructor defaults', () {
    test('sets the correct base URL', () {
      expect(apiClient.dio.options.baseUrl, AppConstants.baseUrl);
    });

    test('sets the correct connect timeout', () {
      expect(apiClient.dio.options.connectTimeout, AppConstants.connectionTimeout);
    });

    test('sets the correct receive timeout', () {
      expect(apiClient.dio.options.receiveTimeout, AppConstants.receiveTimeout);
    });

    test('sets Content-Type to application/json', () {
      expect(
        apiClient.dio.options.headers['Content-Type'],
        'application/json',
      );
    });

    test('sets Accept to application/json', () {
      expect(
        apiClient.dio.options.headers['Accept'],
        'application/json',
      );
    });

    test('accepts a custom base URL', () {
      final client = ApiClient(baseUrl: 'https://custom.example.com/');
      expect(client.dio.options.baseUrl, 'https://custom.example.com/');
    });
  });

  group('ApiClient.setAuthToken', () {
    test('adds Bearer token to Authorization header', () {
      apiClient.setAuthToken('my-secret-token');
      expect(
        apiClient.dio.options.headers['Authorization'],
        'Bearer my-secret-token',
      );
    });

    test('overwrites a previously set token', () {
      apiClient.setAuthToken('first-token');
      apiClient.setAuthToken('second-token');
      expect(
        apiClient.dio.options.headers['Authorization'],
        'Bearer second-token',
      );
    });
  });

  group('ApiClient.clearAuthToken', () {
    test('removes the Authorization header', () {
      apiClient.setAuthToken('my-secret-token');
      apiClient.clearAuthToken();
      expect(apiClient.dio.options.headers.containsKey('Authorization'), isFalse);
    });

    test('does not throw when header was never set', () {
      expect(() => apiClient.clearAuthToken(), returnsNormally);
    });
  });
}
