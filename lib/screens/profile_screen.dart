import 'dart:math';
import 'package:aseep/services/chat/chat_services.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aseep/screens/chat/chat_screen.dart';
import '../components/myAppBar.dart';

class ProfileScreen extends StatelessWidget {
  final String userEmail;
  final String userFirstName;
  final String userLastName;
  final String userImagePath;
  final String userId;
  final String userBirthDate;
  final String userMatricule;
  final List<String> userNiveaux;

  ProfileScreen({
    super.key,
    required this.userEmail,
    required this.userId,
    required this.userFirstName,
    required this.userLastName,
    required this.userImagePath,
    required this.userBirthDate,
    required this.userMatricule,
    required this.userNiveaux,
  });

  final MyServices _chatService = MyServices();
  static final random = Random();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: MyAppBar(
        text: 'Profil',
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Image de profil
            CircleAvatar(
              radius: 60,
              backgroundImage: NetworkImage(userImagePath),
              onBackgroundImageError: (_, __) => Icon(
                Icons.person,
                size: 60,
                color: Colors.grey.shade400,
              ),
            ),
            SizedBox(height: 20),

            // Nom complet
            Text(
              "$userFirstName $userLastName",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),

            // Informations utilisateur sous forme de carte
            Card(
              margin: EdgeInsets.symmetric(vertical: 10),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.email, color: Colors.blueAccent),
                        SizedBox(width: 10),
                        Text(userEmail, style: TextStyle(fontSize: 16)),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(Icons.perm_identity, color: Colors.blueAccent),
                        SizedBox(width: 10),
                        Text("ID: $userId", style: TextStyle(fontSize: 16)),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(Icons.cake, color: Colors.blueAccent),
                        SizedBox(width: 10),
                        Text("Date de naissance: $userBirthDate", style: TextStyle(fontSize: 16)),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(Icons.badge, color: Colors.blueAccent),
                        SizedBox(width: 10),
                        Text("Matricule: $userMatricule", style: TextStyle(fontSize: 16)),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(Icons.school, color: Colors.blueAccent),
                        SizedBox(width: 10),
                        Text("Niveaux: ${userNiveaux.join(', ')}", style: TextStyle(fontSize: 16)),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            Spacer(),

            // Bouton Echanger
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () async {
                bool userExists = await _chatService.checkIfUserExists(userEmail);
                if (userExists) {
                  Get.to(() => ChatScreen(
                    receiverEmail: userEmail,
                    receiverID: userId,
                    receiverFirstName: userFirstName,
                    receiverLastName: userLastName,
                    receiverImagePath: userImagePath,
                  ));
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Invitation envoyée à $userEmail")),
                  );
                }
              },
              child: Text(
                'Echanger',
                style: TextStyle(color: Colors.black),
              ),
            ),

            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
