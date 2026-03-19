import 'package:get/get.dart';

/// Global dependencies that should be available app-wide.
class AppBinding extends Bindings {
  @override
  void dependencies() {
    // Register global services here, e.g.:
    // Get.putAsync<AuthService>(() => AuthService().init());
  }
}
