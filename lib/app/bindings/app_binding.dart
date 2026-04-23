import 'package:get/get.dart';

import '../../core/services/api_client.dart';
import '../../data/providers/auth_provider.dart';
import '../../data/providers/profile_provider.dart';
import '../../data/providers/shipment_provider.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/profile_repository.dart';
import '../../data/repositories/shipment_repository.dart';
import '../../data/services/location_service.dart';

/// Global dependencies that should be available app-wide.
class AppBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<LocationService>(LocationService(), permanent: true);
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

    Get.put<ShipmentProvider>(
      ShipmentProvider(Get.find<ApiClient>()),
      permanent: true,
    );

    Get.put<ShipmentRepository>(
      ShipmentRepository(provider: Get.find<ShipmentProvider>()),
      permanent: true,
    );
  }
}
