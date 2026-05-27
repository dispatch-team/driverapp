import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:pinput/pinput.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/localization/app_translations.dart';
import '../../../core/localization/locale_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/coord_utils.dart';
import '../../../data/models/shipment.dart';
import '../../../widgets/app_primary_button.dart';
import 'orders_controller.dart';
import 'shipment_map_controller.dart';
import 'widgets/shipment_map_card.dart';

// ─── Date helper ──────────────────────────────────────────────────────────────

String _formatDateTime(DateTime dt) {
  final local = dt.toLocal();
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  final month = months[local.month - 1];
  final day = local.day;
  final year = local.year;
  final hour = local.hour % 12 == 0 ? 12 : local.hour % 12;
  final minute = local.minute.toString().padLeft(2, '0');
  final period = local.hour < 12 ? 'AM' : 'PM';
  return '$month $day, $year · $hour:$minute $period';
}

// ─── Shipment detail page ─────────────────────────────────────────────────────

class ShipmentDetailView extends GetView<OrdersController> {
  const ShipmentDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final initialShipment = Get.arguments as Shipment;

    // Set the reactive detail shipment when first opening the page.
    // Using addPostFrameCallback to avoid calling setState during build.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (controller.detailShipment.value?.id != initialShipment.id) {
        controller.setDetailShipment(initialShipment);
      }
    });

    return _ShipmentDetailBody(
      initialShipment: initialShipment,
      ordersController: controller,
    );
  }
}

/// Stateful wrapper that owns the [ShipmentMapController] lifecycle for this
/// detail page. Putting lifecycle in a [StatefulWidget] ensures [onClose] is
/// called when the widget is disposed (i.e. when we navigate back).
class _ShipmentDetailBody extends StatefulWidget {
  const _ShipmentDetailBody({
    required this.initialShipment,
    required this.ordersController,
  });

  final Shipment initialShipment;
  final OrdersController ordersController;

  @override
  State<_ShipmentDetailBody> createState() => _ShipmentDetailBodyState();
}

class _ShipmentDetailBodyState extends State<_ShipmentDetailBody> {
  late final String _mapTag;
  bool _mapControllerRegistered = false;

  OrdersController get _ctrl => widget.ordersController;

  @override
  void initState() {
    super.initState();
    _mapTag = 'map_${widget.initialShipment.id}';
    _maybeRegisterMapController(widget.initialShipment);
  }

  bool _shouldShowMap(Shipment shipment) {
    if (shipment.status == ShipmentStatus.assignedToDriver) {
      return tryParseCoordinates(shipment.startAddress) != null;
    }
    if (shipment.status == ShipmentStatus.inTransit) {
      return tryParseCoordinates(shipment.endAddress) != null;
    }
    return false;
  }

  void _maybeRegisterMapController(Shipment shipment) {
    if (!_mapControllerRegistered && _shouldShowMap(shipment)) {
      Get.put<ShipmentMapController>(
        ShipmentMapController(shipment: shipment.obs),
        tag: _mapTag,
      );
      _mapControllerRegistered = true;
    }
  }

  @override
  void dispose() {
    if (_mapControllerRegistered) {
      Get.delete<ShipmentMapController>(tag: _mapTag);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;

    return Obx(() {
      final shipment = _ctrl.detailShipment.value ?? widget.initialShipment;

      // Register the map controller lazily once conditions are met.
      _maybeRegisterMapController(shipment);

      // Keep the map controller's shipment in sync after status transitions.
      if (_mapControllerRegistered) {
        Get.find<ShipmentMapController>(tag: _mapTag).shipment.value = shipment;
      }

      final showMap = _mapControllerRegistered && _shouldShowMap(shipment);

      return Scaffold(
        backgroundColor: colors.scaffold,
        bottomNavigationBar: _ActionBar(
          shipment: shipment,
          colors: colors,
          controller: _ctrl,
        ),
        body: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            _DetailAppBar(shipment: shipment, colors: colors),
            if (showMap)
              SliverToBoxAdapter(
                child: ShipmentMapCard(tag: _mapTag),
              ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _PackageInfoSection(shipment: shipment, colors: colors),
                  const SizedBox(height: 16),
                  _ContactSection(
                    label: 'detail_merchant_pickup'.tr,
                    dotColor: const Color(0xFFEA4335),
                    rawAddress: shipment.startAddress,
                    contactName: shipment.startAddressContactName,
                    phoneNumber: shipment.startAddressPhoneNumber,
                    additionalContact: shipment.startAddressAdditionalContact,
                    colors: colors,
                    ordersController: _ctrl,
                  ),
                  const SizedBox(height: 16),
                  _ContactSection(
                    label: 'detail_customer_dropoff'.tr,
                    dotColor: const Color(0xFF4285F4),
                    rawAddress: shipment.endAddress,
                    contactName: shipment.endAddressContactName,
                    phoneNumber: shipment.endAddressPhoneNumber,
                    additionalContact: shipment.endAddressAdditionalContact,
                    colors: colors,
                    ordersController: _ctrl,
                  ),
                  const SizedBox(height: 16),
                  _StatusTimelineSection(shipment: shipment, colors: colors),
                  if (shipment.items != null && shipment.items!.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    _ItemsSection(shipment: shipment, colors: colors),
                  ],
                ]),
              ),
            ),
          ],
        ),
      );
    });
  }
}

