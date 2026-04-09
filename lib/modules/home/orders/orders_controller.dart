import 'dart:async';

import 'package:driverapp/core/utils/logger.dart';
import 'package:geocoding/geocoding.dart';
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
  final RxBool isLoadingMore = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString loadMoreErrorMessage = ''.obs;
  final RxMap<String, String> resolvedAddresses = <String, String>{}.obs;

  int _page = 1;
  int _total = 0;
  bool _hasNextPage = true;
  static const int _pageSize = 10;
  final Set<String> _resolvingAddresses = <String>{};

  bool get hasMoreShipments => _hasNextPage;

  @override
  void onInit() {
    super.onInit();
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
      );
      _total = result.total;
      shipments.assignAll(result.shipments);
      _hasNextPage = shipments.length < _total;
      _resolveShipmentAddresses(result.shipments);
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

  Future<void> loadMoreShipments() async {
    if (isLoading.value || isLoadingMore.value || !_hasNextPage) return;

    isLoadingMore.value = true;
    loadMoreErrorMessage.value = '';

    final nextPage = _page + 1;

    try {
      final result = await _shipmentRepository.getShipments(
        page: nextPage,
        pageSize: _pageSize,
      );

      _page = result.page;
      _total = result.total;
      shipments.addAll(result.shipments);
      _hasNextPage = shipments.length < _total && result.shipments.isNotEmpty;
      _resolveShipmentAddresses(result.shipments);
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

  String displayAddress(String rawAddress) {
    return resolvedAddresses[rawAddress] ?? rawAddress;
  }

  void _resolveShipmentAddresses(List<Shipment> items) {
    for (final shipment in items) {
      _resolveAddress(shipment.startAddress);
      _resolveAddress(shipment.endAddress);
    }
  }

  void _resolveAddress(String rawAddress) {
    if (resolvedAddresses.containsKey(rawAddress) ||
        _resolvingAddresses.contains(rawAddress)) {
      return;
    }

    _resolvingAddresses.add(rawAddress);
    unawaited(_reverseGeocode(rawAddress));
  }

  Future<void> _reverseGeocode(String rawAddress) async {
    try {
      final coords = _tryParseCoordinates(rawAddress);
      if (coords == null) {
        resolvedAddresses[rawAddress] = rawAddress;
        return;
      }

      List<Placemark> placemarks = [];
      try {
        placemarks = await placemarkFromCoordinates(
          coords.$1,
          coords.$2,
        );
      } catch (error, stack) {
        Log.e('Error in placemarkFromCoordinates: $error', error: error.toString());
      }
 

      if (placemarks.isEmpty) {
        resolvedAddresses[rawAddress] = rawAddress;
        return;
      }

      resolvedAddresses[rawAddress] = _formatPlacemark(placemarks.first);
    } catch (_) {
      resolvedAddresses[rawAddress] = rawAddress;
    } finally {
      _resolvingAddresses.remove(rawAddress);
    }
  }

  (double, double)? _tryParseCoordinates(String value) {
    final parts = value.split(';');
    if (parts.length != 2) return null;

    final lat = double.tryParse(parts[0].trim());
    final lng = double.tryParse(parts[1].trim());
    if (lat == null || lng == null) return null;

    return (lat, lng);
  }

  String _formatPlacemark(Placemark placemark) {
    final segments = <String>[
      if ((placemark.subLocality ?? '').isNotEmpty) placemark.subLocality!,
      if ((placemark.locality ?? '').isNotEmpty) placemark.locality!,
      if ((placemark.administrativeArea ?? '').isNotEmpty)
        placemark.administrativeArea!,
    ];

    if (segments.isEmpty) {
      final nameSegments = <String>[
        if ((placemark.name ?? '').isNotEmpty) placemark.name!,
        if ((placemark.country ?? '').isNotEmpty) placemark.country!,
      ];
      return nameSegments.isEmpty ? 'Unknown location' : nameSegments.join(', ');
    }

    return segments.join(', ');
  }
}
