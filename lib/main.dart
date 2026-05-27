import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'app/app.dart';
import 'core/services/locale_service.dart';
import 'core/utils/logger.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Must be awaited before LocaleService reads GetStorage.
  await GetStorage.init();

  // Register LocaleService before runApp so App.build() can call
  // Get.find<LocaleService>() synchronously inside GetMaterialApp.
  Get.put<LocaleService>(LocaleService(), permanent: true);

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  Log.i('Firebase initialized');

  runApp(const App());
}
