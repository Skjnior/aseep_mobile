
import 'package:aseep/screens/authScreen/login_screen.dart';
import 'package:aseep/screens/authScreen/signup_screen.dart';
import 'package:flutter/material.dart';

class LoginOrRegister extends StatefulWidget {
  const LoginOrRegister({super.key});

  @override
  State<LoginOrRegister> createState() => _LoginOrRegisterState();
}

class _LoginOrRegisterState extends State<LoginOrRegister> {

  /// login screen is the initial page
  bool showLoginPage = true;

  /// Methode to change the page
  void togglePages() {
    setState(() {
      showLoginPage = !showLoginPage;
    });
  }

  @override
  Widget build(BuildContext context) {
     if (showLoginPage) {
      return LoginScreen(
        onTap: togglePages,
      );
    }
     else {
       return SignupScreen(
         onTap: togglePages,
       );
     }
  }
}
