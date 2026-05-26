import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/shipment.dart';
import '../../../widgets/app_primary_button.dart';
import 'history_controller.dart';

// ─── History page ─────────────────────────────────────────────────────────────

class HistoryView extends GetView<HistoryController> {
  const HistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;

    return Scaffold(
      backgroundColor: colors.scaffold,
      body: SafeArea(
        bottom: false,
        child: Obx(() {
          if (controller.isLoading.value) {
            return Center(
              child: CircularProgressIndicator(color: colors.brand),
            );
          }

          if (controller.errorMessage.value.isNotEmpty) {
            return RefreshIndicator(
              color: colors.brand,
              backgroundColor: colors.surface,
              onRefresh: controller.refreshShipments,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverFillRemaining(
                    child: _ErrorState(
                      message: controller.errorMessage.value,
                      colors: colors,
                      onRetry: controller.refreshShipments,
                    ),
                  ),
                ],
              ),
            );
          }

          if (controller.shipments.isEmpty) {
            return RefreshIndicator(
              color: colors.brand,
              backgroundColor: colors.surface,
              onRefresh: controller.refreshShipments,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverFillRemaining(
                    child: _EmptyState(colors: colors),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            color: colors.brand,
            backgroundColor: colors.surface,
            onRefresh: controller.refreshShipments,
            child: NotificationListener<ScrollNotification>(
              onNotification: (notification) {
                if (notification.metrics.pixels >=
                    notification.metrics.maxScrollExtent - 220) {
                  controller.loadMoreShipments();
                }
                return false;
              },
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: _Header(colors: colors),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: _ShipmentCard(
                            shipment: controller.shipments[index],
                            colors: colors,
                          ),
                        ),
                        childCount: controller.shipments.length,
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: _PaginationFooter(
                      colors: colors,
                      isLoadingMore: controller.isLoadingMore.value,
                      hasMore: controller.hasMoreShipments,
                      errorMessage: controller.loadMoreErrorMessage.value,
                      onRetry: controller.loadMoreShipments,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ─── Header ───────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header({required this.colors});

  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'History',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: colors.textPrimary,
                  letterSpacing: -0.5,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Your completed and failed deliveries',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: colors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        _FilterPills(colors: colors),
        const SizedBox(height: 12),
      ],
    );
  }
}

// ─── Filter pills ─────────────────────────────────────────────────────────────

class _FilterPills extends StatelessWidget {
  const _FilterPills({required this.colors});

  final AppColors colors;

  static const List<(ShipmentStatus?, String)> _filters = [
    (null, 'All'),
    (ShipmentStatus.delivered, 'Delivered'),
    (ShipmentStatus.failed, 'Failed'),
  ];

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HistoryController>();
    return Obx(() {
      final selected = controller.selectedStatus.value;
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: _filters.map((filter) {
            final (status, label) = filter;
            final isSelected = selected == status;
            final activeColor = status?.color ?? colors.brand;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () => controller.setFilter(status),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? activeColor.withValues(alpha: 0.12)
                        : colors.surfaceContainer,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? activeColor : colors.borderSubtle,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isSelected && status != null) ...[
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: activeColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 5),
                      ],
                      Text(
                        label,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color:
                              isSelected ? activeColor : colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      );
    });
  }
}

// ─── Shipment card ────────────────────────────────────────────────────────────

class _ShipmentCard extends StatelessWidget {
  const _ShipmentCard({required this.shipment, required this.colors});

  final Shipment shipment;
  final AppColors colors;

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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status badge + code + icon row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _StatusBadge(status: shipment.status),
                      const SizedBox(height: 8),
                      Text(
                        shipment.code,
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: colors.textPrimary,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ],
                  ),
                ),
                _CardIconButton(status: shipment.status, colors: colors),
              ],
            ),

            const SizedBox(height: 12),

            // Chips row
            _ChipsRow(shipment: shipment, colors: colors),

            const SizedBox(height: 14),

            // Locations sub-card
            _LocationsCard(shipment: shipment, colors: colors),

            const SizedBox(height: 14),

            AppPrimaryButton(
              label: 'View Details',
              icon: Icons.arrow_forward_rounded,
              onTap: () => Get.toNamed(
                AppRoutes.shipmentDetail,
                arguments: shipment,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Status badge ─────────────────────────────────────────────────────────────

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

// ─── Card icon button ─────────────────────────────────────────────────────────

class _CardIconButton extends StatelessWidget {
  const _CardIconButton({required this.status, required this.colors});

  final ShipmentStatus status;
  final AppColors colors;

  IconData get _icon {
    return switch (status) {
      ShipmentStatus.delivered => Icons.check_circle_outline_rounded,
      ShipmentStatus.failed    => Icons.error_outline_rounded,
      ShipmentStatus.cancelled => Icons.cancel_outlined,
      _                        => Icons.inventory_2_outlined,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: colors.surfaceContainer,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colors.borderSubtle),
      ),
      child: Icon(_icon, size: 18, color: colors.textCaption),
    );
  }
}

