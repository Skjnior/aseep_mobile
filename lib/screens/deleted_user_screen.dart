import 'package:aseep/components/userTile.dart';
import 'package:aseep/services/auth/auth_services.dart';
import 'package:aseep/services/chat/chat_services.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/get_navigation.dart';

import '../components/myAppBar.dart';

class DeletedUserPage extends StatelessWidget {
  DeletedUserPage({super.key});

  // chat && auth services
  final MyServices chatService = MyServices();
  final AuthService authService = AuthService();

  // show confirm undelete box
  void _showUndeleteBox(BuildContext context, String userId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Restaurer l'utilisateur"),
        content: const Text("Êtes-vous sûr de vouloir restaurer cet utilisateur ?"),
        actions: [
          // Cancel button
          TextButton(
            onPressed: () => Get.back(),
            child: const Text("Annuler"),
          ),

          // Undelete button
          TextButton(
            onPressed: () {
              chatService.unDeleteUser(userId);
              Get.back();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Utilisateur restauré avec succès !")),
              );
            },
            child: const Text("Restaurer"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Get current user's ID
    String userId = authService.getCurrentUser()!.uid;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: MyAppBar(text: 'Corbeille',),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: chatService.getDeletedUsersStream(userId),
        builder: (context, snapshot) {
          // Errors
          if (snapshot.hasError) {
            return const Center(
              child: Text("Erreur de chargement..."),
            );
          }

          // Loading...
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final deletedUsers = snapshot.data ?? [];

          // No users
          if (deletedUsers.isEmpty) {
            return  Center(
              child: Text(
                  "Aucun utilisateur supprimé.",
                  style: TextStyle(
              color: Theme.of(context).colorScheme.inversePrimary,
            ),
              ),
            );
          }

          // Load complete
          return ListView.builder(
            itemCount: deletedUsers.length,
            itemBuilder: (context, index) {
              final user = deletedUsers[index];
              return UserTile(
                text: user["email"],
                name: user["lastName"],
                firstName: user["firstName"],
                onTap: () => _showUndeleteBox(
                  context,
                  user['uid'],
                ),
                onTapPro: () => _showUndeleteBox(
                  context,
                  user['uid'],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
