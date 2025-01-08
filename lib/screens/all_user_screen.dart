import 'dart:math';

import 'package:aseep/components/userTile.dart';
import 'package:aseep/screens/chat/chat_screen.dart';
import 'package:aseep/screens/profile_screen.dart';
import 'package:aseep/services/auth/auth_services.dart';
import 'package:aseep/services/chat/chat_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import '../components/myAppBar.dart';
import '../components/my_drawer.dart';

class AllUsersScreen extends StatefulWidget {
  AllUsersScreen({super.key});

  @override
  State<AllUsersScreen> createState() => _AllUsersScreenState();
}

class _AllUsersScreenState extends State<AllUsersScreen> {

  // Chat & auth service
  final MyServices _chatService = MyServices();
  final AuthService _authService = AuthService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  TextEditingController _searchController = TextEditingController();
  ScrollController _scrollController = ScrollController();
  String _searchErrorMessage = '';
  static final random = Random();
  

  // Une liste pour stocker les id des users
  List<String> docIDs = [];


/*  void _scrollToUser(Map<String, dynamic> userData) {
    int index = _userList.indexOf(userData);
    if (index != -1 && _scrollController.hasClients) {
      // Utilisation d'une méthode mieux adaptée pour faire défiler
      double itemHeight = 100.0;  // Vous pouvez ajuster la hauteur des éléments ici
      _scrollController.jumpTo(index * itemHeight);
    }
  }

  void findUsers(String query) async {
    if (query.isEmpty) {
      await _loadUsers();
      return;
    }

    setState(() {
      _isLoading = true;
      _searchErrorMessage = '';  // Réinitialiser le message d'erreur
    });

    try {
      QuerySnapshot snapshot = await _firestore
          .collection('Users')
          .where('firstName', isGreaterThanOrEqualTo: query)
          .where('firstName', isLessThanOrEqualTo: '$query\uf8ff')
          .get();

      // Si aucun résultat n'est trouvé avec 'firstName', essayer 'lastName'
      if (snapshot.docs.isEmpty) {
        snapshot = await _firestore
            .collection('Users')
            .where('lastName', isGreaterThanOrEqualTo: query)
            .where('lastName', isLessThanOrEqualTo: '$query\uf8ff')
            .get();
      }

      // Si toujours aucun résultat, essayer avec 'email'
      if (snapshot.docs.isEmpty) {
        snapshot = await _firestore
            .collection('Users')
            .where('email', isGreaterThanOrEqualTo: query)
            .where('email', isLessThanOrEqualTo: '$query\uf8ff')
            .get();
      }

      List<Map<String, dynamic>> searchedUsers = snapshot.docs.map((doc) {
        return doc.data() as Map<String, dynamic>;
      }).toList();

      if (searchedUsers.isNotEmpty) {
        setState(() {
          _userList = searchedUsers;
          _isLoading = false;
        });
        _scrollToUser(searchedUsers.first);
      } else {
        setState(() {
          _userList = [];
          _isLoading = false;
          _searchErrorMessage = 'Aucun utilisateur trouvé';
        });
      }
    } catch (e) {
      print("Erreur lors de la recherche d'utilisateurs : $e");
      setState(() {
        _isLoading = false;
      });
    }
  }*/
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
      final usersStream = _chatService.getUsersStreamExcludingBlockedAndDeleted();
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
      builder: (context) => AlertDialog(
        title: const Text("Bloquer l'Utilisateur"),
        content: const Text("Etes-vous sûr de vouloir bloquer cette personne ?"),
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
                const SnackBar(content: Text("Utilisateur bloqué avec succès!")),
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
      builder: (context) => AlertDialog(
        title: const Text("Suppression de la conversation"),
        content: const Text("Etes-vous sûr de vouloir supprimer cette conversation ?"),
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
                const SnackBar(content: Text("Conversation supprimée avec succès!")),
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
      builder: (context) => AlertDialog(
        title: const Text("Signaler ce Message"),
        content: const Text("Etes-vous sûr de vouloir signaler cet utilisateur ?"),
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
                const SnackBar(content: Text("Utilisateur signalé avec succès!")),
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
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: MyAppBar(text: 'Utilisateurs',),
      body: _isLoading
          ? Center(
                  child: LoadingAnimationWidget.inkDrop(
          color: Theme.of(context).colorScheme.secondary,
          size: 35,
                  ),
                )
          : _userList.isEmpty
          ? const Center(child: Text("Aucun utilisateur disponible"))
          : RefreshIndicator(
        backgroundColor: Theme.of(context).colorScheme.secondary,
        onRefresh: _refreshUsers,
        child: ListView.builder(
          itemCount: _userList.length,
          itemBuilder: (context, index) {
            final userData = _userList[index];
            return _builderListItem(userData, context);
          },
        ),
      ),
    );
  }

  Widget _builderListItem(Map<String, dynamic> userData, BuildContext context) {
    if (userData["email"] != _authService.getCurrentUser()!.email) {
      return GestureDetector(
        onLongPress: () {
          _deleteUserWithChat(context, userData["uid"]);
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Slidable(
            key: ValueKey(userData["uid"]),
            startActionPane: ActionPane(
              motion: const ScrollMotion(),
              children: [
                SlidableAction(
                  onPressed: (_) => _blockUser(context, userData["uid"]),
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  icon: Icons.block,
                  label: 'Bloquer',
                  borderRadius: BorderRadius.circular(23),
                  padding: const EdgeInsets.all(10),
                ),
                const SizedBox(width: 10),
                SlidableAction(
                  onPressed: (_) => _reportUser(context, userData["uid"]),
                  backgroundColor: Colors.lightBlueAccent,
                  foregroundColor: Colors.white,
                  icon: Icons.report,
                  label: 'Signaler',
                  borderRadius: BorderRadius.circular(23),
                  padding: const EdgeInsets.all(10),
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
                  receiverImagePath: userData["https://picsum.photos/seed/${random.nextInt(1000)}/300/300"],
                  // receiverImagePath: userData["profileImageUrl"],
                ));
              },
              onTapPro: () {
                Get.to(() => ProfileScreen(
                  userId: userData["uid"],
                  userEmail: userData["email"],
                  userFirstName: userData["firstName"],
                  userImagePath: userData["https://picsum.photos/seed/${random.nextInt(1000)}/300/300"],
                  // userImagePath: userData["profileImageUrl"],
                  userLastName: userData["lastName"],
                ));
              },
            ),
          ),
        ),
      );
    } else {
      return const SizedBox.shrink();
    }
  }
}


class GetUserData extends StatelessWidget {
  final String documentId;
  const GetUserData({super.key, required this.documentId});

  @override
  Widget build(BuildContext context) {
    // get the collections
    CollectionReference users = FirebaseFirestore.instance.collection("Users");
    return FutureBuilder<DocumentSnapshot>(
      future: users.doc(documentId).get(),
      builder: ((context, snapshot) {
        if(snapshot.connectionState == ConnectionState.done) {
          Map<String, dynamic> data = snapshot.data!.data() as Map<String, dynamic>;
          return Text('${data['firstName']}');
        }
        return const Text("Chargement...");
      }),
    );
  }
}
