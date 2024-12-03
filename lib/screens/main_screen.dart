import 'package:aseep/screens/all_user_screen.dart';
import 'package:aseep/screens/chat/chat_screen.dart';
import 'package:aseep/screens/home_screen.dart';
import 'package:aseep/screens/profile_screen.dart';
import 'package:aseep/screens/settings_screen.dart';
import 'package:aseep/screens/test.dart';
import 'package:aseep/services/auth/auth_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

import '../services/chat/chat_services.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  // Les pages correspondantes à chaque icône
  final List<Widget> _pages = [
    HomeScreen(),
    AllUsersScreen(),
    SettingsScreen(),
  ];




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:Theme.of(context).colorScheme.background,
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),

        ),
        padding: const EdgeInsets.all(15),
        child: GNav(
          rippleColor: Theme.of(context).colorScheme.secondary, // Couleur ripple
          hoverColor: Theme.of(context).colorScheme.primary, // Couleur hover
          haptic: true, // Retour haptique
          tabBorderRadius: 15,
          tabActiveBorder: Border.all(color: Theme.of(context).colorScheme.secondary, width: 2), // Bord actif
          tabBorder: Border.all(color: Theme.of(context).colorScheme.secondary, width: 2), // Bord
          tabShadow: [
            BoxShadow(color: Theme.of(context).colorScheme.secondary, blurRadius: 8)
          ], // Ombre
          curve: Curves.easeOutExpo, // Animation des onglets
          duration: const Duration(milliseconds: 900), // Durée animation onglet
          gap: 8, // Espacement entre icône et texte
          activeColor: Colors.white, // Couleur des icônes et texte sélectionnés
          iconSize: 24, // Taille des icônes
          tabBackgroundColor: Theme.of(context).colorScheme.primary, // Couleur fond sélection
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
          tabs: const [
            GButton(
              icon: Icons.home,
              text: 'Home',
              iconColor: Colors.grey,
            ),
            GButton(
              icon: Icons.group,
              text: 'Utilisateurs',
              iconColor: Colors.grey,
            ),
            GButton(
              icon: Icons.settings,
              text: 'Parametres',
              iconColor: Colors.grey,

            ),
          ],
          selectedIndex: _selectedIndex,
          onTabChange: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
        ),
      ),
    );
  }
}