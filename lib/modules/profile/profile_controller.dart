import 'package:get/get.dart';

import '../../app/routes/app_routes.dart';
import '../../data/models/driver_profile.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/profile_repository.dart';

class ProfileController extends GetxController {
  final ProfileRepository _profileRepository;
  final AuthRepository _authRepository;

  ProfileController()
      : _profileRepository = Get.find<ProfileRepository>(),
        _authRepository = Get.find<AuthRepository>();

  final Rx<DriverProfile?> profile = Rx(null);
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchProfile();
  }

  Future<void> fetchProfile() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final result = await _profileRepository.getProfile();
      profile.value = result;
    } catch (e) {
      final isUnauthorized =
          e is ProfileException && e.isUnauthorized;

      if (isUnauthorized) {
        await _authRepository.logout();
        Get.offAllNamed(AppRoutes.login);
        return;
      }

      errorMessage.value =
          e is ProfileException ? e.message : 'An unexpected error occurred.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    await _authRepository.logout();
    Get.offAllNamed(AppRoutes.login);
  }
}
