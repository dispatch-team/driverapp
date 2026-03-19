import 'package:get/get.dart';

import '../../modules/home/home_binding.dart';
import '../../modules/home/home_view.dart';
import 'app_routes.dart';

/// Maps route names to pages and their bindings.
class AppPages {
  static const initial = AppRoutes.home;

  static final pages = <GetPage>[
    GetPage(
      name: AppRoutes.home,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
  ];
}
