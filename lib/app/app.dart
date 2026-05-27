import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../core/constants/app_constants.dart';
import '../core/localization/app_translations.dart';
import '../core/services/locale_service.dart';
import '../core/theme/app_theme.dart';
import 'bindings/app_binding.dart';
import 'routes/app_pages.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    // AppBinding.dependencies() runs before build, so LocaleService is ready.
    final localeService = Get.find<LocaleService>();

    return GetMaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      translations: AppTranslations(),
      locale: localeService.savedLocale,
      fallbackLocale: const Locale('en', 'US'),
      initialBinding: AppBinding(),
      initialRoute: AppPages.initial,
      getPages: AppPages.pages,
      defaultTransition: Transition.fadeIn,
    );
  }
}
