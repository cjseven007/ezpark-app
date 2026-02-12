import 'package:ezpark/controllers/auth_controller.dart';
import 'package:ezpark/services/auth_service.dart';
import 'package:get/get.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<AuthService>(AuthService(), permanent: true);
    Get.put<AuthController>(
      AuthController(Get.find<AuthService>()),
      permanent: true,
    );
  }
}
