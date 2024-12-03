import 'package:aseep/services/chat/chat_services.dart';
import 'package:aseep/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:provider/provider.dart';

class ChatBublle extends StatelessWidget {
  final String message;
  final bool isCurrentUser;
  final String messageId;
  final String userId;
   ChatBublle({
     super.key,
     required this.message,
     required this.isCurrentUser,
     required this.messageId,
     required this.userId
   });

   // Show options
  void _showOptions(BuildContext context, String messageId, String userId) {
    showBottomSheet(
        context: context,
        builder: (context) {
          return SafeArea(
            child: Wrap(
              children: [
                // report message button
                ListTile(
                  leading: const Icon(Icons.flag),
                  title: const Text("Signaler"),
                  onTap: () {
                    Get.back();
                    _reportMessage(context, messageId, userId);
                  },
                ),

                // block user button
              /*  ListTile(
                  leading: const Icon(Icons.block),
                  title: const Text("Bloquer le user"),
                  onTap: () {
                    Get.back();
                    _blockUer(context, userId);
                  },
                ),*/
                ListTile(
                  leading: const Icon(Icons.cancel),
                  title: const Text("Retour"),
                  onTap: () => Get.back(),
                ),
              ],
            ),
          );
        }
    );
  }

  // report message
  void _reportMessage(BuildContext context, String messageId, String userId) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Signaler ce Message"),
          content: const Text("Etes-vous sûr de vouloir signaler ce message ?"),
          actions: [

            // cancel button
            TextButton(
                onPressed: () => Get.back(),
                child: const Text('Annuler'),
            ),

            // Le button signaler
            TextButton(
              onPressed: () {
                MyServices().reportUser(messageId, userId);
                Get.back();
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Message signaler avec succes!")));
              },
              child: const Text('Signaler'),
            ),
          ],
        )
    );
  }


/*
  // block user
  void _blockUer(BuildContext context, String userId) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Bloquer l'Utilisateur"),
          content: const Text("Etes-vous sûr de vouloir bloquer cette personne ?"),
          actions: [

            // cancel button
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('Non'),
            ),

            // Le button signaler
            TextButton(
              onPressed: () {
                // perform block
                ChatService().blockUser(userId);
                // dismiss dialog
                Get.back();
                // dismiss page
                Get.back();
                // let user know of result
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Utilisateur bloquer avec succes!")));
              },
              child: const Text('Bloquer'),
            ),
          ],
        )
    );
  }

*/







  @override
  Widget build(BuildContext context) {
    // light vs dark mode for correct bubble colors
    bool isDarkMode = Provider.of<ThemeProvider>(context, listen: false).isDarkMode;



    return GestureDetector(
      onLongPress: () {
        if (!isCurrentUser) {
          // show options
          _showOptions(context, messageId, userId);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.symmetric(vertical: 2.5, horizontal: 25),
        decoration: BoxDecoration(
          borderRadius:
          isCurrentUser
              ? const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(25),
            bottomLeft: Radius.circular(20)
          )
              : const BorderRadius.only(

              topRight: Radius.circular(20),
              bottomRight: Radius.circular(20),
              bottomLeft: Radius.circular(25)
          ),
          color: isCurrentUser
              ? (isDarkMode ? Theme.of(context).colorScheme.secondary : Theme.of(context).colorScheme.secondary)
              : (isDarkMode ? Theme.of(context).colorScheme.secondary : Theme.of(context).colorScheme.secondary),
        ),
        child: Text(
            message,
          style: TextStyle(
            color: isCurrentUser ? Colors.white :( isDarkMode ? Colors.white : Colors.black),
          ),
        ),
      ),
    );
  }
}