// ─── Bottom action bar ────────────────────────────────────────────────────────

class _ActionBar extends StatelessWidget {
  const _ActionBar({
    required this.shipment,
    required this.colors,
    required this.controller,
  });

  final Shipment shipment;
  final AppColors colors;
  final OrdersController controller;

  @override
  Widget build(BuildContext context) {
    if (shipment.status == ShipmentStatus.assignedToDriver) {
      return _PickupActionBar(colors: colors, controller: controller);
    }
    if (shipment.status == ShipmentStatus.inTransit) {
      return _DeliveredActionBar(
        shipment: shipment,
        colors: colors,
        controller: controller,
      );
    }
    return const SizedBox.shrink();
  }
}

class _PickupActionBar extends StatelessWidget {
  const _PickupActionBar({
    required this.colors,
    required this.controller,
  });

  final AppColors colors;
  final OrdersController controller;

  @override
  Widget build(BuildContext context) {
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
      child: Obx(() {
        final isLoading = controller.isPickingUp.value;
        final error = controller.actionError.value;
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (error.isNotEmpty) ...[
              _ActionErrorText(message: error, colors: colors),
              const SizedBox(height: 8),
            ],
            _GradientButton(
              label: 'detail_btn_arrived'.tr,
              icon: Icons.location_on_rounded,
              isLoading: isLoading,
              colors: colors,
              onTap: isLoading ? null : controller.pickUpShipment,
            ),
          ],
        );
      }),
    );
  }
}

class _DeliveredActionBar extends StatelessWidget {
  const _DeliveredActionBar({
    required this.shipment,
    required this.colors,
    required this.controller,
  });

  final Shipment shipment;
  final AppColors colors;
  final OrdersController controller;

  @override
  Widget build(BuildContext context) {
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
          AppPrimaryButton(
            label: 'detail_btn_delivered'.tr,
            icon: Icons.check_circle_rounded,
            onTap: () => _showVerifySheet(context),
          ),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: () => _showFailSheet(context),
            child: Text(
              'detail_mark_failed'.tr,
              style: localeBodyStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: const Color(0xFFEA4335),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showVerifySheet(BuildContext context) {
    controller.actionError.value = '';
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _DeliveryVerificationSheet(
        colors: colors,
        controller: controller,
      ),
    );
  }

  void _showFailSheet(BuildContext context) {
    controller.actionError.value = '';
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _FailShipmentSheet(
        colors: colors,
        controller: controller,
      ),
    );
  }
}

// ─── Delivery verification bottom sheet ──────────────────────────────────────

class _DeliveryVerificationSheet extends StatefulWidget {
  const _DeliveryVerificationSheet({
    required this.colors,
    required this.controller,
  });

  final AppColors colors;
  final OrdersController controller;

  @override
  State<_DeliveryVerificationSheet> createState() =>
      _DeliveryVerificationSheetState();
}

