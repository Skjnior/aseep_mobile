import 'package:aseep/components/userTile.dart';
import 'package:aseep/screens/chat/chat_screen.dart';
import 'package:aseep/screens/profile_screen.dart';
import 'package:aseep/services/auth/auth_services.dart';
import 'package:aseep/services/chat/chat_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import '../components/my_drawer.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  // Chat & auth service
  final MyServices _chatService = MyServices();
  final AuthService _authService = AuthService();

  // Block user
  void _blockUser(BuildContext context, String userId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Bloquer l'Utilisateur"),
        content: const Text("Etes-vous sûr de vouloir bloquer cette personne ?"),
        actions: [
          // Cancel button
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Non'),
          ),
          // Block button
          TextButton(
            onPressed: () {
              // Perform block
              MyServices().blockUser(userId);
              // Dismiss dialog
              Get.back();
              // Dismiss page
              Get.back();
              // Notify user of success
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Utilisateur bloqué avec succès!")));
            },
            child: const Text('Bloquer'),
          ),
        ],
      ),
    );
  }

  // report message
  void _reportUser(BuildContext context, String userId) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Signaler ce Message"),
          content: const Text("Etes-vous sûr de vouloir signaler ce utilisateur ?"),
          actions: [

            // cancel button
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('Annuler'),
            ),

            // Le button signaler
            TextButton(
              onPressed: () {
                MyServices().reportMessage(userId);
                Get.back();
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Utilisateur signaler avec succes!")));
              },
              child: const Text('Signaler'),
            ),
          ],
        )
    );
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.grey,
        centerTitle: true,
        title: Text("Home Screen"),
      ),
      drawer: MyDrawer(),
      body: _buildUserList(context),
    );
  }

  Widget _buildUserList(BuildContext context) {
    return StreamBuilder(
      stream: _chatService.getUsersStreamExcludingBlocked(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text("Erreur"));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: LoadingAnimationWidget.inkDrop(
              color: Color(0xff2983A6),
              size: 35,
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text("Aucun utilisateur disponible"));
        }

        return RefreshIndicator(
          onRefresh: () async {
            await _chatService.refreshData();
          },
          child: ListView(
            children: snapshot.data!.map<Widget>((userData) {
              return _builderListItem(userData, context);
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _builderListItem(Map<String, dynamic> userData, BuildContext context) {
    if (userData["email"] != _authService.getCurrentUser()!.email) {
      return Slidable(
        key: ValueKey(userData["uid"]), // Unique key for Slidable
        startActionPane: ActionPane(
          motion: const ScrollMotion(),
         /* dismissible: DismissiblePane(onDismissed: () {
            _blockUser(context, userData["uid"]);
          }),*/
          children: [
            SlidableAction(
              onPressed: (_) => _blockUser(context, userData["uid"]),
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              icon: Icons.block,
              label: 'Bloquer',
              borderRadius: BorderRadius.circular(23),
              padding: EdgeInsets.all(10),

            ),
            const SizedBox(width: 10,),
            SlidableAction(
              onPressed: (_) => _reportUser(context, userData["uid"]),
              backgroundColor: Colors.lightBlueAccent,
              foregroundColor: Colors.white,
              icon: Icons.report,
              label: 'Signaler',
              borderRadius: BorderRadius.circular(23),
              padding: EdgeInsets.all(10),
            ),
          ],
        ),
        child: UserTile(
          text: userData["email"],
          name: userData["lastName"],
          firstName: userData["firstName"],
          onTap: () {
            Get.to(() => ChatScreen(
              receiverEmail: userData["email"],
              receiverID: userData["uid"],
              receiverFirstName: userData["firstName"],
              receiverLastName: userData["lastName"],
              receiverImagePath: userData["profileImageUrl"],
            ));
          },
          onTapPro: () {
            Get.to(() => ProfileScreen(
              userId: userData["uid"],
              userEmail: userData["email"],
              userFirstName: userData["firstName"],
              userImagePath: userData["profileImageUrl"],
              userLastName: userData["lastName"],
            ));
          },
        ),
      );
    } else {
      return Container();
    }
  }
}
