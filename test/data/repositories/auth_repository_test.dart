import 'package:dio/dio.dart';
import 'package:driverapp/core/constants/app_constants.dart';
import 'package:driverapp/data/repositories/auth_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/mocks.dart';

void main() {
  late MockAuthProvider mockAuthProvider;
  late MockApiClient mockApiClient;
  late MockFlutterSecureStorage mockSecureStorage;
  late AuthRepository repo;

  setUpAll(() {
    registerFallbackValue(RequestOptions(path: ''));
  });

  setUp(() {
    mockAuthProvider = MockAuthProvider();
    mockApiClient = MockApiClient();
    mockSecureStorage = MockFlutterSecureStorage();

    repo = AuthRepository(
      provider: mockAuthProvider,
      apiClient: mockApiClient,
      secureStorage: mockSecureStorage,
    );

    // Stub void/Future<void> methods with safe defaults
    when(
      () => mockApiClient.setAuthToken(any()),
    ).thenReturn(null);

    when(
      () => mockApiClient.clearAuthToken(),
    ).thenReturn(null);

    when(
      () => mockSecureStorage.write(
        key: any(named: 'key'),
        value: any(named: 'value'),
      ),
    ).thenAnswer((_) async {});

    when(
      () => mockSecureStorage.delete(key: any(named: 'key')),
    ).thenAnswer((_) async {});
  });

  DioException makeDioException({int? statusCode}) {
    final response = statusCode != null
        ? Response<dynamic>(
            statusCode: statusCode,
            requestOptions: RequestOptions(path: ''),
          )
        : null;
    return DioException(
      requestOptions: RequestOptions(path: ''),
      response: response,
      type: statusCode != null
          ? DioExceptionType.badResponse
          : DioExceptionType.connectionTimeout,
    );
  }

  group('AuthRepository.login', () {
    test('returns null and stores token on success', () async {
      when(
        () => mockAuthProvider.login(any(), any()),
      ).thenAnswer((_) async => {'access_token': 'tok123'});

      final result = await repo.login('driver1', 'secret');

      expect(result, isNull);
    });

    test('writes token to secure storage on success', () async {
      when(
        () => mockAuthProvider.login(any(), any()),
      ).thenAnswer((_) async => {'access_token': 'tok123'});

      await repo.login('driver1', 'secret');

      verify(
        () => mockSecureStorage.write(
          key: AppConstants.tokenKey,
          value: 'tok123',
        ),
      ).called(1);
    });

    test('sets auth token on ApiClient on success', () async {
      when(
        () => mockAuthProvider.login(any(), any()),
      ).thenAnswer((_) async => {'access_token': 'tok123'});

      await repo.login('driver1', 'secret');

      verify(() => mockApiClient.setAuthToken('tok123')).called(1);
    });

    test('returns error message when token is empty string', () async {
      when(
        () => mockAuthProvider.login(any(), any()),
      ).thenAnswer((_) async => {'access_token': ''});

      final result = await repo.login('driver1', 'secret');

      expect(result, 'Unexpected response from server.');
    });

    test('returns error message when access_token key is missing', () async {
      when(
        () => mockAuthProvider.login(any(), any()),
      ).thenAnswer((_) async => {});

      final result = await repo.login('driver1', 'secret');

      expect(result, 'Unexpected response from server.');
    });

    test('returns error message when access_token is explicitly null', () async {
      when(
        () => mockAuthProvider.login(any(), any()),
      ).thenAnswer((_) async => {'access_token': null});

      final result = await repo.login('driver1', 'secret');

      expect(result, 'Unexpected response from server.');
    });

    test('forwards credentials to the provider', () async {
      when(
        () => mockAuthProvider.login(any(), any()),
      ).thenAnswer((_) async => {'access_token': 'tok'});

      await repo.login('myuser', 'mypass');

      verify(() => mockAuthProvider.login('myuser', 'mypass')).called(1);
    });

    test('returns invalid credentials message on 401 DioException', () async {
      when(
        () => mockAuthProvider.login(any(), any()),
      ).thenThrow(makeDioException(statusCode: 401));

      final result = await repo.login('driver1', 'wrong');

      expect(result, 'Invalid credentials.');
    });

    test('returns connection error message on non-401 DioException', () async {
      when(
        () => mockAuthProvider.login(any(), any()),
      ).thenThrow(makeDioException());

      final result = await repo.login('driver1', 'secret');

      expect(result, 'Connection error. Please try again.');
    });

    test('returns connection error message on 500 DioException', () async {
      when(
        () => mockAuthProvider.login(any(), any()),
      ).thenThrow(makeDioException(statusCode: 500));

      final result = await repo.login('driver1', 'secret');

      expect(result, 'Connection error. Please try again.');
    });

    test('returns unexpected error message on non-Dio exception', () async {
      when(
        () => mockAuthProvider.login(any(), any()),
      ).thenThrow(Exception('Something went wrong'));

      final result = await repo.login('driver1', 'secret');

      expect(result, 'An unexpected error occurred.');
    });

    test('does not store token or set auth header when login fails', () async {
      when(
        () => mockAuthProvider.login(any(), any()),
      ).thenThrow(makeDioException(statusCode: 401));

      await repo.login('driver1', 'wrong');

      verifyNever(
        () => mockSecureStorage.write(
          key: any(named: 'key'),
          value: any(named: 'value'),
        ),
      );
      verifyNever(() => mockApiClient.setAuthToken(any()));
    });
  });

  group('AuthRepository.getStoredToken', () {
    test('returns token when one is stored', () async {
      when(
        () => mockSecureStorage.read(key: AppConstants.tokenKey),
      ).thenAnswer((_) async => 'stored-token');

      final result = await repo.getStoredToken();

      expect(result, 'stored-token');
    });

    test('returns null when no token is stored', () async {
      when(
        () => mockSecureStorage.read(key: AppConstants.tokenKey),
      ).thenAnswer((_) async => null);

      final result = await repo.getStoredToken();

      expect(result, isNull);
    });

    test('delegates to secure storage with the correct key', () async {
      when(
        () => mockSecureStorage.read(key: any(named: 'key')),
      ).thenAnswer((_) async => null);

      await repo.getStoredToken();

      verify(
        () => mockSecureStorage.read(key: AppConstants.tokenKey),
      ).called(1);
    });
  });

  group('AuthRepository.logout', () {
    test('deletes token from secure storage', () async {
      await repo.logout();

      verify(
        () => mockSecureStorage.delete(key: AppConstants.tokenKey),
      ).called(1);
    });

    test('clears auth token from ApiClient', () async {
      await repo.logout();

      verify(() => mockApiClient.clearAuthToken()).called(1);
    });
  });
}
