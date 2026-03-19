import 'dart:developer' as dev;

import 'package:flutter/foundation.dart';

/// Lightweight logging utility. Only prints in debug mode.
class Log {
  Log._();

  static void d(String message, {String tag = 'APP'}) {
    if (kDebugMode) {
      dev.log('💬 $message', name: tag);
    }
  }

  static void e(String message, {String tag = 'APP', Object? error}) {
    if (kDebugMode) {
      dev.log('❌ $message', name: tag, error: error);
    }
  }

  static void w(String message, {String tag = 'APP'}) {
    if (kDebugMode) {
      dev.log('⚠️ $message', name: tag);
    }
  }

  static void i(String message, {String tag = 'APP'}) {
    if (kDebugMode) {
      dev.log('ℹ️ $message', name: tag);
    }
  }
}
