import 'package:aseep/screens/home_screen.dart';
import 'package:aseep/services/auth/login_or_register.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../screens/main_screen.dart';
import '../../screens/welcom_screen.dart';


class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            // user is logged in
            if(snapshot.hasData) {
              return  MainScreen();
            }
            // user is not logged in
            else {
              return  LoginOrRegister();
            }
          }
      ),
    );
  }
}

