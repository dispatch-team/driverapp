import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../data/models/shipment.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/shipment_repository.dart';

class OrdersController extends GetxController {
  final ShipmentRepository _shipmentRepository;
  final AuthRepository _authRepository;

  OrdersController()
      : _shipmentRepository = Get.find<ShipmentRepository>(),
        _authRepository = Get.find<AuthRepository>();

  final RxList<Shipment> shipments = <Shipment>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  int _page = 1;
  static const int _pageSize = 10;

  @override
  void onInit() {
    super.onInit();
    fetchShipments();
  }

  Future<void> fetchShipments() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final result = await _shipmentRepository.getShipments(
        page: _page,
        pageSize: _pageSize,
      );
      shipments.assignAll(result.shipments);
    } catch (e) {
      final isUnauthorized =
          e is ShipmentException && e.isUnauthorized;

      if (isUnauthorized) {
        await _authRepository.logout();
        Get.offAllNamed(AppRoutes.login);
        return;
      }

      errorMessage.value =
          e is ShipmentException ? e.message : 'An unexpected error occurred.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshShipments() async {
    _page = 1;
    await fetchShipments();
  }
}
