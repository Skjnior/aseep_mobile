import 'package:aseep/screens/filiere/create_filiere_screen.dart';
import 'package:aseep/screens/notifications_screen.dart';
import 'package:aseep/screens/settings_screen.dart';
import 'package:aseep/services/auth/auth_services.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  void logout() {
    // get auth service
    final _auth = AuthService();
    _auth.signOut();
  }



  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // logo
       Column(
         children: [
           DrawerHeader(
               child: Center(
                 child: Icon(
                   Icons.message,
                   color: Theme.of(context).colorScheme.primary,
                   size: 40,
                 ),
               )
           ),


           // home list tile
           Padding(
             padding: EdgeInsets.only(left: 25),
             child: ListTile(
               title: Text("H O M E"),
               leading: Icon(Icons.home),
               onTap: () {
                 Navigator.pop(context);
               },
             ),
           ),

           // settings list tile
           Padding(
             padding: EdgeInsets.only(left: 25),
             child: ListTile(
               title: Text("S E T T I N G S"),
               leading: Icon(Icons.settings),
               onTap: () {
                 Get.to(() => SettingsScreen());
               },
             ),
           ),

        /*  Padding(
             padding: EdgeInsets.only(left: 25),
             child: ListTile(
               title: Text("F I L I E R E S"),
               leading: Icon(Icons.home_work_outlined),
               onTap: () {
                 Get.to(() => CreateFilierePage());
               },
             ),
           ),*/


           // notifications list tile
           /*Padding(
             padding: EdgeInsets.only(left: 25),
             child: ListTile(
               title: Text("N O T I F I C A T I O N S"),
               leading: Icon(Icons.settings),
               onTap: () {
                 Get.to(() => NotificationsScreen());
               },
             ),
           ),
*/

         ],
       ),

        // logout list tile
        Padding(
          padding: EdgeInsets.only(left: 25),
          child: ListTile(
            title: Text("L O G O U T"),
            leading: Icon(Icons.logout),
            onTap: logout,
          ),
        ),



      ],
      ),
    );
  }
}
