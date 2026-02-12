import 'package:ezpark/bindings/initial_binding.dart';
import 'package:ezpark/routes/app_pages.dart';
import 'package:ezpark/routes/app_routes.dart';
import 'package:ezpark/theme/app_theme.dart';
// import 'package:ezpark/utils/firestore_seeder.dart';
import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:google_sign_in/google_sign_in.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await GoogleSignIn.instance.initialize();
  //  await FirestoreSeeder.seedDemoParkingArea();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title:"EZPark",
      debugShowCheckedModeBanner: false,
      enableLog: true,
      initialBinding: InitialBinding(),
      getPages: AppPages.pages,

      // Start at login — AuthController will redirect instantly if already logged in
      initialRoute: AppRoutes.login,

      defaultTransition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
      theme: AppTheme.light(),
    );
  }
}
