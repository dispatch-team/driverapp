import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_colors.dart';
import '../profile/profile_view.dart';
import 'home_controller.dart';
import 'orders/orders_view.dart';

// ─── Tab definitions ──────────────────────────────────────────────────────────

class _TabItem {
  const _TabItem({
    required this.label,
    required this.icon,
    required this.activeIcon,
  });

  final String label;
  final IconData icon;
  final IconData activeIcon;
}

const _tabs = [
  _TabItem(
    label: 'ORDERS',
    icon: Icons.delivery_dining_outlined,
    activeIcon: Icons.delivery_dining,
  ),
  // _TabItem(
  //   label: 'EARNINGS',
  //   icon: Icons.account_balance_wallet_outlined,
  //   activeIcon: Icons.account_balance_wallet,
  // ),
  _TabItem(
    label: 'PROFILE',
    icon: Icons.person_outline_rounded,
    activeIcon: Icons.person_rounded,
  ),
];

// ─── Shell ────────────────────────────────────────────────────────────────────

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;

    SystemChrome.setSystemUIOverlayStyle(
      colors.scaffold.computeLuminance() > 0.5
          ? SystemUiOverlayStyle.dark
          : SystemUiOverlayStyle.light,
    );

    return Scaffold(
      backgroundColor: colors.scaffold,
      extendBody: true,
      body: Obx(
        () => IndexedStack(
          index: controller.currentIndex.value,
          children: const [OrdersView(), /*_EarningsPage(),*/ ProfileView()],
        ),
      ),
      bottomNavigationBar: Obx(
        () => _BottomNavBar(
          currentIndex: controller.currentIndex.value,
          onTap: controller.changePage,
          colors: colors,
        ),
      ),
    );
  }
}

// ─── Bottom navigation bar ────────────────────────────────────────────────────

class _BottomNavBar extends StatelessWidget {
  const _BottomNavBar({
    required this.currentIndex,
    required this.onTap,
    required this.colors,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    final bar = Container(
      decoration: BoxDecoration(
        color: colors.navBackground,
        border: Border(top: BorderSide(color: colors.navBorderColor, width: 1)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 68,
          child: Row(
            children: List.generate(
              _tabs.length,
              (i) => Expanded(
                child: _NavItem(
                  tab: _tabs[i],
                  isActive: i == currentIndex,
                  onTap: () => onTap(i),
                  colors: colors,
                ),
              ),
            ),
          ),
        ),
      ),
    );

    if (!colors.navBlur) return bar;

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: bar,
      ),
    );
  }
}

// ─── Individual nav item ──────────────────────────────────────────────────────

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.tab,
    required this.isActive,
    required this.onTap,
    required this.colors,
  });

  final _TabItem tab;
  final bool isActive;
  final VoidCallback onTap;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    final iconColor = isActive ? colors.brand : colors.iconSubtle;
    final labelColor = isActive ? colors.brand : colors.textCaption;

    // Active card: brand at ~15% opacity — looks warm/orange-tinted in dark,
    // soft warm fill in light.
    final activeCardColor = colors.brand.withValues(alpha: 0.15);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? activeCardColor : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 150),
              child: Icon(
                isActive ? tab.activeIcon : tab.icon,
                key: ValueKey(isActive),
                size: 22,
                color: iconColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              tab.label,
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w600,
                color: labelColor,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Placeholder pages ────────────────────────────────────────────────────────

// class _PlaceholderPage extends StatelessWidget {
//   const _PlaceholderPage({required this.title});
//
//   final String title;
//
//   @override
//   Widget build(BuildContext context) {
//     final colors = Theme.of(context).extension<AppColors>()!;
//
//     return SafeArea(
//       child: Center(
//         child: Text(
//           title,
//           style: GoogleFonts.spaceGrotesk(
//             fontSize: 28,
//             fontWeight: FontWeight.w700,
//             color: colors.textPrimary,
//             letterSpacing: -1,
//           ),
//         ),
//       ),
//     );
//   }
// }

// class _EarningsPage extends StatelessWidget {
//   const _EarningsPage();
//
//   @override
//   Widget build(BuildContext context) =>
//       const _PlaceholderPage(title: 'Earnings');
// }
