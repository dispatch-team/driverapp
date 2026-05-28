import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:driverapp/core/constants/app_constants.dart';
import 'package:driverapp/core/services/api_client.dart';
import 'package:flutter_test/flutter_test.dart';

/// Lightweight Dio HTTP adapter that always returns a fixed 200 JSON response.
/// Used to exercise the ApiClient HTTP-method wrappers without a real server.
class _MockAdapter implements HttpClientAdapter {
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future? cancelFuture,
  ) async {
    return ResponseBody.fromString(
      '{}',
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  late ApiClient apiClient;

  setUp(() {
    apiClient = ApiClient();
  });

  // ─── Helpers ────────────────────────────────────────────────────────────────

  /// Returns a fresh ApiClient whose HTTP adapter is replaced with
  /// [_MockAdapter] so no real network call is made.
  ApiClient mockClient() {
    final client = ApiClient(baseUrl: 'https://test.example.com/');
    client.dio.httpClientAdapter = _MockAdapter();
    return client;
  }

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

  group('ApiClient HTTP method wrappers', () {
    // Each wrapper is a one-line pass-through to dio; we verify it resolves
    // to a successful Response rather than throwing, using _MockAdapter to
    // avoid any real network traffic.

    test('get returns a 200 response', () async {
      final response = await mockClient().get<dynamic>('/test');
      expect(response.statusCode, 200);
    });

    test('post returns a 200 response', () async {
      final response =
          await mockClient().post<dynamic>('/test', data: {'key': 'value'});
      expect(response.statusCode, 200);
    });

    test('put returns a 200 response', () async {
      final response =
          await mockClient().put<dynamic>('/test', data: {'key': 'value'});
      expect(response.statusCode, 200);
    });

    test('patch returns a 200 response', () async {
      final response =
          await mockClient().patch<dynamic>('/test', data: {'key': 'value'});
      expect(response.statusCode, 200);
    });

    test('delete returns a 200 response', () async {
      final response = await mockClient().delete<dynamic>('/test');
      expect(response.statusCode, 200);
    });
  });
}
