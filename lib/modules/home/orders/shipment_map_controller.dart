import 'dart:async';

import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../core/utils/coord_utils.dart';
import '../../../data/models/shipment.dart';
import '../../../data/services/location_service.dart';

/// Per-shipment-detail map controller. Manages driver position, destination
/// resolution, route polyline fetching, and periodic refresh.
class ShipmentMapController extends GetxController {
  ShipmentMapController({required this.shipment});

  final Rx<Shipment> shipment;

  // ─── Observable state ────────────────────────────────────────────────────

  final Rx<LatLng?> driverPosition = Rx<LatLng?>(null);
  final Rx<LatLng?> destination = Rx<LatLng?>(null);
  final RxString destinationLabel = ''.obs;
  final RxList<LatLng> routePoints = <LatLng>[].obs;
  final RxBool isLoadingRoute = false.obs;
  final RxString routeError = ''.obs;
  final RxBool locationPermissionDenied = false.obs;

  // ─── Internals ───────────────────────────────────────────────────────────

  static const String _mapsKey =
      String.fromEnvironment('MAPS_API_KEY', defaultValue: '');

  final LocationService _locationService = Get.find<LocationService>();
  Timer? _refreshTimer;

  @override
  void onInit() {
    super.onInit();
    _resolveDestination();
    _startRefreshCycle();

    // Re-resolve destination when shipment status changes (e.g. after pickup).
    ever(shipment, (_) {
      _resolveDestination();
      refreshRoute();
    });
  }

  @override
  void onClose() {
    _refreshTimer?.cancel();
    super.onClose();
  }

  // ─── Destination resolution ───────────────────────────────────────────────

  void _resolveDestination() {
    final s = shipment.value;
    switch (s.status) {
      case ShipmentStatus.assignedToDriver:
        final coords = tryParseCoordinates(s.startAddress);
        if (coords != null) {
          destination.value = LatLng(coords.$1, coords.$2);
          destinationLabel.value = 'Pickup';
        } else {
          destination.value = null;
        }
      case ShipmentStatus.inTransit:
        final coords = tryParseCoordinates(s.endAddress);
        if (coords != null) {
          destination.value = LatLng(coords.$1, coords.$2);
          destinationLabel.value = 'Drop-off';
        } else {
          destination.value = null;
        }
      default:
        destination.value = null;
    }
  }

  // ─── Refresh cycle ────────────────────────────────────────────────────────

  void _startRefreshCycle() {
    refreshRoute();
    _refreshTimer =
        Timer.periodic(const Duration(minutes: 5), (_) => refreshRoute());
  }

  Future<void> refreshRoute() async {
    if (destination.value == null) return;

    isLoadingRoute.value = true;
    routeError.value = '';

    // 1. Fetch current driver position.
    final position = await _locationService.getCurrent();

    if (position == null) {
      locationPermissionDenied.value =
          !(await _locationService.ensurePermission());
      isLoadingRoute.value = false;
      return;
    }

    locationPermissionDenied.value = false;
    final driverLatLng = LatLng(position.latitude, position.longitude);
    driverPosition.value = driverLatLng;

    // 2. Fetch route polyline.
    await _fetchRoute(driverLatLng, destination.value!);

    isLoadingRoute.value = false;
  }

  Future<void> _fetchRoute(LatLng origin, LatLng dest) async {
    if (_mapsKey.isEmpty) {
      routeError.value = 'Maps API key not configured.';
      _useStraightLine(origin, dest);
      return;
    }

    try {
      final polylinePoints = PolylinePoints();
      final result = await polylinePoints.getRouteBetweenCoordinates(
        googleApiKey: _mapsKey,
        request: PolylineRequest(
          origin: PointLatLng(origin.latitude, origin.longitude),
          destination: PointLatLng(dest.latitude, dest.longitude),
          mode: TravelMode.driving,
        ),
      );

      if (result.points.isNotEmpty) {
        routePoints.assignAll(
          result.points.map((p) => LatLng(p.latitude, p.longitude)),
        );
        routeError.value = '';
      } else {
        routeError.value = result.errorMessage ?? 'Could not fetch route.';
        _useStraightLine(origin, dest);
      }
    } catch (_) {
      routeError.value = 'Route unavailable. Showing straight line.';
      _useStraightLine(origin, dest);
    }
  }

  void _useStraightLine(LatLng origin, LatLng dest) {
    routePoints.assignAll([origin, dest]);
  }
}
