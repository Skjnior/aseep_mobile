import 'package:aseep/components/userTile.dart';
import 'package:aseep/services/auth/auth_services.dart';
import 'package:aseep/services/chat/chat_services.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/get_navigation.dart';

import '../components/myAppBar.dart';

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
                 child: Text("Annuler", style: TextStyle(
                     fontSize: 15.0,
                     fontWeight: FontWeight.normal,
                     color: Theme.of(context).colorScheme.background
                 ),)
             ),

             // unblock button
             TextButton(
                 onPressed: () {
                   chatService.unblockUser(userId);
                   Get.back();
                   Get.snackbar(
                       "Debloquer",
                       "Utilisateur debloquer avec succes!",
                       snackPosition: SnackPosition.TOP,
                       backgroundColor: Colors.green.withOpacity(0.7)
                   );
                 },
                 child: Text("Debloquer", style: TextStyle(
                     fontSize: 15.0,
                     fontWeight: FontWeight.normal,
                     color: Theme.of(context).colorScheme.background
                 ),)
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
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: MyAppBar(text: 'Utilisateurs bloques',),
      body: StreamBuilder<List<Map<String, dynamic>>>(
          stream: chatService.getBlockedUsersStream(userId),
          builder: (context, snapshot) {
            // errors
            if(snapshot.hasError) {
              return  Center(
                child: Text(
                    "Erreur de chargement...",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.inversePrimary,
                  ),
                ),
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
              return  Center(
                child: Text(
                    "Aucun utilisateurs bloquer",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.inversePrimary,
                  ),
                ),
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
