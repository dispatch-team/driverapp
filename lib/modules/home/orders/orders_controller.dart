import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/utils/coord_utils.dart';
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
  final RxBool isLoadingMore = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString loadMoreErrorMessage = ''.obs;
  final Rx<ShipmentStatus?> selectedStatus = Rx<ShipmentStatus?>(null);

  // ─── Detail page state ───────────────────────────────────────────────────
  final Rx<Shipment?> detailShipment = Rx<Shipment?>(null);
  final RxBool isPickingUp = false.obs;
  final RxBool isVerifyingDelivery = false.obs;
  final RxBool isFailingShipment = false.obs;
  final RxString actionError = ''.obs;

  int _page = 1;
  bool _hasNextPage = true;
  static const int _pageSize = 10;

  bool get hasMoreShipments => _hasNextPage;

  @override
  void onInit() {
    super.onInit();
    fetchShipments();
  }

  void setFilter(ShipmentStatus? status) {
    if (selectedStatus.value == status) return;
    selectedStatus.value = status;
    fetchShipments();
  }

  Future<void> fetchShipments() async {
    isLoading.value = true;
    errorMessage.value = '';
    loadMoreErrorMessage.value = '';
    _page = 1;
    _hasNextPage = true;

    try {
      final result = await _shipmentRepository.getShipments(
        page: _page,
        pageSize: _pageSize,
        status: selectedStatus.value,
      );
      // When no specific filter is active, only show shipments that are
      // actively assigned or in transit — exclude delivered/failed/etc.
      final items = selectedStatus.value == null
          ? result.shipments.where((s) => s.status.isActive).toList()
          : result.shipments;
      shipments.assignAll(items);
      _hasNextPage = result.shipments.length >= _pageSize;
    } catch (e) {
      final isUnauthorized =
          e is ShipmentException && e.isUnauthorized;

      if (isUnauthorized) {
        await _authRepository.logout();
        Get.offAllNamed(AppRoutes.login);
        return;
      }

      errorMessage.value =
          e is ShipmentException ? e.message : 'common_error_unexpected'.tr;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadMoreShipments() async {
    if (isLoading.value || isLoadingMore.value || !_hasNextPage) return;

    isLoadingMore.value = true;
    loadMoreErrorMessage.value = '';

    final nextPage = _page + 1;

    try {
      final result = await _shipmentRepository.getShipments(
        page: nextPage,
        pageSize: _pageSize,
        status: selectedStatus.value,
      );

      _page = result.page;
      final items = selectedStatus.value == null
          ? result.shipments.where((s) => s.status.isActive).toList()
          : result.shipments;
      shipments.addAll(items);
      _hasNextPage = result.shipments.length >= _pageSize;
    } catch (e) {
      final isUnauthorized =
          e is ShipmentException && e.isUnauthorized;

      if (isUnauthorized) {
        await _authRepository.logout();
        Get.offAllNamed(AppRoutes.login);
        return;
      }

      loadMoreErrorMessage.value = e is ShipmentException
          ? e.message
          : 'Failed to load more shipments.';
    } finally {
      isLoadingMore.value = false;
    }
  }

  Future<void> refreshShipments() async {
    await fetchShipments();
  }

  // ─── Detail actions ──────────────────────────────────────────────────────

  void setDetailShipment(Shipment shipment) {
    detailShipment.value = shipment;
    actionError.value = '';
  }

  Future<void> pickUpShipment() async {
    final current = detailShipment.value;
    if (current == null || isPickingUp.value) return;

    isPickingUp.value = true;
    actionError.value = '';

    try {
      await _shipmentRepository.pickUp(current.code);
      final now = DateTime.now();
      final updated = current.copyWith(
        status: ShipmentStatus.inTransit,
        pickedUpAt: current.pickedUpAt ?? now,
        inTransitAt: now,
      );
      _updateShipmentInList(updated);
      detailShipment.value = updated;
    } catch (e) {
      if (e is ShipmentException && e.isUnauthorized) {
        await _authRepository.logout();
        Get.offAllNamed(AppRoutes.login);
        return;
      }
      actionError.value =
          e is ShipmentException ? e.message : 'common_error_unexpected'.tr;
    } finally {
      isPickingUp.value = false;
    }
  }

  /// Returns `true` when the delivery was verified successfully.
  Future<bool> verifyDelivery(String deliveryCode) async {
    final current = detailShipment.value;
    if (current == null || isVerifyingDelivery.value) return false;

    isVerifyingDelivery.value = true;
    actionError.value = '';

    try {
      await _shipmentRepository.verifyDelivery(current.code, deliveryCode);
      await refreshShipments();
      return true;
    } catch (e) {
      if (e is ShipmentException && e.isUnauthorized) {
        await _authRepository.logout();
        Get.offAllNamed(AppRoutes.login);
        return false;
      }
      actionError.value =
          e is ShipmentException ? e.message : 'common_error_unexpected'.tr;
      return false;
    } finally {
      isVerifyingDelivery.value = false;
    }
  }

  /// Returns `true` when the shipment was successfully marked as failed.
  Future<bool> failShipment(String remark) async {
    final current = detailShipment.value;
    if (current == null || isFailingShipment.value) return false;

    isFailingShipment.value = true;
    actionError.value = '';

    try {
      await _shipmentRepository.failShipment(current.code, remark);
      final updated = current.copyWith(
        status: ShipmentStatus.failed,
        failedAt: DateTime.now(),
      );
      _updateShipmentInList(updated);
      detailShipment.value = updated;
      return true;
    } catch (e) {
      if (e is ShipmentException && e.isUnauthorized) {
        await _authRepository.logout();
        Get.offAllNamed(AppRoutes.login);
        return false;
      }
      actionError.value =
          e is ShipmentException ? e.message : 'common_error_unexpected'.tr;
      return false;
    } finally {
      isFailingShipment.value = false;
    }
  }

  void _updateShipmentInList(Shipment updated) {
    final idx = shipments.indexWhere((s) => s.id == updated.id);
    if (idx != -1) shipments[idx] = updated;
  }

  /// Returns the human-readable label from an address string.
  ///
  /// For the `"Label | lat;lng"` format, returns the part before `|`.
  /// Falls back to the raw string if no label is present.
  String displayAddress(String rawAddress) {
    return parseAddressLabel(rawAddress);
  }
}
