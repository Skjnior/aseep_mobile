import 'package:aseep/screens/auth/auth_services.dart';
import 'package:aseep/screens/auth/signup_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/get_navigation.dart';

import '../../components/myButton.dart';
import '../../components/myTextField.dart';


class LoginScreen extends StatelessWidget {

  final TextEditingController _emailControler = TextEditingController();
  final TextEditingController _pwControler = TextEditingController();

  /// action to go to register screen
  final void Function()? onTap;


   LoginScreen({super.key, required this.onTap});

   /// Login methode
    void login(BuildContext context) async {
      // Get.off(() => SignupScreen());
      // auth service
      final authservice = AuthService();

      // try to login
      try {
        await authservice.signInWithEmailPasswoord(_emailControler.text, _pwControler.text);
      }

      // catch any errors
      catch (e) {
        showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text(e.toString()),
            ),
        );
      }
    }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                /// Logo ou affiche
                Icon(
                  Icons.lock_clock,
                  size: 60,
                  color: Theme.of(context).colorScheme.primary,
                ),

                const SizedBox(height: 50,),
                /// Message d'acceuil
                Text(
                  "Welcom to how use API in flutter...",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 16,
                  ),
                ),

                const SizedBox(height: 25,),

                /// TextField for email
                MyTextField(
                  controller: _emailControler,
                  obscureText: false,
                  hintext: "Address email",
                  myIcon: Icons.email,
                ),


                const SizedBox(height: 25,),

                /// TextField for password
                MyTextField(
                  controller: _pwControler,
                  obscureText: true,
                  hintext: "Mot de passe",
                  myIcon: Icons.password,
                ),

                const SizedBox(height: 25,),

                /// Login Buttton
                MyButton(
                  text: "Login",
                  onTap: () => login(context),
                ),


                const SizedBox(height: 25,),

                /// Register now
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                        "Vous n\'est pas memebre de l'EPI? ",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                     GestureDetector(
                       onTap: onTap,
                       child: Text(
                          "S'inscrire",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                                           ),
                     )
                  ],
                ),



                /// Reset password
              ],
            ),
          ),
        ],
      ),
    );
  }
}