class _DeliveryVerificationSheetState
    extends State<_DeliveryVerificationSheet> {
  final TextEditingController _pinController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  String _code = '';

  AppColors get colors => widget.colors;
  OrdersController get controller => widget.controller;

  @override
  void initState() {
    super.initState();
    controller.actionError.value = '';
    WidgetsBinding.instance.addPostFrameCallback((_) => _focusNode.requestFocus());
  }

  @override
  void dispose() {
    _pinController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _onVerify() async {
    if (_code.length < 6) return;
    final success = await controller.verifyDelivery(_code);
    if (success && mounted) {
      Navigator.of(context).pop();
      Get.back();
      Get.snackbar(
        'detail_snack_verified_title'.tr,
        'detail_snack_verified_body'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    final defaultPinTheme = PinTheme(
      width: 52,
      height: 58,
      textStyle: localeHeadingStyle(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: colors.textPrimary,
      ),
      decoration: BoxDecoration(
        color: colors.surfaceContainer,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colors.borderSubtle),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        border: Border.all(color: colors.brand, width: 2),
      ),
    );

    final submittedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        color: colors.brand.withValues(alpha: 0.1),
        border: Border.all(color: colors.brand.withValues(alpha: 0.4)),
      ),
    );

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        border: Border(top: BorderSide(color: colors.borderSubtle)),
      ),
      padding: EdgeInsets.fromLTRB(24, 0, 24, 24 + bottomInset),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: colors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),

          // Security protocol label
          Text(
            'detail_verify_label'.tr,
            style: localeBodyStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: colors.brand,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),

          // Heading
          Text(
            'detail_verify_heading'.tr,
            style: localeHeadingStyle(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: colors.textPrimary,
              letterSpacing: -0.5,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 10),

          // Subtitle
          Text(
            'detail_verify_subtitle'.tr,
            style: localeBodyStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: colors.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 28),

          // PIN input
          Center(
            child: Pinput(
              length: 6,
              controller: _pinController,
              focusNode: _focusNode,
              defaultPinTheme: defaultPinTheme,
              focusedPinTheme: focusedPinTheme,
              submittedPinTheme: submittedPinTheme,
              keyboardType: TextInputType.visiblePassword,
              textCapitalization: TextCapitalization.characters,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
              ],
              cursor: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    width: 2,
                    height: 28,
                    decoration: BoxDecoration(
                      color: colors.brand,
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
              onChanged: (value) => setState(() => _code = value),
              onCompleted: (_) => _onVerify(),
            ),
          ),
          const SizedBox(height: 24),

          // Error message
          Obx(() {
            final error = controller.actionError.value;
            if (error.isEmpty) return const SizedBox.shrink();
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _ActionErrorText(message: error, colors: colors),
            );
          }),

          // Verify button
          Obx(() {
            final isLoading = controller.isVerifyingDelivery.value;
            final isReady = _code.length == 6;
            return _GradientButton(
              label: 'detail_btn_verify'.tr,
              icon: Icons.verified_rounded,
              isLoading: isLoading,
              colors: colors,
              disabled: !isReady,
              onTap: (isLoading || !isReady) ? null : _onVerify,
            );
          }),
        ],
      ),
    );
  }
}

// ─── Fail shipment bottom sheet ───────────────────────────────────────────────

class _FailShipmentSheet extends StatefulWidget {
  const _FailShipmentSheet({
    required this.colors,
    required this.controller,
  });

  final AppColors colors;
  final OrdersController controller;

  @override
  State<_FailShipmentSheet> createState() => _FailShipmentSheetState();
}

class _FailShipmentSheetState extends State<_FailShipmentSheet> {
  final TextEditingController _remarkController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  String _remark = '';

  AppColors get colors => widget.colors;
  OrdersController get controller => widget.controller;

  @override
  void initState() {
    super.initState();
    controller.actionError.value = '';
    WidgetsBinding.instance.addPostFrameCallback((_) => _focusNode.requestFocus());
  }

  @override
  void dispose() {
    _remarkController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _onConfirm() async {
    if (_remark.trim().isEmpty) return;
    final success = await controller.failShipment(_remark.trim());
    if (success && mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        border: Border(top: BorderSide(color: colors.borderSubtle)),
      ),
      padding: EdgeInsets.fromLTRB(24, 0, 24, 24 + bottomInset),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: colors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
          Text(
            'detail_fail_label'.tr,
            style: localeBodyStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: const Color(0xFFEA4335),
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'detail_fail_heading'.tr,
            style: localeHeadingStyle(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: colors.textPrimary,
              letterSpacing: -0.5,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'detail_fail_subtitle'.tr,
            style: localeBodyStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: colors.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _remarkController,
            focusNode: _focusNode,
            maxLines: 3,
            minLines: 3,
            textCapitalization: TextCapitalization.sentences,
            style: localeBodyStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: colors.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: 'detail_remark_hint'.tr,
              hintStyle: localeBodyStyle(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: colors.textCaption,
              ),
              filled: true,
              fillColor: colors.surfaceContainer,
              contentPadding: const EdgeInsets.all(14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: colors.borderSubtle),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: colors.borderSubtle),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: const Color(0xFFEA4335), width: 2),
              ),
            ),
            onChanged: (value) => setState(() => _remark = value),
          ),
          const SizedBox(height: 20),
          Obx(() {
            final error = controller.actionError.value;
            if (error.isEmpty) return const SizedBox.shrink();
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _ActionErrorText(message: error, colors: colors),
            );
          }),
          Obx(() {
            final isLoading = controller.isFailingShipment.value;
            final isReady = _remark.trim().isNotEmpty;
            return _RedButton(
              label: 'detail_btn_confirm_failure'.tr,
              icon: Icons.cancel_rounded,
              isLoading: isLoading,
              disabled: !isReady,
              onTap: (isLoading || !isReady) ? null : _onConfirm,
            );
          }),
        ],
      ),
    );
  }
}

