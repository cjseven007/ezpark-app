import 'package:ezpark/routes/app_routes.dart';
import 'package:ezpark/views/pages/landing_page.dart';
import 'package:ezpark/views/pages/login_page.dart';
import 'package:get/get.dart';

class AppPages {
  static final pages = [
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginPage(),
    ),
    GetPage(
      name: AppRoutes.landing,
      page: () => LandingPage(),
    ),
  ];
}
