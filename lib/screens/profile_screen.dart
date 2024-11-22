import 'package:aseep/services/chat/chat_services.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:aseep/screens/chat/chat_screen.dart';

class ProfileScreen extends StatelessWidget {
  final String userEmail;
  final String userFirstName;
  final String userLastName;
  final String userImagePath;
  final String userId;

  ProfileScreen({
    super.key,
    required this.userEmail,
    required this.userId,
    required this.userFirstName,
    required this.userLastName,
    required this.userImagePath
  });

  final MyServices _chatService = MyServices();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Profil de $userEmail"),
      ),

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Email: $userEmail", style: TextStyle(fontSize: 18)),
            Text("ID: $userId", style: TextStyle(fontSize: 18)),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                // Vérifiez si l'utilisateur existe dans la base de données
                bool userExists = await _chatService.checkIfUserExists(userEmail);

                if (userExists) {
                  // Ouvrir la discussion avec cet utilisateur
                  Get.to(() => ChatScreen(receiverEmail: userEmail, receiverID: userId,  receiverFirstName: userFirstName, receiverLastName: userLastName, receiverImagePath: userImagePath,));
                } else {
                  // Envoyer l'invitation par email
                  // Remarquez que vous pouvez utiliser un service pour envoyer l'email comme montré précédemment
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Invitation envoyée à $userEmail")));
                }
              },
              child: Text("Ajouter aux contacts"),
            ),
          ],
        ),
      ),
    );
  }
}
