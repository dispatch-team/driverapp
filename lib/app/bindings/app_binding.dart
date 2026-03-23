import 'package:get/get.dart';

import '../../core/services/api_client.dart';
import '../../data/providers/auth_provider.dart';
import '../../data/providers/profile_provider.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/profile_repository.dart';

/// Global dependencies that should be available app-wide.
class AppBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<ApiClient>(ApiClient(), permanent: true);

    Get.put<AuthProvider>(
      AuthProvider(Get.find<ApiClient>()),
      permanent: true,
    );

    Get.put<AuthRepository>(
      AuthRepository(
        provider: Get.find<AuthProvider>(),
        apiClient: Get.find<ApiClient>(),
      ),
      permanent: true,
    );

    Get.put<ProfileProvider>(
      ProfileProvider(Get.find<ApiClient>()),
      permanent: true,
    );

    Get.put<ProfileRepository>(
      ProfileRepository(provider: Get.find<ProfileProvider>()),
      permanent: true,
    );
  }
}
