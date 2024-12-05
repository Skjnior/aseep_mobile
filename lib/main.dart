import 'package:aseep/api/firebase_api.dart';
import 'package:aseep/firebase_options.dart';
import 'package:aseep/screens/authScreen/login_screen.dart';
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
import 'package:supabase_flutter/supabase_flutter.dart';

import 'theme/ligth_mode.dart';

final navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  await Supabase.initialize(
    url: 'https://mjkkscgtqxfwuazwxeka.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1qa2tzY2d0cXhmd3Vhend4ZWthIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzMzMDUyMTQsImV4cCI6MjA0ODg4MTIxNH0.6cvpiH6dStvVe9WmbmZe1GrVxqaC6KUFDq8GF5hm81U',
  );
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // await FirebaseApi().initNotifications();

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
     /* routes: {
        '/notification_screen': (context) => const NotificationsScreen(),
      },*/
      theme: Provider.of<ThemeProvider>(context).themeData,
      // home: isFirstLaunch ? const OmbordingScreen() : const AuthGate(),
        home:  AuthGate()
    );
  }
}
