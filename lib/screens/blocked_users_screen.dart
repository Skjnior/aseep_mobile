import 'package:aseep/components/userTile.dart';
import 'package:aseep/services/auth/auth_services.dart';
import 'package:aseep/services/chat/chat_services.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/get_navigation.dart';

class BlockedUserPage extends StatelessWidget {
   BlockedUserPage({super.key});

   // chat && auth services
   final MyServices chatService = MyServices();
   final AuthService authService = AuthService();

   // show confirm unblock box
   void _showUnblockBox(BuildContext context, String userId) {
     showDialog(
         context: context,
         builder: (context) => AlertDialog(
           title: const Text("Debloquer l'utilisateur"),
           content: const Text("Etes vous sure de vouloir debloquer cet utilisateur"),
           actions: [
             // cancel button
             TextButton(
                 onPressed: () => Get.back(),
                 child: Text("Annuler")
             ),

             // unblock button
             TextButton(
                 onPressed: () {
                   chatService.unblockUser(userId);
                   Get.back();
                   ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Utilisateur debloquer avec succes!"),
                   ),
                   );
                 },
                 child: Text("Debloquer")
             ),
           ],
         )
     );
   }


  @override
  Widget build(BuildContext context) {
    // get current users id
    String userId = authService.getCurrentUser()!.uid;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Utilisateurs bloques"),
        actions: [],
      ),

      body: StreamBuilder<List<Map<String, dynamic>>>(
          stream: chatService.getBlockedUsersStream(userId),
          builder: (context, snapshot) {
            // errors
            if(snapshot.hasError) {
              return const Center(
                child: Text("Erreur de chargement..."),
              );
            }

            // loading..
            if(snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            final blockedUses = snapshot.data ?? [];

            // no users
            if(blockedUses.isEmpty) {
              return const Center(
                child: Text("Aucun utilisateurs bloquer"),
              );
            }


            // load complete
            return ListView.builder(
              itemCount: blockedUses.length,
                itemBuilder: (context, index) {
                  final user = blockedUses[index];
                  return UserTile(
                    text: user["email"],
                    name: user["lastName"],
                    firstName: user["firstName"],
                    onTap: () => _showUnblockBox(context,
                        user['uid']
                    ),
                    onTapPro:  () => _showUnblockBox(context,
                        user['uid']
                    ),
                  );
                }
            );


          }
      ),
    );
  }
}