// ─── Red destructive button ───────────────────────────────────────────────────

class _RedButton extends StatelessWidget {
  const _RedButton({
    required this.label,
    required this.icon,
    required this.isLoading,
    this.disabled = false,
    this.onTap,
  });

  final String label;
  final IconData icon;
  final bool isLoading;
  final bool disabled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: disabled ? 0.5 : 1.0,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          height: 52,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFEA4335), Color(0xFFc5221f)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFEA4335).withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: isLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        label,
                        style: localeBodyStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 0.2,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Icon(icon, size: 16, color: Colors.white),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

// ─── Shared button with loading state ────────────────────────────────────────

class _GradientButton extends StatelessWidget {
  const _GradientButton({
    required this.label,
    required this.icon,
    required this.isLoading,
    required this.colors,
    this.disabled = false,
    this.onTap,
  });

  final String label;
  final IconData icon;
  final bool isLoading;
  final bool disabled;
  final AppColors colors;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final effectiveOpacity = disabled ? 0.5 : 1.0;
    return Opacity(
      opacity: effectiveOpacity,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          height: 52,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [colors.brand, colors.brandDim],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(10),
            boxShadow: [colors.buttonShadow],
          ),
          child: Center(
            child: isLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        label,
                        style: localeBodyStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 0.2,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Icon(icon, size: 16, color: Colors.white),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

class _ActionErrorText extends StatelessWidget {
  const _ActionErrorText({required this.message, required this.colors});

  final String message;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.error_outline_rounded,
            size: 14, color: const Color(0xFFEA4335)),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            message,
            style: localeBodyStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: const Color(0xFFEA4335),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── App bar ──────────────────────────────────────────────────────────────────

class _DetailAppBar extends StatelessWidget {
  const _DetailAppBar({required this.shipment, required this.colors});

  final Shipment shipment;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      backgroundColor: colors.scaffold,
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.transparent,
      elevation: 0,
      leading: GestureDetector(
        onTap: () => Get.back(),
        child: Container(
          margin: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: colors.surfaceContainer,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: colors.borderSubtle),
          ),
          child: Icon(
            Icons.arrow_back_rounded,
            size: 18,
            color: colors.textPrimary,
          ),
        ),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            shipment.code,
            style: localeHeadingStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: colors.textPrimary,
              letterSpacing: -0.3,
            ),
          ),
        ],
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: _StatusBadge(status: shipment.status),
        ),
      ],
    );
  }
}

// ─── Package info section ─────────────────────────────────────────────────────

class _PackageInfoSection extends StatelessWidget {
  const _PackageInfoSection({required this.shipment, required this.colors});

  final Shipment shipment;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    final weightLabel =
        '${shipment.weightKg % 1 == 0 ? shipment.weightKg.toInt() : shipment.weightKg} KG';
    final feeLabel =
        'ETB ${shipment.totalFee % 1 == 0 ? shipment.totalFee.toInt() : shipment.totalFee.toStringAsFixed(2)}';

