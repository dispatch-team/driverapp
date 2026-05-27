import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../constants/app_constants.dart';

class LocaleService extends GetxService {
  static const _defaultLocale = Locale('en', 'US');

  final _box = GetStorage();

  /// Reactive flag — widgets wrapped in [Obx] rebuild when this toggles.
  final isAmharic = false.obs;

  Locale get savedLocale {
    final tag = _box.read<String>(AppConstants.localeKey);
    if (tag == null) return _defaultLocale;
    final parts = tag.split('_');
    return Locale(parts[0], parts.length > 1 ? parts[1] : null);
  }

  @override
  void onInit() {
    super.onInit();
    isAmharic.value = savedLocale.languageCode == 'am';
  }

  void setLocale(Locale locale) {
    _box.write(
      AppConstants.localeKey,
      '${locale.languageCode}_${locale.countryCode}',
    );
    Get.updateLocale(locale);
    isAmharic.value = locale.languageCode == 'am';
  }

  void toggleLocale() {
    setLocale(
      isAmharic.value ? const Locale('en', 'US') : const Locale('am', 'ET'),
    );
  }
}
