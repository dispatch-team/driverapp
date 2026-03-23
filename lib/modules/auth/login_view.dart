import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_colors.dart';
import 'login_controller.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;

    return Scaffold(
      backgroundColor: colors.scaffold,
      appBar: _DispatchAppBar(colors: colors),
      body: Stack(
        children: [
          // Decorative dot-grid background pattern (right edge, visual only)
          Positioned(
            right: 0,
            top: 0,
            child: Opacity(
              opacity: colors.patternOpacity,
              child: _BackgroundPattern(
                color: colors.textCaption,
                height: 884,
              ),
            ),
          ),

          // Scrollable content
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Main form area
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 46.75, 16, 78.75),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 448),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _BrandingArea(colors: colors),
                          const SizedBox(height: 32),
                          _LoginForm(
                            controller: controller,
                            colors: colors,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Footer
                _FooterBlade(colors: colors),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── App Bar ──────────────────────────────────────────────────────────────────

class _DispatchAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _DispatchAppBar({required this.colors});

  final AppColors colors;

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: 64,
      // When blurring, the AppBar background must be transparent so the
      // BackdropFilter in flexibleSpace can render behind the toolbar.
      backgroundColor:
          colors.navBlur ? Colors.transparent : colors.navBackground,
      elevation: 0,
      scrolledUnderElevation: 0,
      automaticallyImplyLeading: false,
      flexibleSpace: colors.navBlur
          ? ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                child: Container(
                  decoration: BoxDecoration(
                    color: colors.navBackground,
                    border: Border(
                      bottom: BorderSide(color: colors.navBorderColor),
                    ),
                  ),
                ),
              ),
            )
          : null,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.local_shipping_outlined, color: colors.brand, size: 20),
          const SizedBox(width: 12),
          Text(
            'DISPATCH',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: colors.brand,
              letterSpacing: -1.2,
            ),
          ),
        ],
      ),
      titleSpacing: 24,
    );
  }
}

// ─── Branding Area ────────────────────────────────────────────────────────────

