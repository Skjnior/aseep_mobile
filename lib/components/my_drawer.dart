import 'dart:math';

import 'package:aseep/screens/filiere/create_filiere_screen.dart';
import 'package:aseep/screens/notifications_screen.dart';
import 'package:aseep/screens/profile_screen.dart';
import 'package:aseep/screens/settings_screen.dart';
import 'package:aseep/services/auth/auth_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../screens/grande_salle.dart';
import '../screens/my_Profile.dart';

class MyDrawer extends StatefulWidget {
  const MyDrawer({super.key, required String userName, required String userEmail, required String userImage});

  @override
  State<MyDrawer> createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> {
  String userName = 'Aucun';
  String userEmail = 'Aucun';
  String userImage = 'Aucun';
  String lastName = 'Aucun';
  String firstName = 'Aucun';

  // Charger les données de l'utilisateur depuis les SharedPreferences
  Future<void> loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString('userName') ?? 'Aucun';
      userEmail = prefs.getString('userEmail') ?? 'Aucun';
      userImage = prefs.getString('userImage') ?? 'Aucun';
      lastName = prefs.getString('lastName') ?? 'Aucun';
      firstName = prefs.getString('firstName') ?? 'Aucun';
    });
  }
  static final random = Random();

  // Méthode pour récupérer les données de l'utilisateur courant
  void fetchCurrentUserData() async {
    String currentUserUid = FirebaseAuth.instance.currentUser?.uid ?? '';

    if (currentUserUid.isNotEmpty) {
      FirebaseFirestore.instance
          .collection('Users') // Nom de votre collection
          .where('uid', isEqualTo: currentUserUid) // Filtrer par UID
          .get()
          .then((QuerySnapshot querySnapshot) {
        if (querySnapshot.docs.isNotEmpty) {
          var userDoc = querySnapshot.docs.first;

          // Sauvegarder les données récupérées dans SharedPreferences
          SharedPreferences.getInstance().then((prefs) {
            prefs.setString('firstName', userDoc['firstName'] ?? 'Aucun');
            prefs.setString('lastName', userDoc['lastName'] ?? 'Aucun');
            prefs.setString('userImage', userDoc['profileImageUrl'] ?? 'Aucun');
            prefs.setString('userEmail', userDoc['email'] ?? 'Aucun');
            prefs.setString('userName', '${userDoc['firstName']} ${userDoc['lastName']}');

            // Mettre à jour l'état de l'interface
            loadUserData();
          });
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
    final _auth = AuthService();
    _auth.signOut();
  }

  @override
  void initState() {
    super.initState();
    loadUserData(); // Charger les données locales au démarrage
    fetchCurrentUserData(); // Récupérer les données de l'utilisateur depuis Firestore et les enregistrer localement
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
            // Logo et informations de l'utilisateur
            Column(
              children: [
                DrawerHeader(
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.grey,
                        backgroundImage: userImage.isNotEmpty
                            ? NetworkImage("https://picsum.photos/seed/${random.nextInt(1000)}/300/300")
                            :  NetworkImage("https://picsum.photos/seed/${random.nextInt(1000)}/300/300"),
                            // : const AssetImage('assets/images/ourLogo.jpg') as ImageProvider,
                      ),
                      SizedBox(width: 10),
                      Padding(
                        padding: const EdgeInsets.only(top: 18.0),
                        child: Column(
                          children: [
                            Text(
                              '$firstName $lastName',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.inversePrimary,
                              ),
                            ),
                            Text(
                              userEmail,
                              style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context).colorScheme.inversePrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Home list tile
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
                Padding(
                  padding: EdgeInsets.only(left: 25),
                  child: ListTile(
                    title: Text(
                      "Profile",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.inversePrimary,
                      ),
                    ),
                    leading: Icon(
                      Icons.person,
                      color: Theme.of(context).colorScheme.inversePrimary,
                    ),
                    onTap: () {
                      Get.to(() => MyProfileScreen());
                    },
                  ),
                ),

                // Paramètres list tile
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

                // EPI
                Padding(
                  padding: EdgeInsets.only(left: 25),
                  child: ListTile(
                    title: Text(
                      "Messages EPI ",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.inversePrimary,
                      ),
                    ),
                    leading: Icon(
                     CupertinoIcons.chat_bubble_2_fill,
                      color: Theme.of(context).colorScheme.inversePrimary,
                    ),
                    onTap: () {
                      Get.to(() => AllChat());
                    },
                  ),
                ),
              ],
            ),

            // Deconnexion list tile
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
