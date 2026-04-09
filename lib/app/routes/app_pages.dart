import 'package:get/get.dart';

import '../../modules/auth/login_binding.dart';
import '../../modules/auth/login_view.dart';
import '../../modules/home/home_binding.dart';
import '../../modules/home/home_view.dart';
import '../../modules/home/orders/shipment_detail_view.dart';
import 'app_routes.dart';

/// Maps route names to pages and their bindings.
class AppPages {
  static const initial = AppRoutes.login;

  static final pages = <GetPage>[
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginView(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: AppRoutes.home,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: AppRoutes.shipmentDetail,
      page: () => const ShipmentDetailView(),
    ),
  ];
}
