import 'package:driverapp/modules/home/home_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

void main() {
  late HomeController controller;

  setUp(() {
    Get.testMode = true;
    controller = HomeController();
    controller.onInit();
  });

  tearDown(() {
    controller.onClose();
    Get.reset();
  });

  group('HomeController initial state', () {
    test('currentIndex starts at 0', () {
      expect(controller.currentIndex.value, 0);
    });
  });

  group('HomeController.changePage', () {
    test('updates currentIndex to the given index', () {
      controller.changePage(2);
      expect(controller.currentIndex.value, 2);
    });

    test('updates currentIndex when called multiple times', () {
      controller.changePage(1);
      expect(controller.currentIndex.value, 1);

      controller.changePage(3);
      expect(controller.currentIndex.value, 3);
    });

    test('updates currentIndex back to 0', () {
      controller.changePage(2);
      controller.changePage(0);
      expect(controller.currentIndex.value, 0);
    });
  });
}
