import 'dart:math';
import 'package:aseep/services/chat/chat_services.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aseep/screens/chat/chat_screen.dart';
import '../components/myAppBar.dart';

class UsersProfileScreen extends StatelessWidget {
  final String userEmail;
  final String userFirstName;
  final String userLastName;
  final String userImagePath;
  final String userId;
  final String userBirthDate;
  final String userMatricule;
  final List<String> userNiveaux;

  UsersProfileScreen({
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
  final myUsers  = MyServices().getAllUsers();

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
            const SizedBox(height: 20),

            // Nom complet
            Text(
              "$userFirstName $userLastName",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.inversePrimary
              ),
            ),
            const SizedBox(height: 10),

            // Informations utilisateur sous forme de carte
            Card(
              margin: const EdgeInsets.symmetric(vertical: 10),
              color: Theme.of(context).colorScheme.secondary,
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.email, color: Colors.blueAccent),
                        const SizedBox(width: 10),
                        Text(
                            userEmail,
                            style: TextStyle(
                                fontSize: 16,
                              color: Theme.of(context).colorScheme.inversePrimary
                            )
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(Icons.perm_identity, color: Colors.blueAccent),
                        const SizedBox(width: 10),
                        Text("Name: ${userFirstName +" "+ userLastName}",  style: TextStyle(
                            fontSize: 16,
                            color: Theme.of(context).colorScheme.inversePrimary
                        )
                        ),
                      ],
                    ),
                   /* Row(
                      children: [
                        const Icon(Icons.cake, color: Colors.blueAccent),
                        const SizedBox(width: 10),
                        Text("Date de naissance: $userBirthDate",  style: TextStyle(
                            fontSize: 16,
                            color: Theme.of(context).colorScheme.inversePrimary
                        )),
                      ],
                    ),*/
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(Icons.badge, color: Colors.blueAccent),
                        const SizedBox(width: 10),
                        Text("Matricule: $userMatricule",  style: TextStyle(
                            fontSize: 16,
                            color: Theme.of(context).colorScheme.inversePrimary
                        )),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(Icons.school, color: Colors.blueAccent),
                        const SizedBox(width: 10),
                        Text("Niveaux: ${userNiveaux.isNotEmpty ? userNiveaux.join(', ') : 'Aucun niveau'}",
                            style: TextStyle(
                            fontSize: 16,
                            color: Theme.of(context).colorScheme.inversePrimary
                        )),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 100,),
            // Bouton Echanger
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.secondary,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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
              child:  Text(
                'Echanger',
                style: TextStyle(
                    color: Theme.of(context).colorScheme.inversePrimary
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