    return _SectionCard(
      colors: colors,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionLabel(label: 'detail_section_pkg_info'.tr, colors: colors),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _InfoChip(
                icon: Icons.scale_outlined,
                label: weightLabel,
                colors: colors,
              ),
              _InfoChip(
                icon: Icons.payments_outlined,
                label: feeLabel,
                colors: colors,
              ),
              if (shipment.dimensions.isNotEmpty)
                _InfoChip(
                  icon: Icons.straighten_outlined,
                  label: shipment.dimensions,
                  colors: colors,
                ),
              if (shipment.items != null && shipment.items!.isNotEmpty)
                _InfoChip(
                  icon: Icons.inventory_2_outlined,
                  label:
                      '${shipment.items!.length} ${shipment.items!.length == 1 ? 'orders_unit_item'.tr : 'orders_unit_items'.tr}',
                  colors: colors,
                ),
            ],
          ),
          if (shipment.description.isNotEmpty) ...[
            const SizedBox(height: 14),
            _Divider(colors: colors),
            const SizedBox(height: 14),
            _LabeledText(
              label: 'detail_section_description'.tr,
              value: shipment.description,
              colors: colors,
            ),
          ],
          if (shipment.remark.isNotEmpty) ...[
            const SizedBox(height: 14),
            _Divider(colors: colors),
            const SizedBox(height: 14),
            _LabeledText(
              label: 'detail_section_remark'.tr,
              value: shipment.remark,
              colors: colors,
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Contact section ──────────────────────────────────────────────────────────

class _ContactSection extends StatelessWidget {
  const _ContactSection({
    required this.label,
    required this.dotColor,
    required this.rawAddress,
    required this.contactName,
    required this.phoneNumber,
    required this.additionalContact,
    required this.colors,
    required this.ordersController,
  });

  final String label;
  final Color dotColor;
  final String rawAddress;
  final String contactName;
  final String phoneNumber;
  final String additionalContact;
  final AppColors colors;
  final OrdersController ordersController;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      colors: colors,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: dotColor.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  border: Border.all(color: dotColor, width: 2),
                ),
              ),
              const SizedBox(width: 8),
              _SectionLabel(label: label, colors: colors),
            ],
          ),
          const SizedBox(height: 12),
          _DetailRow(
            icon: Icons.location_on_outlined,
            value: ordersController.displayAddress(rawAddress),
            colors: colors,
          ),
          if (contactName.isNotEmpty) ...[
            const SizedBox(height: 10),
            _DetailRow(
              icon: Icons.person_outline_rounded,
              value: contactName,
              colors: colors,
            ),
          ],
          if (phoneNumber.isNotEmpty) ...[
            const SizedBox(height: 14),
            AppPrimaryButton(
              label: phoneNumber,
              icon: Icons.phone_rounded,
              onTap: () async {
                final uri = Uri(scheme: 'tel', path: phoneNumber);
                if (await canLaunchUrl(uri)) await launchUrl(uri);
              },
            ),
          ],
          if (additionalContact.isNotEmpty) ...[
            const SizedBox(height: 10),
            _DetailRow(
              icon: Icons.contact_phone_outlined,
              value: additionalContact,
              colors: colors,
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Status timeline section ──────────────────────────────────────────────────

class _StatusTimelineSection extends StatelessWidget {
  const _StatusTimelineSection({
    required this.shipment,
    required this.colors,
  });

  final Shipment shipment;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    final steps = _buildSteps();

    return _SectionCard(
      colors: colors,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionLabel(label: 'detail_section_timeline'.tr, colors: colors),
          const SizedBox(height: 16),
          ...steps.asMap().entries.map((entry) {
            final index = entry.key;
            final step = entry.value;
            final isLast = index == steps.length - 1;
            return _TimelineStep(
              step: step,
              isLast: isLast,
              colors: colors,
            );
          }),
        ],
      ),
    );
  }

  List<_TimelineStepData> _buildSteps() {
    final steps = <_TimelineStepData>[];

    steps.add(_TimelineStepData(
      label: 'timeline_created'.tr,
      timestamp: shipment.createdAt,
      isCompleted: true,
    ));

    if (shipment.assignedToCourierAt != null) {
      steps.add(_TimelineStepData(
        label: 'timeline_courier_assigned'.tr,
        timestamp: shipment.assignedToCourierAt,
        isCompleted: true,
      ));
    }

    if (shipment.assignedToDriverAt != null) {
      steps.add(_TimelineStepData(
        label: 'timeline_driver_assigned'.tr,
        timestamp: shipment.assignedToDriverAt,
        isCompleted: true,
      ));
    }

    if (shipment.pickedUpAt != null) {
      steps.add(_TimelineStepData(
        label: 'timeline_picked_up'.tr,
        timestamp: shipment.pickedUpAt,
        isCompleted: true,
      ));
    }

    if (shipment.inTransitAt != null) {
      steps.add(_TimelineStepData(
        label: 'timeline_in_transit'.tr,
        timestamp: shipment.inTransitAt,
        isCompleted: true,
      ));
    }

    if (shipment.deliveredAt != null) {
      steps.add(_TimelineStepData(
        label: 'timeline_delivered'.tr,
        timestamp: shipment.deliveredAt,
        isCompleted: true,
        isSuccess: true,
      ));
    }

    if (shipment.failedAt != null) {
      steps.add(_TimelineStepData(
        label: 'timeline_failed'.tr,
        timestamp: shipment.failedAt,
        isCompleted: true,
        isFailure: true,
      ));
    }

    if (shipment.returnedAt != null) {
      steps.add(_TimelineStepData(
        label: 'timeline_returned'.tr,
        timestamp: shipment.returnedAt,
        isCompleted: true,
        isFailure: true,
      ));
    }

    if (shipment.cancelledAt != null) {
      steps.add(_TimelineStepData(
        label: 'timeline_cancelled'.tr,
        timestamp: shipment.cancelledAt,
        isCompleted: true,
        isFailure: true,
      ));
    }

    return steps;
  }
}