// ─── Chips row ────────────────────────────────────────────────────────────────

class _ChipsRow extends StatelessWidget {
  const _ChipsRow({required this.shipment, required this.colors});

  final Shipment shipment;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _Chip(
          icon: Icons.scale_outlined,
          label:
              '${shipment.weightKg % 1 == 0 ? shipment.weightKg.toInt() : shipment.weightKg} KG',
          colors: colors,
        ),
        if (shipment.dimensions.isNotEmpty)
          _Chip(
            icon: Icons.straighten_outlined,
            label: shipment.dimensions,
            colors: colors,
          ),
        if (shipment.items != null && shipment.items!.isNotEmpty)
          _Chip(
            icon: Icons.inventory_2_outlined,
            label:
                '${shipment.items!.length} ${shipment.items!.length == 1 ? 'item' : 'items'}',
            colors: colors,
          ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.icon, required this.label, required this.colors});

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

// ─── Locations sub-card ───────────────────────────────────────────────────────

class _LocationsCard extends StatelessWidget {
  const _LocationsCard({required this.shipment, required this.colors});

  final Shipment shipment;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: colors.surfaceContainer,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colors.borderSubtle),
      ),
      child: Column(
        children: [
          _LocationRow(
            label: 'PICKUP',
            rawAddress: shipment.startAddress,
            dotColor: const Color(0xFFEA4335),
            colors: colors,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 6),
            child: Column(
              children: List.generate(
                3,
                (_) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Container(
                    width: 1.5,
                    height: 4,
                    color: colors.divider,
                  ),
                ),
              ),
            ),
          ),
          _LocationRow(
            label: 'DROP-OFF',
            rawAddress: shipment.endAddress,
            dotColor: const Color(0xFF4285F4),
            colors: colors,
          ),
        ],
      ),
    );
  }
}

class _LocationRow extends StatelessWidget {
  const _LocationRow({
    required this.label,
    required this.rawAddress,
    required this.dotColor,
    required this.colors,
  });

  final String label;
  final String rawAddress;
  final Color dotColor;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HistoryController>();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: dotColor.withValues(alpha: 0.15),
              shape: BoxShape.circle,
              border: Border.all(color: dotColor, width: 2),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: colors.textCaption,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                controller.displayAddress(rawAddress),
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: colors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Empty state ──────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.colors});

  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Header(colors: colors),
        Padding(
          padding: const EdgeInsets.fromLTRB(32, 48, 32, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: colors.surfaceContainer,
                  shape: BoxShape.circle,
                  border: Border.all(color: colors.borderSubtle),
                ),
                child: Icon(
                  Icons.history_rounded,
                  size: 32,
                  color: colors.iconSubtle,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'No history yet',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: colors.textPrimary,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Completed and failed deliveries will appear here.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: colors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Error state ──────────────────────────────────────────────────────────────

class _ErrorState extends StatelessWidget {
  const _ErrorState({
    required this.message,
    required this.colors,
    required this.onRetry,
  });

  final String message;
  final AppColors colors;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.wifi_off_rounded, size: 40, color: colors.iconSubtle),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: colors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: onRetry,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: colors.brand,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'RETRY',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Pagination footer ────────────────────────────────────────────────────────

class _PaginationFooter extends StatelessWidget {
  const _PaginationFooter({
    required this.colors,
    required this.isLoadingMore,
    required this.hasMore,
    required this.errorMessage,
    required this.onRetry,
  });

  final AppColors colors;
  final bool isLoadingMore;
  final bool hasMore;
  final String errorMessage;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    if (isLoadingMore) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 110),
        child: Center(
          child: SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2.4,
              color: colors.brand,
            ),
          ),
        ),
      );
    }

    if (errorMessage.isNotEmpty) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 110),
        child: Center(
          child: GestureDetector(
            onTap: onRetry,
            child: Text(
              'Retry loading more',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: colors.textLink,
                decoration: TextDecoration.underline,
                decorationColor: colors.textLink,
              ),
            ),
          ),
        ),
      );
    }

    if (hasMore) {
      return const SizedBox(height: 110);
    }

    return const SizedBox(height: 100);
  }
}
