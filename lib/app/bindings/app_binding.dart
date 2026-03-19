import 'package:get/get.dart';

import '../../core/services/api_client.dart';

/// Global dependencies that should be available app-wide.
class AppBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<ApiClient>(ApiClient(), permanent: true);
  }
}