class _BrandingArea extends StatelessWidget {
  const _BrandingArea({required this.colors});

  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'DRIVER\nLOGIN',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 48,
            fontWeight: FontWeight.w700,
            color: colors.textPrimary,
            height: 1.25,
            letterSpacing: -2.4,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: 280,
          child: Text(
            'Enter your credentials to begin\nyour delivery patrol.',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: colors.textSecondary,
              height: 1.556,
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Login Form ───────────────────────────────────────────────────────────────

class _LoginForm extends StatelessWidget {
  const _LoginForm({
    required this.controller,
    required this.colors,
  });

  final LoginController controller;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Bento-style double-container card
        Container(
          decoration: BoxDecoration(
            color: colors.surfaceContainer,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: colors.borderSubtle),
          ),
          padding: const EdgeInsets.all(4),
          child: Container(
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(6),
            ),
            padding: const EdgeInsets.all(24),
            child: AutofillGroup(
              child: Column(
                children: [
                  _InputField(
                    label: 'USERNAME OR EMAIL',
                    placeholder: 'Enter username or email',
                    prefixIcon: Icons.person_outline,
                    controller: controller.usernameController,
                    colors: colors,
                    autofillHints: const [
                      AutofillHints.username,
                      AutofillHints.email,
                    ],
                  ),
                  const SizedBox(height: 24),
                  Obx(
                    () => _InputField(
                      label: 'ACCESS KEY',
                      placeholder: '••••••••',
                      prefixIcon: Icons.lock_outline,
                      controller: controller.passwordController,
                      colors: colors,
                      isPassword: true,
                      isPasswordVisible: controller.isPasswordVisible.value,
                      onToggleVisibility: controller.togglePasswordVisibility,
                      autofillHints: const [AutofillHints.password],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Primary CTA button
        Obx(
          () => _LoginButton(
            colors: colors,
            isLoading: controller.isLoading.value,
            onPressed: () {
              TextInput.finishAutofillContext();
              controller.login();
            },
          ),
        ),
      ],
    );
  }
}

// ─── Input Field ──────────────────────────────────────────────────────────────

class _InputField extends StatelessWidget {
  const _InputField({
    required this.label,
    required this.placeholder,
    required this.prefixIcon,
    required this.controller,
    required this.colors,
    this.isPassword = false,
    this.isPasswordVisible = false,
    this.onToggleVisibility,
    this.autofillHints,
  });

  final String label;
  final String placeholder;
  final IconData prefixIcon;
  final TextEditingController controller;
  final AppColors colors;
  final bool isPassword;
  final bool isPasswordVisible;
  final VoidCallback? onToggleVisibility;
  final List<String>? autofillHints;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: colors.textCaption,
                letterSpacing: 1.2,
              ),
            ),
            if (isPassword)
              GestureDetector(
                onTap: () {
                  // TODO: navigate to forgot password screen
                },
                child: Text(
                  'FORGOT?',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: colors.textLink,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8.5),

        // Input container
        Container(
          decoration: BoxDecoration(
            color: colors.inputFill,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: colors.borderSubtle),
          ),
          child: TextField(
            controller: controller,
            obscureText: isPassword && !isPasswordVisible,
            autofillHints: autofillHints,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: colors.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: placeholder,
              hintStyle: GoogleFonts.spaceGrotesk(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: colors.textHint,
              ),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              filled: false,
              prefixIcon: Padding(
                padding: const EdgeInsets.only(left: 16, right: 12),
                child: Icon(prefixIcon, size: 18, color: colors.iconSubtle),
              ),
              prefixIconConstraints: const BoxConstraints(minWidth: 48),
              suffixIcon: isPassword
                  ? GestureDetector(
                      onTap: onToggleVisibility,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 16),
                        child: Icon(
                          isPasswordVisible
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          size: 20,
                          color: colors.iconSubtle,
                        ),
                      ),
                    )
                  : null,
              suffixIconConstraints: const BoxConstraints(minWidth: 48),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 0,
                vertical: 18,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Login Button ─────────────────────────────────────────────────────────────

class _LoginButton extends StatelessWidget {
  const _LoginButton({
    required this.colors,
    required this.isLoading,
    required this.onPressed,
  });

  final AppColors colors;
  final bool isLoading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onPressed,
      child: Container(
        height: 64,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [colors.brand, colors.brandDim],
          ),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [colors.buttonShadow],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isLoading)
              const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            else ...[
              Text(
                'LOGIN',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(width: 12),
              const Icon(Icons.arrow_forward, color: Colors.white, size: 18),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── Footer Blade ─────────────────────────────────────────────────────────────

class _FooterBlade extends StatelessWidget {
  const _FooterBlade({required this.colors});

  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: colors.surfaceContainer,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
        ),
        border: Border(
          top: BorderSide(color: colors.borderSubtle),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 48),
      child: Center(
        child: Text(
          'DISPATCH - SECURE LOGIN',
          style: GoogleFonts.inter(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: colors.textCaption,
            letterSpacing: 2,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

// ─── Background Pattern ───────────────────────────────────────────────────────

class _BackgroundPattern extends StatelessWidget {
  const _BackgroundPattern({required this.color, required this.height});

  final Color color;
  final double height;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(195, height),
      painter: _DotGridPainter(color: color),
    );
  }
}

class _DotGridPainter extends CustomPainter {
  const _DotGridPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    const spacing = 24.0;

    for (double y = 0; y < size.height; y += spacing) {
      for (double x = 0; x < size.width; x += spacing) {
        canvas.drawCircle(Offset(x, y), 1.5, paint);
      }
    }
  }

  @override
  bool shouldRepaint(_DotGridPainter oldDelegate) =>
      oldDelegate.color != color;
}
