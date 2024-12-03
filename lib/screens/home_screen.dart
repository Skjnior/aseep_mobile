import 'package:aseep/components/userTile.dart';
import 'package:aseep/screens/chat/chat_screen.dart';
import 'package:aseep/screens/profile_screen.dart';
import 'package:aseep/services/auth/auth_services.dart';
import 'package:aseep/services/chat/chat_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import '../components/myAppBar.dart';
import '../components/my_drawer.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  // Chat & auth service
  final MyServices _chatService = MyServices();
  final AuthService _authService = AuthService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Une liste pour stocker les id des users
  List<String> docIDs = [];


  // Local state for user list
  List<Map<String, dynamic>> _userList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUsers(); // Load initial users
    fetchCurrentUserData();
  }

  /* Future getDocId() async {
    await FirebaseFirestore.instance.collection("Users").where('uid', ).get().then(
        (snapshot) => snapshot.docs.forEach(
            (document) {
              docIDs.add(document.reference.id);
            }
        ),
    );
  }*/


  void fetchCurrentUserData() async {
    String currentUserUid = FirebaseAuth.instance.currentUser?.uid ?? '';

    if (currentUserUid.isNotEmpty) {
      FirebaseFirestore.instance
          .collection('Users')
          .where('uid', isEqualTo: currentUserUid)
          .get()
          .then((QuerySnapshot querySnapshot) {
        if (querySnapshot.docs.isNotEmpty) {
          var userDoc = querySnapshot.docs.first;

          setState(() {
            currentUserFirstName = userDoc['firstName'] ?? 'Prénom';
            currentUserLastName = userDoc['lastName'] ?? 'Nom';
            currentUserEmail = userDoc['email'] ?? 'Email';
            currentUserProfileImageUrl =
                userDoc['profileImageUrl'] ?? ''; // Peut être une URL ou vide
          });
        }
      }).catchError((error) {
        print("Erreur lors de la récupération des données : $error");
      });
    }
  }


  Future<void> _loadUsers() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final usersStream = _chatService
          .getUsersStreamExcludingBlockedAndDeleted();
      final users = await usersStream.first; // Fetch first batch of users
      setState(() {
        _userList = users;
        _isLoading = false;
      });
    } catch (e) {
      print("Erreur lors du chargement des utilisateurs : $e");
      setState(() {
        _isLoading = false;
      });
    }
  }


  Future<void> _refreshUsers() async {
    await _chatService.refreshData(); // Optional for server updates
    await _loadUsers(); // Reload users locally
  }


  // Block user
  void _blockUser(BuildContext context, String userId) {
    showDialog(
      context: context,
      builder: (context) =>
          AlertDialog(
            title: const Text("Bloquer l'Utilisateur"),
            content: const Text(
                "Etes-vous sûr de vouloir bloquer cette personne ?"),
            actions: [
              TextButton(
                onPressed: () => Get.back(),
                child: const Text('Non'),
              ),
              TextButton(
                onPressed: () {
                  MyServices().blockUser(userId);
                  _refreshUsers();
                  Get.back();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text("Utilisateur bloqué avec succès!")),
                  );
                },
                child: const Text('Bloquer'),
              ),
            ],
          ),
    );
  }

  // Delete user with all chat
  void _deleteUserWithChat(BuildContext context, String userId) {
    showDialog(
      context: context,
      builder: (context) =>
          AlertDialog(
            title: const Text("Suppression de la conversation"),
            content: const Text(
                "Etes-vous sûr de vouloir supprimer cette conversation ?"),
            actions: [
              TextButton(
                onPressed: () => Get.back(),
                child: const Text('Non'),
              ),
              TextButton(
                onPressed: () {
                  MyServices().deleteUser(userId);
                  Get.back();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text("Conversation supprimée avec succès!")),
                  );
                  _refreshUsers();
                },
                child: const Text('Supprimer'),
              ),
            ],
          ),
    );
  }

  // Report message
  void _reportUser(BuildContext context, String userId) {
    showDialog(
      context: context,
      builder: (context) =>
          AlertDialog(
            title: const Text("Signaler ce Message"),
            content: const Text(
                "Etes-vous sûr de vouloir signaler cet utilisateur ?"),
            actions: [
              TextButton(
                onPressed: () => Get.back(),
                child: const Text('Annuler'),
              ),
              TextButton(
                onPressed: () {
                  MyServices().reportMessage(userId);
                  Get.back();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text("Utilisateur signalé avec succès!")),
                  );
                  _refreshUsers();
                },
                child: const Text('Signaler'),
              ),
            ],
          ),
    );
  }


  String currentUserFirstName = '';
  String currentUserLastName = '';
  String currentUserEmail = '';
  String currentUserProfileImageUrl = '';


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:Theme.of(context).colorScheme.background,
      appBar: MyAppBar(text: 'Home Screen',),

      drawer: MyDrawer(
        userName: "$currentUserFirstName $currentUserLastName",
        userEmail: currentUserEmail,
        userImage: currentUserProfileImageUrl,
      ),

      body: Container(),
    );
  }
}




