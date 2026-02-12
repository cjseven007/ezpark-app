import 'package:ezpark/routes/app_routes.dart';
import 'package:ezpark/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthController extends GetxController {
  final AuthService _authService;
  AuthController(this._authService);

  final Rxn<User> user = Rxn<User>();
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();

    _authService.authStateChanges().listen((u) {
      user.value = u;
      if (u == null) {
        Get.offAllNamed(AppRoutes.login);
      } else {
        Get.offAllNamed(AppRoutes.landing);
      }
    });
  }

  Future<void> loginWithGoogle() async {
    try {
      isLoading.value = true;
      await _authService.signInWithGoogle();
    } on GoogleSignInException catch (e) {
      // Common: canceled
      Get.snackbar('Login failed', '${e.code}: ${e.description ?? ''}');
    } catch (e) {
      Get.snackbar('Login failed', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    try {
      isLoading.value = true;
      await _authService.signOut();
    } finally {
      isLoading.value = false;
    }
  }
}
