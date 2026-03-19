import 'package:get/get.dart';

import '../../core/utils/logger.dart';

class HomeController extends GetxController {
  final count = 0.obs;

  @override
  void onInit() {
    super.onInit();
    Log.i('HomeController initialized', tag: 'HOME');
  }

  void increment() => count.value++;

  @override
  void onClose() {
    Log.i('HomeController disposed', tag: 'HOME');
    super.onClose();
  }
}
