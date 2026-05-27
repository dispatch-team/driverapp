import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../app/routes/app_routes.dart';
import '../../data/repositories/auth_repository.dart';

class LoginController extends GetxController {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final RxBool isPasswordVisible = false.obs;
  final RxBool isLoading = false.obs;

  late final AuthRepository _authRepository;

  @override
  void onInit() {
    super.onInit();
    _authRepository = Get.find<AuthRepository>();
  }

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  Future<void> login() async {
    final username = usernameController.text.trim();
    final password = passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      Get.snackbar(
        'snack_missing_fields_title'.tr,
        'snack_missing_fields_body'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    isLoading.value = true;

    final error = await _authRepository.login(username, password);

    isLoading.value = false;

    if (error != null) {
      Get.snackbar(
        'snack_login_failed_title'.tr,
        error,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    TextInput.finishAutofillContext();
    Get.offAllNamed(AppRoutes.home);
  }

  @override
  void onClose() {
    usernameController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
