import 'package:aseep/components/myButton.dart';
import 'package:aseep/screens/auth/auth_services.dart';
import 'package:aseep/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/get_navigation.dart';

import '../../components/myTextField.dart';


class SignupScreen extends StatelessWidget {

  final TextEditingController _emailControler = TextEditingController();
  final TextEditingController _pwControler = TextEditingController();
  final TextEditingController _confirmPwControler = TextEditingController();

  /// action to go to login screen
  final void Function()? onTap;

   SignupScreen({super.key, required this.onTap});

  /// Login methode
  void singup(BuildContext context) {
    // Get.off(() => HomeScreen());
    // get auth service
    final _auth = AuthService();
    // password match -> create user
   if(_pwControler.text == _confirmPwControler.text) {
     try {
       _auth.signUpWithEmailAndPassword(
           _emailControler.text,
           _pwControler.text
       );
     } catch (e) {
       showDialog(
         context: context,
         builder: (context) => AlertDialog(
           title: Text(e.toString()),
         ),
       );
     }
   }

   // password dont match -> tell user to fix
    else {
     showDialog(
       context: context,
       builder: (context) => const AlertDialog(
         title: Text("Mot de passe correspond pas!"),
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
                  Icons.person,
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

                /// TextField for password
                MyTextField(
                  controller: _confirmPwControler,
                  obscureText: true,
                  hintext: "Confirmer mot de passe",
                  myIcon: Icons.confirmation_num,
                ),

                const SizedBox(height: 25,),

                /// Login Buttton
                MyButton(
                  text: "S'inscrire",
                  onTap: () => singup(context),
                ),


                const SizedBox(height: 25,),

                /// Register now
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Vous etes memebre de l'EPI? ",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    GestureDetector(
                      onTap: onTap,
                      child: Text(
                        "Se connecter",
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
