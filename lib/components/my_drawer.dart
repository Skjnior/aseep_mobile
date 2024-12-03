import 'package:aseep/screens/filiere/create_filiere_screen.dart';
import 'package:aseep/screens/notifications_screen.dart';
import 'package:aseep/screens/profile_screen.dart';
import 'package:aseep/screens/settings_screen.dart';
import 'package:aseep/services/auth/auth_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:math' show pi;

class MyDrawer extends StatefulWidget {
  final String userName;
  final String userImage;
  final String userEmail;
  const MyDrawer({
    super.key,
    required this.userEmail,
    required this.userName,
    required this.userImage
  });

  @override
  State<MyDrawer> createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> {


  void fetchCurrentUserData() async {
    // Récupérer le UID de l'utilisateur courant
    String currentUserUid = FirebaseAuth.instance.currentUser?.uid ?? '';

    if (currentUserUid.isNotEmpty) {
      // Effectuer la requête Firestore
      FirebaseFirestore.instance
          .collection('Users') // Nom de votre collection
          .where('uid', isEqualTo: currentUserUid) // Filtrer par UID
          .get()
          .then((QuerySnapshot querySnapshot) {
        if (querySnapshot.docs.isNotEmpty) {
          // Récupérer le premier document correspondant
          var userDoc = querySnapshot.docs.first;

          // Extraire les champs spécifiques
          String lastName = userDoc['lastName'] ?? 'Nom non disponible';
          String firstName = userDoc['firstName'] ?? 'Prénom non disponible';
          String profileImageUrl = userDoc['profileImageUrl'] ?? 'Image non disponible';
          String email = userDoc['email'] ?? 'Email non disponible';

          // Afficher les données récupérées
          print("Nom : $lastName");
          print("Prénom : $firstName");
          print("Email : $email");
          print("Photo de profile : $profileImageUrl");

          // Vous pouvez utiliser ces données comme vous le souhaitez
        } else {
          print("Aucun document trouvé pour cet utilisateur !");
        }
      }).catchError((error) {
        print("Erreur lors de la récupération des données : $error");
      });
    } else {
      print("Aucun utilisateur connecté !");
    }
  }



  void logout() {
    // get auth service
    final _auth = AuthService();
    _auth.signOut();
  }



  @override
  Widget build(BuildContext context) {
    return Container(

      width: 250,
      child: Drawer(
        backgroundColor: Theme.of(context).colorScheme.background,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // logo
         Column(
           children: [
             DrawerHeader(
                 child: Column(
                   children: [
                     CircleAvatar(
                       radius: 40,
                       backgroundColor: Colors.grey,
                       backgroundImage:
                       (widget.userImage.isNotEmpty)
                           ? NetworkImage(widget.userImage) as ImageProvider
                           : const AssetImage('assets/images/ourLogo.jpg'),
                     ),
                     Text(widget.userName, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold,  color: Theme.of(context).colorScheme.inversePrimary,),),
                     Text(widget.userEmail, style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.inversePrimary,  ),),
                   ],
                 ),
             ),



             // home list tile
             Padding(
               padding: EdgeInsets.only(left: 25),
               child: ListTile(
                 title: Text(
                     "Acceuil",
                   style: TextStyle(
                     color: Theme.of(context).colorScheme.inversePrimary,
                   ),
                 ),
                 leading: Icon(
                     Icons.home,
                   color: Theme.of(context).colorScheme.inversePrimary,
                 ),
                 onTap: () {
                   Navigator.pop(context);
                 },
               ),
             ),

             // settings list tile
             Padding(
               padding: EdgeInsets.only(left: 25),
               child: ListTile(
                 title: Text(
                     "Parametres",
                   style: TextStyle(
                     color: Theme.of(context).colorScheme.inversePrimary,
                   ),
                 ),
                 leading: Icon(
                     Icons.settings,
                   color: Theme.of(context).colorScheme.inversePrimary,
                 ),
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
                   Get.to(() => ProfileScreen(
                       userEmail: userEmail,
                       userId: userId,
                       userFirstName: userFirstName,
                       userLastName: userLastName,
                       userImagePath: userImagePath
                   ),
                   );
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
              title: Text(
                  "Deconnexion",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.inversePrimary,
                ),
              ),
              leading: Icon(
                  Icons.logout,
                color: Theme.of(context).colorScheme.inversePrimary,
              ),
              onTap: logout,
            ),
          ),



        ],
        ),
      ),
    );
  }
}
