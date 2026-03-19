import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../core/constants/app_constants.dart';
import '../core/theme/app_theme.dart';
import 'bindings/app_binding.dart';
import 'routes/app_pages.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      initialBinding: AppBinding(),
      initialRoute: AppPages.initial,
      getPages: AppPages.pages,
      defaultTransition: Transition.fadeIn,
    );
  }
}
