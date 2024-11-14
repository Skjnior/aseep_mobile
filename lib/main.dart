import 'package:aseep/firebase_options.dart';
import 'package:aseep/screens/auth/auth_gate.dart';
import 'package:aseep/screens/auth/login_or_register.dart';
import 'package:aseep/screens/auth/signup_screen.dart';
import 'package:aseep/screens/omboardingScreen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';

import 'ligth_mode.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'ASEEP APP',
      navigatorKey: Get.key,
      theme: lightMode,
      home: AuthGate(),
    );
  }
}
