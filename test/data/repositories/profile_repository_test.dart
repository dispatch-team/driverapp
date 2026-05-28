import 'package:dio/dio.dart';
import 'package:driverapp/data/models/driver_profile.dart';
import 'package:driverapp/data/repositories/profile_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/mocks.dart';

void main() {
  late MockProfileProvider mockProfileProvider;
  late ProfileRepository repo;

  setUpAll(() {
    registerFallbackValue(RequestOptions(path: ''));
  });

  setUp(() {
    mockProfileProvider = MockProfileProvider();
    repo = ProfileRepository(provider: mockProfileProvider);
  });

  Map<String, dynamic> profileJson() => {
        'id': 1,
        'keycloak_id': 'kc-abc-123',
        'first_name': 'Jane',
        'middle_name': null,
        'last_name': 'Smith',
        'email': 'jane@example.com',
        'phone_number': '+9876543210',
        'courier_company_id': 10,
        'status': 'active',
        'profile_picture_id': null,
        'additional_documents_id': null,
        'vehicle_type': 'motorcycle',
        'license_plate': 'AA-12345',
        'emergency_contact': '+0987654321',
        'rating_aggregate': 4.9,
        'rating_count': 50,
      };

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

  group('ProfileRepository.getProfile', () {
    test('returns a DriverProfile on success', () async {
      when(() => mockProfileProvider.getProfile())
          .thenAnswer((_) async => profileJson());

      final result = await repo.getProfile();

      expect(result, isA<DriverProfile>());
    });

    test('returns a DriverProfile with correct fields on success', () async {
      when(() => mockProfileProvider.getProfile())
          .thenAnswer((_) async => profileJson());

      final result = await repo.getProfile();

      expect(result.id, 1);
      expect(result.firstName, 'Jane');
      expect(result.lastName, 'Smith');
      expect(result.email, 'jane@example.com');
      expect(result.status, 'active');
      expect(result.vehicleType, 'motorcycle');
      expect(result.licensePlate, 'AA-12345');
      expect(result.emergencyContact, '+0987654321');
    });

    test('throws unauthorized ProfileException on 401 DioException', () async {
      when(() => mockProfileProvider.getProfile())
          .thenThrow(makeDioException(statusCode: 401));

      await expectLater(
        () => repo.getProfile(),
        throwsA(
          isA<ProfileException>().having((e) => e.isUnauthorized, 'isUnauthorized', isTrue),
        ),
      );
    });

    test('throws network ProfileException on non-401 DioException', () async {
      when(() => mockProfileProvider.getProfile())
          .thenThrow(makeDioException());

      await expectLater(
        () => repo.getProfile(),
        throwsA(
          isA<ProfileException>()
              .having((e) => e.isUnauthorized, 'isUnauthorized', isFalse)
              .having((e) => e.message, 'message', 'Connection error. Please try again.'),
        ),
      );
    });

    test('throws network ProfileException on 500 DioException', () async {
      when(() => mockProfileProvider.getProfile())
          .thenThrow(makeDioException(statusCode: 500));

      await expectLater(
        () => repo.getProfile(),
        throwsA(
          isA<ProfileException>()
              .having((e) => e.isUnauthorized, 'isUnauthorized', isFalse)
              .having((e) => e.message, 'message', 'Connection error. Please try again.'),
        ),
      );
    });

    test('throws unknown ProfileException on non-Dio exception', () async {
      when(() => mockProfileProvider.getProfile())
          .thenThrow(Exception('Something failed'));

      await expectLater(
        () => repo.getProfile(),
        throwsA(
          isA<ProfileException>()
              .having((e) => e.isUnauthorized, 'isUnauthorized', isFalse)
              .having((e) => e.message, 'message', 'An unexpected error occurred.'),
        ),
      );
    });
  });

  group('ProfileException factories', () {
    test('unauthorized has correct message and isUnauthorized flag', () {
      final e = ProfileException.unauthorized();
      expect(e.message, 'Session expired. Please log in again.');
      expect(e.isUnauthorized, isTrue);
    });

    test('network has correct message and isUnauthorized flag', () {
      final e = ProfileException.network();
      expect(e.message, 'Connection error. Please try again.');
      expect(e.isUnauthorized, isFalse);
    });

    test('unknown has correct message and isUnauthorized flag', () {
      final e = ProfileException.unknown();
      expect(e.message, 'An unexpected error occurred.');
      expect(e.isUnauthorized, isFalse);
    });
  });
}
