import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/localization/locale_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../widgets/app_primary_button.dart';
import '../shipment_map_controller.dart';

// ─── Collapsed map card (20% of screen height) ────────────────────────────────

class ShipmentMapCard extends StatelessWidget {
  const ShipmentMapCard({super.key, required this.tag});

  final String tag;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final controller = Get.find<ShipmentMapController>(tag: tag);
    final height = MediaQuery.of(context).size.height * 0.20;

    return Obx(() {
      final dest = controller.destination.value;
      if (dest == null) return const SizedBox.shrink();

      return GestureDetector(
        onTap: () => Get.to(
          () => ShipmentMapFullScreen(tag: tag),
          transition: Transition.fadeIn,
        ),
        child: Container(
          height: height,
          margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: colors.borderSubtle),
            color: colors.surfaceContainer,
          ),
          clipBehavior: Clip.hardEdge,
          child: Stack(
            children: [
              _MapView(controller: controller, interactive: false),
              _LocationBanner(controller: controller, colors: colors),
              _ExpandHint(colors: colors),
              _LoadingOverlay(controller: controller),
            ],
          ),
        ),
      );
    });
  }
}

// ─── Full-screen map view ─────────────────────────────────────────────────────

class ShipmentMapFullScreen extends StatelessWidget {
  const ShipmentMapFullScreen({super.key, required this.tag});

  final String tag;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final controller = Get.find<ShipmentMapController>(tag: tag);

    return Scaffold(
      backgroundColor: colors.scaffold,
      body: Stack(
        children: [
          _MapView(controller: controller, interactive: true),
          _LoadingOverlay(controller: controller),
          // Close button
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: GestureDetector(
                onTap: () => Get.back(),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: colors.borderSubtle),
                    boxShadow: [colors.buttonShadow],
                  ),
                  child: Icon(
                    Icons.close_rounded,
                    size: 18,
                    color: colors.textPrimary,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Obx(() {
        final driver = controller.driverPosition.value;
        final dest = controller.destination.value;
        final label = controller.destinationLabel.value;

        return Container(
          padding: EdgeInsets.fromLTRB(
            16,
            12,
            16,
            12 + MediaQuery.of(context).padding.bottom,
          ),
          decoration: BoxDecoration(
            color: colors.scaffold,
            border: Border(top: BorderSide(color: colors.borderSubtle)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (controller.routeError.value.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _ErrorChip(
                    message: controller.routeError.value,
                    onRetry: controller.refreshRoute,
                    colors: colors,
                  ),
                ),
              AppPrimaryButton(
                label: 'map_open_google_maps'.tr,
                icon: Icons.directions_rounded,
                onTap: (driver != null && dest != null)
                    ? () => _openGoogleMaps(driver, dest)
                    : () => _openGoogleMapsDestOnly(dest!, label),
              ),
            ],
          ),
        );
      }),
    );
  }

  Future<void> _openGoogleMaps(LatLng origin, LatLng dest) async {
    final uri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1'
      '&origin=${origin.latitude},${origin.longitude}'
      '&destination=${dest.latitude},${dest.longitude}'
      '&travelmode=driving',
    );
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  Future<void> _openGoogleMapsDestOnly(LatLng dest, String label) async {
    final encoded = Uri.encodeComponent(label.isEmpty ? 'Destination' : label);
    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1'
      '&query=${dest.latitude},${dest.longitude}'
      '&query_place_id=$encoded',
    );
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }
}

// ─── Shared map view ──────────────────────────────────────────────────────────

class _MapView extends StatefulWidget {
  const _MapView({required this.controller, required this.interactive});

  final ShipmentMapController controller;
  final bool interactive;

  @override
  State<_MapView> createState() => _MapViewState();
}

class _MapViewState extends State<_MapView> {
  GoogleMapController? _mapController;
  StreamSubscription<dynamic>? _sub;

  ShipmentMapController get ctrl => widget.controller;

  @override
  void initState() {
    super.initState();
    // Re-fit camera whenever key positions update.
    _sub = ctrl.driverPosition.listen((_) => _fitBounds());
  }

  @override
  void dispose() {
    _sub?.cancel();
    _mapController?.dispose();
    super.dispose();
  }

