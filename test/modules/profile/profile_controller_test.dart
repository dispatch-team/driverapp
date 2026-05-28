import 'package:driverapp/data/models/driver_profile.dart';
import 'package:driverapp/data/repositories/auth_repository.dart';
import 'package:driverapp/data/repositories/profile_repository.dart';
import 'package:driverapp/modules/profile/profile_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/mocks.dart';

void main() {
  late MockProfileRepository mockProfileRepository;
  late MockAuthRepository mockAuthRepository;

  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  // Helper to build a minimal DriverProfile for stub returns
  DriverProfile makeProfile() => const DriverProfile(
        id: 1,
        keycloakId: 'kc-abc',
        firstName: 'Jane',
        lastName: 'Smith',
        email: 'jane@example.com',
        phoneNumber: '+1234567890',
        courierCompanyId: 10,
        status: 'active',
        ratingAggregate: 4.9,
        ratingCount: 50,
        vehicleType: 'Sedan',
        licensePlate: 'ABC123',
        emergencyContact: 'John Doe'
      );

  /// Creates and initialises the controller, then waits for any pending
  /// microtasks (i.e. the async [fetchProfile] kicked off by [onInit]).
  Future<ProfileController> buildController() async {
    final controller = ProfileController();
    controller.onInit();
    // Allow the unawaited fetchProfile() call inside onInit to complete.
    await Future<void>.delayed(Duration.zero);
    return controller;
  }

  setUp(() {
    Get.testMode = true;
    mockProfileRepository = MockProfileRepository();
    mockAuthRepository = MockAuthRepository();

    // Register mocks so Get.find<ProfileRepository/AuthRepository> resolves them.
    Get.put<ProfileRepository>(mockProfileRepository);
    Get.put<AuthRepository>(mockAuthRepository);

    // Safe default stub for logout (called during unauthorized flow).
    when(() => mockAuthRepository.logout()).thenAnswer((_) async {});
  });

  tearDown(() {
    Get.reset();
  });

  group('ProfileController.fetchProfile on success', () {
    setUp(() {
      when(() => mockProfileRepository.getProfile())
          .thenAnswer((_) async => makeProfile());
    });

    test('profile.value is populated with the returned driver profile', () async {
      final controller = await buildController();

      expect(controller.profile.value, isNotNull);
      expect(controller.profile.value?.firstName, 'Jane');
    });

    test('isLoading is false after successful fetch', () async {
      final controller = await buildController();

      expect(controller.isLoading.value, isFalse);
    });

    test('errorMessage is empty after successful fetch', () async {
      final controller = await buildController();

      expect(controller.errorMessage.value, '');
    });
  });

  group('ProfileController.fetchProfile on unauthorized error', () {
    setUp(() {
      when(() => mockProfileRepository.getProfile())
          .thenThrow(ProfileException.unauthorized());
    });

    test('calls authRepository.logout on 401', () async {
      await buildController();

      verify(() => mockAuthRepository.logout()).called(1);
    });

    test('isLoading is false after unauthorized error', () async {
      final controller = await buildController();

      expect(controller.isLoading.value, isFalse);
    });
  });

  group('ProfileController.fetchProfile on non-unauthorized error', () {
    setUp(() {
      when(() => mockProfileRepository.getProfile())
          .thenThrow(ProfileException.network());
    });

    test('sets errorMessage to the exception message', () async {
      final controller = await buildController();

      expect(controller.errorMessage.value, 'Connection error. Please try again.');
    });

    test('profile.value remains null', () async {
      final controller = await buildController();

      expect(controller.profile.value, isNull);
    });

    test('isLoading is false after error', () async {
      final controller = await buildController();

      expect(controller.isLoading.value, isFalse);
    });

    test('does not call logout on non-unauthorized error', () async {
      await buildController();

      verifyNever(() => mockAuthRepository.logout());
    });
  });

  group('ProfileController.fetchProfile on unknown exception', () {
    setUp(() {
      when(() => mockProfileRepository.getProfile())
          .thenThrow(Exception('Unexpected'));
    });

    test('sets a generic errorMessage for non-ProfileException errors', () async {
      final controller = await buildController();

      // In test mode, .tr returns the translation key rather than the resolved
      // English string — assert that a non-empty message was set.
      expect(controller.errorMessage.value, isNotEmpty);
    });

    test('does not call logout on unknown exception', () async {
      await buildController();

      verifyNever(() => mockAuthRepository.logout());
    });
  });

  group('ProfileController.logout', () {
    setUp(() {
      // Stub fetchProfile triggered by onInit
      when(() => mockProfileRepository.getProfile())
          .thenAnswer((_) async => makeProfile());
    });

    test('calls authRepository.logout', () async {
      final controller = await buildController();
      await controller.logout();

      // Verify logout was called at least once (once from logout(), not from onInit)
      verify(() => mockAuthRepository.logout()).called(1);
    });
  });
}
