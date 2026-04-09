import 'package:get/get.dart';

import '../profile/profile_controller.dart';
import 'home_controller.dart';
import 'orders/orders_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(() => HomeController());
    Get.lazyPut<ProfileController>(() => ProfileController());
    Get.lazyPut<OrdersController>(() => OrdersController());
  }
}
