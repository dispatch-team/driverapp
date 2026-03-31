import 'dart:async';

import 'package:driverapp/data/repositories/auth_repository.dart';
import 'package:driverapp/modules/auth/login_controller.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/mocks.dart';

void main() {
  late MockAuthRepository mockAuthRepository;
  late LoginController controller;

  setUpAll(() {
    // Required to allow Flutter service calls like TextInput.finishAutofillContext()
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  setUp(() {
    Get.testMode = true;
    mockAuthRepository = MockAuthRepository();
    Get.put<AuthRepository>(mockAuthRepository);
    controller = LoginController();
    controller.onInit();
  });

  tearDown(() {
    // Don't manually call onClose() here — the onClose test calls it directly
    // and a second call would cause a double-dispose on the TextEditingControllers.
    // Get.reset() is sufficient to clean up GetX state between tests.
    Get.reset();
  });

  group('LoginController initial state', () {
    test('isPasswordVisible starts as false', () {
      expect(controller.isPasswordVisible.value, isFalse);
    });

    test('isLoading starts as false', () {
      expect(controller.isLoading.value, isFalse);
    });
  });

  group('LoginController.togglePasswordVisibility', () {
    test('flips isPasswordVisible from false to true', () {
      controller.togglePasswordVisibility();
      expect(controller.isPasswordVisible.value, isTrue);
    });

    test('flips isPasswordVisible back to false on second call', () {
      controller.togglePasswordVisibility();
      controller.togglePasswordVisibility();
      expect(controller.isPasswordVisible.value, isFalse);
    });
  });

  group('LoginController.login with empty fields', () {
    // In a pure unit-test environment there is no widget tree, so Get.snackbar()
    // fires an UNHANDLED async error from its internal queue (GetQueue._check)
    // after login() has already returned. A try/catch cannot intercept it because
    // it is thrown in a separate async callback. runZonedGuarded absorbs it,
    // letting us verify only the behaviour we care about.
    Future<void> loginIgnoringSnackbarError() {
      final completer = Completer<void>();
      runZonedGuarded(
        () async {
          await controller.login();
          // Give the snackbar queue one microtask turn to fire (and be absorbed).
          await Future<void>.delayed(Duration.zero);
          if (!completer.isCompleted) completer.complete();
        },
        (_, __) {
          // Swallow async errors from the headless GetX snackbar.
          if (!completer.isCompleted) completer.complete();
        },
      );
      return completer.future;
    }

    test('does not call the repository when username is empty', () async {
      controller.usernameController.text = '';
      controller.passwordController.text = 'secret';

      await loginIgnoringSnackbarError();

      verifyNever(() => mockAuthRepository.login(any(), any()));
    });

    test('does not call the repository when password is empty', () async {
      controller.usernameController.text = 'driver1';
      controller.passwordController.text = '';

      await loginIgnoringSnackbarError();

      verifyNever(() => mockAuthRepository.login(any(), any()));
    });

    test('does not call the repository when both fields are empty', () async {
      controller.usernameController.text = '';
      controller.passwordController.text = '';

      await loginIgnoringSnackbarError();

      verifyNever(() => mockAuthRepository.login(any(), any()));
    });

    test('does not call the repository for whitespace-only fields', () async {
      controller.usernameController.text = '   ';
      controller.passwordController.text = '   ';

      await loginIgnoringSnackbarError();

      verifyNever(() => mockAuthRepository.login(any(), any()));
    });

    test('isLoading remains false when fields are empty', () async {
      await loginIgnoringSnackbarError();
      expect(controller.isLoading.value, isFalse);
    });
  });

  group('LoginController.login on success', () {
    setUp(() {
      when(() => mockAuthRepository.login(any(), any()))
          .thenAnswer((_) async => null);
    });

    test('calls repository with trimmed username and password', () async {
      controller.usernameController.text = '  driver1  ';
      controller.passwordController.text = '  secret  ';

      await controller.login();

      verify(() => mockAuthRepository.login('driver1', 'secret')).called(1);
    });

    test('isLoading is false after successful login', () async {
      controller.usernameController.text = 'driver1';
      controller.passwordController.text = 'secret';

      await controller.login();

      expect(controller.isLoading.value, isFalse);
    });
  });

  group('LoginController.login on failure', () {
    setUp(() {
      when(() => mockAuthRepository.login(any(), any()))
          .thenAnswer((_) async => 'Invalid credentials.');
    });

    test('isLoading is false after failed login', () async {
      controller.usernameController.text = 'driver1';
      controller.passwordController.text = 'wrong';

      await controller.login();

      expect(controller.isLoading.value, isFalse);
    });

    test('still calls repository with provided credentials', () async {
      controller.usernameController.text = 'driver1';
      controller.passwordController.text = 'wrong';

      await controller.login();

      verify(() => mockAuthRepository.login('driver1', 'wrong')).called(1);
    });
  });

  group('LoginController.onClose', () {
    test('disposes text controllers without throwing', () {
      // Use a dedicated controller so this call is the first (and only) dispose,
      // preventing a double-dispose conflict with tearDown.
      final freshController = LoginController();
      freshController.onInit();
      expect(() => freshController.onClose(), returnsNormally);
    });
  });
}
