import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/utils/coord_utils.dart';
import '../../../data/models/shipment.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/shipment_repository.dart';

class HistoryController extends GetxController {
  final ShipmentRepository _shipmentRepository;
  final AuthRepository _authRepository;

  HistoryController()
      : _shipmentRepository = Get.find<ShipmentRepository>(),
        _authRepository = Get.find<AuthRepository>();

  final RxList<Shipment> shipments = <Shipment>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString loadMoreErrorMessage = ''.obs;
  final Rx<ShipmentStatus?> selectedStatus = Rx<ShipmentStatus?>(null);

  int _page = 1;
  bool _hasNextPage = true;
  static const int _pageSize = 10;

  // Statuses shown on the history page
  static const _historyStatuses = {
    ShipmentStatus.delivered,
    ShipmentStatus.failed,
  };

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
      final filtered = selectedStatus.value == null
          ? result.shipments
              .where((s) => _historyStatuses.contains(s.status))
              .toList()
          : result.shipments;
      shipments.assignAll(filtered);
      // If the API returned a full page there may be more; stop only when it
      // returns fewer than a full page.
      _hasNextPage = result.shipments.length >= _pageSize;
    } catch (e) {
      final isUnauthorized = e is ShipmentException && e.isUnauthorized;
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
      final filtered = selectedStatus.value == null
          ? result.shipments
              .where((s) => _historyStatuses.contains(s.status))
              .toList()
          : result.shipments;
      shipments.addAll(filtered);
      _hasNextPage = result.shipments.length >= _pageSize;
    } catch (e) {
      final isUnauthorized = e is ShipmentException && e.isUnauthorized;
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

  String displayAddress(String rawAddress) {
    return parseAddressLabel(rawAddress);
  }
}
