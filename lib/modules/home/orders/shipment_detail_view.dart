import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/models/shipment.dart';
import '../../../widgets/app_primary_button.dart';
import 'orders_controller.dart';

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

class ShipmentDetailView extends StatelessWidget {
  const ShipmentDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final shipment = Get.arguments as Shipment;
    final colors = Theme.of(context).extension<AppColors>()!;
    final ordersController = Get.find<OrdersController>();

    return Scaffold(
      backgroundColor: colors.scaffold,
      body: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          _DetailAppBar(shipment: shipment, colors: colors),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _PackageInfoSection(shipment: shipment, colors: colors),
                const SizedBox(height: 16),
                _ContactSection(
                  label: 'MERCHANT (PICKUP)',
                  dotColor: const Color(0xFFEA4335),
                  rawAddress: shipment.startAddress,
                  contactName: shipment.startAddressContactName,
                  phoneNumber: shipment.startAddressPhoneNumber,
                  additionalContact: shipment.startAddressAdditionalContact,
                  colors: colors,
                  ordersController: ordersController,
                ),
                const SizedBox(height: 16),
                _ContactSection(
                  label: 'CUSTOMER (DROP-OFF)',
                  dotColor: const Color(0xFF4285F4),
                  rawAddress: shipment.endAddress,
                  contactName: shipment.endAddressContactName,
                  phoneNumber: shipment.endAddressPhoneNumber,
                  additionalContact: shipment.endAddressAdditionalContact,
                  colors: colors,
                  ordersController: ordersController,
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
            style: GoogleFonts.spaceGrotesk(
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
          _SectionLabel(label: 'PACKAGE INFO', colors: colors),
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
                      '${shipment.items!.length} ${shipment.items!.length == 1 ? 'item' : 'items'}',
                  colors: colors,
                ),
            ],
          ),
          if (shipment.description.isNotEmpty) ...[
            const SizedBox(height: 14),
            _Divider(colors: colors),
            const SizedBox(height: 14),
            _LabeledText(
              label: 'DESCRIPTION',
              value: shipment.description,
              colors: colors,
            ),
          ],
          if (shipment.remark.isNotEmpty) ...[
            const SizedBox(height: 14),
            _Divider(colors: colors),
            const SizedBox(height: 14),
            _LabeledText(
              label: 'REMARK',
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
          Obx(
            () => _DetailRow(
              icon: Icons.location_on_outlined,
              value: ordersController.displayAddress(rawAddress),
              colors: colors,
            ),
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
          _SectionLabel(label: 'STATUS TIMELINE', colors: colors),
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
      label: 'Created',
      timestamp: shipment.createdAt,
      isCompleted: true,
    ));

    if (shipment.assignedToCourierAt != null) {
      steps.add(_TimelineStepData(
        label: 'Courier Assigned',
        timestamp: shipment.assignedToCourierAt,
        isCompleted: true,
      ));
    }

    if (shipment.assignedToDriverAt != null) {
      steps.add(_TimelineStepData(
        label: 'Driver Assigned',
        timestamp: shipment.assignedToDriverAt,
        isCompleted: true,
      ));
    }

    if (shipment.pickedUpAt != null) {
      steps.add(_TimelineStepData(
        label: 'Picked Up',
        timestamp: shipment.pickedUpAt,
        isCompleted: true,
      ));
    }

    if (shipment.inTransitAt != null) {
      steps.add(_TimelineStepData(
        label: 'In Transit',
        timestamp: shipment.inTransitAt,
        isCompleted: true,
      ));
    }

    if (shipment.deliveredAt != null) {
      steps.add(_TimelineStepData(
        label: 'Delivered',
        timestamp: shipment.deliveredAt,
        isCompleted: true,
        isSuccess: true,
      ));
    }

    if (shipment.failedAt != null) {
      steps.add(_TimelineStepData(
        label: 'Failed',
        timestamp: shipment.failedAt,
        isCompleted: true,
        isFailure: true,
      ));
    }

    if (shipment.returnedAt != null) {
      steps.add(_TimelineStepData(
        label: 'Returned',
        timestamp: shipment.returnedAt,
        isCompleted: true,
        isFailure: true,
      ));
    }

    if (shipment.cancelledAt != null) {
      steps.add(_TimelineStepData(
        label: 'Cancelled',
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
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: colors.textPrimary,
                    ),
                  ),
                  if (formattedTime.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      formattedTime,
                      style: GoogleFonts.inter(
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
          _SectionLabel(label: 'ITEMS', colors: colors),
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
                        style: GoogleFonts.inter(
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
      style: GoogleFonts.inter(
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
            style: GoogleFonts.inter(
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
            style: GoogleFonts.inter(
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
          style: GoogleFonts.inter(
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
            status.displayLabel.toUpperCase(),
            style: GoogleFonts.inter(
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
