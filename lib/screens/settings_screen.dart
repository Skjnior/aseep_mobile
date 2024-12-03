import 'package:aseep/screens/blocked_users_screen.dart';
import 'package:aseep/screens/deleted_user_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/route_manager.dart';
import 'package:provider/provider.dart';

import '../components/myAppBar.dart';
import '../theme/theme_provider.dart';


class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: MyAppBar(text: 'Parametres',),


      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
            children: [
              // dark mode
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondary,
                  borderRadius: BorderRadius.circular(10),
                ),
                margin: EdgeInsets.only(left: 25, top: 10, right: 25),
                padding: EdgeInsets.only(left: 25, right: 25, top: 20, bottom: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    /// dark mode
                    Text(
                        "Mode sombre",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.inversePrimary,              ),
                    ),

                    /// Switch toggle
                    CupertinoSwitch(
                      thumbColor: Theme.of(context).colorScheme.inversePrimary,
                        value: Provider.of<ThemeProvider>(context, listen: false).isDarkMode,
                        onChanged: (value) => Provider.of<ThemeProvider>(context, listen: false).toggleTheme()
                    ),


                  ],
                ),
              ),

              // Les utilisateurs bloquer
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondary,
                  borderRadius: BorderRadius.circular(10),
                ),
                margin: EdgeInsets.only(left: 25, top: 10, right: 25),
                padding: EdgeInsets.only(left: 25, right: 25, top: 20, bottom: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    /// dark mode
                    Text(
                      "Utilisateurs bloques",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.inversePrimary,              ),
                    ),

                    /// Button to go to blocked user page
                    IconButton(
                        onPressed: () => Get.to(() => BlockedUserPage()),
                        icon: Icon(
                          CupertinoIcons.forward,
                          color: Theme.of(context).colorScheme.inversePrimary,
                        )
                    ),



                  ],
                ),
              ),

              // Les utilisateurs supprimer
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondary,
                  borderRadius: BorderRadius.circular(10),
                ),
                margin: EdgeInsets.only(left: 25, top: 10, right: 25),
                padding: EdgeInsets.only(left: 25, right: 25, top: 20, bottom: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [

                    /// dark mode
                    Text(
                      "Corbeille",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.inversePrimary,              ),
                    ),

                    /// Button to go to blocked user page
                    IconButton(
                        onPressed: () => Get.to(() => DeletedUserPage()),
                        icon: Icon(
                          CupertinoIcons.forward,
                          color: Theme.of(context).colorScheme.inversePrimary,
                        )
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
