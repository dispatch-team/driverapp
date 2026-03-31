import 'package:driverapp/data/models/driver_profile.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // Reusable complete JSON fixture
  Map<String, dynamic> fullJson() => {
        'id': 1,
        'keycloak_id': 'kc-abc-123',
        'first_name': 'John',
        'middle_name': 'Paul',
        'last_name': 'Doe',
        'email': 'john.doe@example.com',
        'phone_number': '+1234567890',
        'courier_company_id': 42,
        'status': 'active',
        'profile_picture_id': 7,
        'additional_documents_id': 3,
        'rating_aggregate': 4.5,
        'rating_count': 20,
      };

  group('DriverProfile.fromJson', () {
    test('parses all required fields correctly', () {
      final profile = DriverProfile.fromJson(fullJson());

      expect(profile.id, 1);
      expect(profile.keycloakId, 'kc-abc-123');
      expect(profile.firstName, 'John');
      expect(profile.lastName, 'Doe');
      expect(profile.email, 'john.doe@example.com');
      expect(profile.phoneNumber, '+1234567890');
      expect(profile.courierCompanyId, 42);
      expect(profile.status, 'active');
      expect(profile.ratingAggregate, 4.5);
      expect(profile.ratingCount, 20);
    });

    test('parses optional middleName when present', () {
      final profile = DriverProfile.fromJson(fullJson());
      expect(profile.middleName, 'Paul');
    });

    test('parses middleName as null when absent', () {
      final json = fullJson()..remove('middle_name');
      final profile = DriverProfile.fromJson(json);
      expect(profile.middleName, isNull);
    });

    test('parses optional profilePictureId when present', () {
      final profile = DriverProfile.fromJson(fullJson());
      expect(profile.profilePictureId, 7);
    });

    test('parses profilePictureId as null when absent', () {
      final json = fullJson()..['profile_picture_id'] = null;
      final profile = DriverProfile.fromJson(json);
      expect(profile.profilePictureId, isNull);
    });

    test('parses optional additionalDocumentsId when present', () {
      final profile = DriverProfile.fromJson(fullJson());
      expect(profile.additionalDocumentsId, 3);
    });

    test('parses additionalDocumentsId as null when absent', () {
      final json = fullJson()..['additional_documents_id'] = null;
      final profile = DriverProfile.fromJson(json);
      expect(profile.additionalDocumentsId, isNull);
    });

    test('parses ratingAggregate from an integer JSON value', () {
      final json = fullJson()..['rating_aggregate'] = 5;
      final profile = DriverProfile.fromJson(json);
      expect(profile.ratingAggregate, 5.0);
      expect(profile.ratingAggregate, isA<double>());
    });

    test('parses ratingAggregate from a double JSON value', () {
      final json = fullJson()..['rating_aggregate'] = 3.75;
      final profile = DriverProfile.fromJson(json);
      expect(profile.ratingAggregate, 3.75);
    });
  });

  group('DriverProfile.fullName', () {
    test('returns first and last name when no middle name', () {
      final json = fullJson()..remove('middle_name');
      final profile = DriverProfile.fromJson(json);
      expect(profile.fullName, 'John Doe');
    });

    test('includes middle name when present', () {
      final profile = DriverProfile.fromJson(fullJson());
      expect(profile.fullName, 'John Paul Doe');
    });
  });

  group('DriverProfile.initials', () {
    test('returns uppercased first letter of first and last name', () {
      final profile = DriverProfile.fromJson(fullJson());
      expect(profile.initials, 'JD');
    });

    test('returns only last initial when firstName is empty', () {
      final json = fullJson()..['first_name'] = '';
      final profile = DriverProfile.fromJson(json);
      expect(profile.initials, 'D');
    });

    test('returns only first initial when lastName is empty', () {
      final json = fullJson()..['last_name'] = '';
      final profile = DriverProfile.fromJson(json);
      expect(profile.initials, 'J');
    });

    test('returns empty string when both names are empty', () {
      final json = fullJson()
        ..['first_name'] = ''
        ..['last_name'] = '';
      final profile = DriverProfile.fromJson(json);
      expect(profile.initials, '');
    });
  });
}