class _TimelineStepData {
  const _TimelineStepData({
    required this.label,
    required this.timestamp,
    required this.isCompleted,
    this.isSuccess = false,
    this.isFailure = false,
  });

  final String label;
  final DateTime? timestamp;
  final bool isCompleted;
  final bool isSuccess;
  final bool isFailure;
}

class _TimelineStep extends StatelessWidget {
  const _TimelineStep({
    required this.step,
    required this.isLast,
    required this.colors,
  });

  final _TimelineStepData step;
  final bool isLast;
  final AppColors colors;

  Color get _dotColor {
    if (step.isFailure) return const Color(0xFFEA4335);
    if (step.isSuccess) return const Color(0xFF34A853);
    return const Color(0xFFFF8C00);
  }

  @override
  Widget build(BuildContext context) {
    final formattedTime =
        step.timestamp != null ? _formatDateTime(step.timestamp!) : '';

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 24,
            child: Column(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  margin: const EdgeInsets.only(top: 2),
                  decoration: BoxDecoration(
                    color: _dotColor.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                    border: Border.all(color: _dotColor, width: 2),
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 1.5,
                      margin: const EdgeInsets.symmetric(vertical: 3),
                      color: colors.divider,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    step.label,
                    style: localeBodyStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: colors.textPrimary,
                    ),
                  ),
                  if (formattedTime.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      formattedTime,
                      style: localeBodyStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: colors.textCaption,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Items section ────────────────────────────────────────────────────────────

class _ItemsSection extends StatelessWidget {
  const _ItemsSection({required this.shipment, required this.colors});

  final Shipment shipment;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      colors: colors,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionLabel(label: 'detail_section_items'.tr, colors: colors),
          const SizedBox(height: 12),
          ...shipment.items!.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            final isLast = index == shipment.items!.length - 1;
            return Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Container(
                        width: 5,
                        height: 5,
                        decoration: BoxDecoration(
                          color: colors.textCaption,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        item,
                        style: localeBodyStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: colors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
                if (!isLast) const SizedBox(height: 8),
              ],
            );
          }),
        ],
      ),
    );
  }
}

// ─── Reusable primitives ──────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.colors, required this.child});

  final AppColors colors;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: colors.surfaceContainer,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.borderSubtle),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(11),
        ),
        child: child,
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label, required this.colors});

  final String label;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: localeBodyStyle(
        fontSize: 9,
        fontWeight: FontWeight.w700,
        color: colors.textCaption,
        letterSpacing: 1,
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.icon,
    required this.label,
    required this.colors,
  });

  final IconData icon;
  final String label;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: colors.surfaceContainer,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colors.borderSubtle),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: colors.textCaption),
          const SizedBox(width: 5),
          Text(
            label,
            style: localeBodyStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: colors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.value,
    required this.colors,
  });

  final IconData icon;
  final String value;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 1),
          child: Icon(
            icon,
            size: 15,
            color: colors.iconSubtle,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            value,
            style: localeBodyStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: colors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}

class _LabeledText extends StatelessWidget {
  const _LabeledText({
    required this.label,
    required this.value,
    required this.colors,
  });

  final String label;
  final String value;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionLabel(label: label, colors: colors),
        const SizedBox(height: 6),
        Text(
          value,
          style: localeBodyStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: colors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider({required this.colors});

  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    return Container(height: 1, color: colors.divider);
  }
}

// ─── Status badge (mirrors the one in orders_view.dart) ───────────────────────

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final ShipmentStatus status;

  @override
  Widget build(BuildContext context) {
    final color = status.color;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 5),
          Text(
            status.labelKey.tr.toUpperCase(),
            style: localeBodyStyle(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: color,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }
}
