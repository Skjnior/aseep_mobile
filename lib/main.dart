import 'package:aseep/api/firebase_api.dart';
import 'package:aseep/firebase_options.dart';
import 'package:aseep/screens/notifications_screen.dart';
import 'package:aseep/screens/omboardingScreen.dart';
import 'package:aseep/services/auth/auth_gate.dart';
import 'package:aseep/services/filiere_service.dart';
import 'package:aseep/theme/theme_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

import 'theme/ligth_mode.dart';

final navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await FirebaseApi().initNotifications();

  // Vérifier si c'est la première fois que l'utilisateur lance l'application
  final prefs = await SharedPreferences.getInstance();
  final isFirstLaunch = prefs.getBool('isFirstLaunch') ?? true;

  // Si c'est la première fois, définir isFirstLaunch à false
  if (isFirstLaunch) {
    await prefs.setBool('isFirstLaunch', false);
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ChangeNotifierProvider(create: (context) => FiliereService()),
      ],
      child: MyApp(isFirstLaunch: isFirstLaunch),
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool isFirstLaunch;

  const MyApp({super.key, required this.isFirstLaunch});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'ASEEP APP',
      navigatorKey: navigatorKey,
      routes: {
        '/notification_screen': (context) => const NotificationsScreen(),
      },
      theme: Provider.of<ThemeProvider>(context).themeData,
      home: isFirstLaunch ? const OmbordingScreen() : const AuthGate(),
    );
  }
}