  Set<Marker> _buildMarkers() {
    final markers = <Marker>{};
    final driver = ctrl.driverPosition.value;
    final dest = ctrl.destination.value;
    final label = ctrl.destinationLabel.value;

    if (driver != null) {
      markers.add(Marker(
        markerId: const MarkerId('driver'),
        position: driver,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        infoWindow: InfoWindow(title: 'map_marker_you'.tr),
      ));
    }

    if (dest != null) {
      markers.add(Marker(
        markerId: const MarkerId('destination'),
        position: dest,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow: InfoWindow(title: label.isEmpty ? 'map_marker_destination'.tr : label),
      ));
    }

    return markers;
  }

  Set<Polyline> _buildPolylines() {
    final points = ctrl.routePoints;
    if (points.length < 2) return {};
    return {
      Polyline(
        polylineId: const PolylineId('route'),
        points: points,
        color: const Color(0xFF4285F4),
        width: 4,
      ),
    };
  }

  CameraPosition _initialCamera() {
    final dest = ctrl.destination.value;
    final driver = ctrl.driverPosition.value;
    final target = driver ?? dest!;
    return CameraPosition(target: target, zoom: 13);
  }

  void _fitBounds() {
    final controller = _mapController;
    if (controller == null) return;
    final driver = ctrl.driverPosition.value;
    final dest = ctrl.destination.value;
    if (driver == null || dest == null) return;

    final bounds = LatLngBounds(
      southwest: LatLng(
        driver.latitude < dest.latitude ? driver.latitude : dest.latitude,
        driver.longitude < dest.longitude ? driver.longitude : dest.longitude,
      ),
      northeast: LatLng(
        driver.latitude > dest.latitude ? driver.latitude : dest.latitude,
        driver.longitude > dest.longitude ? driver.longitude : dest.longitude,
      ),
    );
    controller.animateCamera(
      CameraUpdate.newLatLngBounds(bounds, 60),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final dest = ctrl.destination.value;
      if (dest == null) return const SizedBox.expand();

      return GoogleMap(
        initialCameraPosition: _initialCamera(),
        markers: _buildMarkers(),
        polylines: _buildPolylines(),
        myLocationButtonEnabled: false,
        zoomControlsEnabled: widget.interactive,
        scrollGesturesEnabled: widget.interactive,
        rotateGesturesEnabled: widget.interactive,
        tiltGesturesEnabled: widget.interactive,
        zoomGesturesEnabled: widget.interactive,
        liteModeEnabled: !widget.interactive,
        onMapCreated: (c) {
          _mapController = c;
          _fitBounds();
        },
      );
    });
  }
}

// ─── Permission / error banner inside the card ────────────────────────────────

class _LocationBanner extends StatelessWidget {
  const _LocationBanner({required this.controller, required this.colors});

  final ShipmentMapController controller;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (!controller.locationPermissionDenied.value) {
        return const SizedBox.shrink();
      }
      return Positioned(
        bottom: 0,
        left: 0,
        right: 0,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          color: Colors.black54,
          child: Row(
            children: [
              const Icon(Icons.location_off_rounded,
                  size: 14, color: Colors.white),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'map_enable_location'.tr,
                  style: localeBodyStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}

// ─── "Tap to expand" hint ─────────────────────────────────────────────────────

class _ExpandHint extends StatelessWidget {
  const _ExpandHint({required this.colors});

  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 8,
      right: 8,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.black54,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.fullscreen_rounded, size: 12, color: Colors.white),
            const SizedBox(width: 4),
            Text(
              'map_tap_to_expand'.tr,
              style: localeBodyStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Loading overlay ──────────────────────────────────────────────────────────

class _LoadingOverlay extends StatelessWidget {
  const _LoadingOverlay({required this.controller});

  final ShipmentMapController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (!controller.isLoadingRoute.value) return const SizedBox.shrink();
      return Container(
        color: Colors.black26,
        alignment: Alignment.center,
        child: const SizedBox(
          width: 28,
          height: 28,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            color: Colors.white,
          ),
        ),
      );
    });
  }
}

// ─── Error retry chip ─────────────────────────────────────────────────────────

class _ErrorChip extends StatelessWidget {
  const _ErrorChip({
    required this.message,
    required this.onRetry,
    required this.colors,
  });

  final String message;
  final VoidCallback onRetry;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.warning_amber_rounded,
            size: 14, color: Color(0xFFFBBC04)),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            message,
            style: localeBodyStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: colors.textSecondary,
            ),
          ),
        ),
        GestureDetector(
          onTap: onRetry,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: colors.surfaceContainer,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: colors.borderSubtle),
            ),
            child: Text(
              'map_retry'.tr,
              style: localeBodyStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: colors.brand,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
