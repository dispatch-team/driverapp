import 'package:dio/dio.dart';
import 'package:driverapp/core/constants/api_constants.dart';
import 'package:driverapp/core/constants/app_constants.dart';
import 'package:driverapp/data/providers/auth_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/mocks.dart';

void main() {
  late MockApiClient mockApiClient;
  late AuthProvider authProvider;

  setUpAll(() {
    registerFallbackValue(Options());
    registerFallbackValue(RequestOptions(path: ''));
  });

  setUp(() {
    mockApiClient = MockApiClient();
    authProvider = AuthProvider(mockApiClient);
  });

  Response<Map<String, dynamic>> makeResponse({
    required int statusCode,
    required Map<String, dynamic> data,
  }) {
    return Response<Map<String, dynamic>>(
      data: data,
      statusCode: statusCode,
      requestOptions: RequestOptions(path: ''),
    );
  }

  group('AuthProvider.login', () {
    const expectedPath = '${AppConstants.apiPrefix}${ApiConstants.driversLogin}';

    test('returns response data on a 200 response', () async {
      final responseData = {'access_token': 'tok123'};
      when(
        () => mockApiClient.post<Map<String, dynamic>>(
          any(),
          data: any(named: 'data'),
          options: any(named: 'options'),
        ),
      ).thenAnswer((_) async => makeResponse(statusCode: 200, data: responseData));

      final result = await authProvider.login('driver1', 'secret');

      expect(result, responseData);
    });

    test('calls post with the correct endpoint path', () async {
      when(
        () => mockApiClient.post<Map<String, dynamic>>(
          any(),
          data: any(named: 'data'),
          options: any(named: 'options'),
        ),
      ).thenAnswer(
        (_) async => makeResponse(statusCode: 200, data: {'access_token': 'tok'}),
      );

      await authProvider.login('driver1', 'secret');

      verify(
        () => mockApiClient.post<Map<String, dynamic>>(
          expectedPath,
          data: any(named: 'data'),
          options: any(named: 'options'),
        ),
      ).called(1);
    });

    test('calls post with the correct username and password in the body', () async {
      when(
        () => mockApiClient.post<Map<String, dynamic>>(
          any(),
          data: any(named: 'data'),
          options: any(named: 'options'),
        ),
      ).thenAnswer(
        (_) async => makeResponse(statusCode: 200, data: {'access_token': 'tok'}),
      );

      await authProvider.login('driver1', 'secret');

      verify(
        () => mockApiClient.post<Map<String, dynamic>>(
          any(),
          data: {'username': 'driver1', 'password': 'secret'},
          options: any(named: 'options'),
        ),
      ).called(1);
    });

    test('throws DioException on a 401 response', () async {
      when(
        () => mockApiClient.post<Map<String, dynamic>>(
          any(),
          data: any(named: 'data'),
          options: any(named: 'options'),
        ),
      ).thenAnswer(
        (_) async => makeResponse(statusCode: 401, data: {}),
      );

      expect(
        () => authProvider.login('driver1', 'wrong'),
        throwsA(isA<DioException>()),
      );
    });

    test('thrown DioException has badResponse type on 401', () async {
      when(
        () => mockApiClient.post<Map<String, dynamic>>(
          any(),
          data: any(named: 'data'),
          options: any(named: 'options'),
        ),
      ).thenAnswer(
        (_) async => makeResponse(statusCode: 401, data: {}),
      );

      try {
        await authProvider.login('driver1', 'wrong');
        fail('Expected DioException to be thrown');
      } on DioException catch (e) {
        expect(e.type, DioExceptionType.badResponse);
        expect(e.response?.statusCode, 401);
      }
    });
  });
}
