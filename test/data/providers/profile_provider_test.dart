import 'package:dio/dio.dart';
import 'package:driverapp/core/constants/api_constants.dart';
import 'package:driverapp/core/constants/app_constants.dart';
import 'package:driverapp/data/providers/profile_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/mocks.dart';

void main() {
  late MockApiClient mockApiClient;
  late ProfileProvider profileProvider;

  setUpAll(() {
    registerFallbackValue(RequestOptions(path: ''));
  });

  setUp(() {
    mockApiClient = MockApiClient();
    profileProvider = ProfileProvider(mockApiClient);
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

  Map<String, dynamic> profileJson() => {
        'id': 1,
        'keycloak_id': 'kc-abc-123',
        'first_name': 'John',
        'middle_name': null,
        'last_name': 'Doe',
        'email': 'john@example.com',
        'phone_number': '+1234567890',
        'courier_company_id': 42,
        'status': 'active',
        'profile_picture_id': null,
        'additional_documents_id': null,
        'rating_aggregate': 4.8,
        'rating_count': 10,
      };

  group('ProfileProvider.getProfile', () {
    const expectedPath = '${AppConstants.apiPrefix}${ApiConstants.driversProfile}';

    test('returns the response data map on success', () async {
      final data = profileJson();
      when(
        () => mockApiClient.get<Map<String, dynamic>>(any()),
      ).thenAnswer((_) async => makeResponse(statusCode: 200, data: data));

      final result = await profileProvider.getProfile();

      expect(result, data);
    });

    test('calls get with the correct endpoint path', () async {
      when(
        () => mockApiClient.get<Map<String, dynamic>>(any()),
      ).thenAnswer(
        (_) async => makeResponse(statusCode: 200, data: profileJson()),
      );

      await profileProvider.getProfile();

      verify(
        () => mockApiClient.get<Map<String, dynamic>>(expectedPath),
      ).called(1);
    });

    test('propagates DioException thrown by the API client', () async {
      final exception = DioException(
        requestOptions: RequestOptions(path: expectedPath),
        type: DioExceptionType.connectionTimeout,
      );
      when(
        () => mockApiClient.get<Map<String, dynamic>>(any()),
      ).thenThrow(exception);

      expect(
        () => profileProvider.getProfile(),
        throwsA(isA<DioException>()),
      );
    });

    test('propagates unexpected exceptions thrown by the API client', () async {
      when(
        () => mockApiClient.get<Map<String, dynamic>>(any()),
      ).thenThrow(Exception('Unexpected'));

      expect(
        () => profileProvider.getProfile(),
        throwsA(isA<Exception>()),
      );
    });
  });
}
