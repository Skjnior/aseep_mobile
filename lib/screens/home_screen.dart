import 'dart:math';

import 'package:aseep/components/userTile.dart';
import 'package:aseep/myUserTiteFromHomeScreen.dart';
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
  String currentUserFirstName = '';
  String currentUserLastName = '';
  String currentUserEmail = '';
  String currentUserProfileImageUrl = '';

  HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final MyServices _chatService = MyServices();
  final AuthService _authService = AuthService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  TextEditingController _searchController = TextEditingController();
  ScrollController _scrollController = ScrollController();  // ScrollController ajouté
  List<String> docIDs = [];
  List<Map<String, dynamic>> _userList = [];
  bool _isLoading = true;
  String _searchErrorMessage = '';
  static final random = Random();

  static String randomPictureUrl() {
    final randomInt = random.nextInt(1000);
    return 'https://picsum.photos/seed/$randomInt/300/300';
  }

  @override
  void initState() {
    super.initState();
    _loadUsers();
    fetchCurrentUserData();
  }

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



  String currentUserFirstName = '';
  String currentUserLastName = '';
  String currentUserEmail = '';
  String currentUserProfileImageUrl = '';
  /*void findUsers(String query) async {
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



  void _scrollToUser(Map<String, dynamic> userData) {
    int index = _userList.indexOf(userData);
    if (index != -1 && _scrollController.hasClients) {
      // Utilisation d'une méthode mieux adaptée pour faire défiler
      double itemHeight = 100.0;  // Vous pouvez ajuster la hauteur des éléments ici
      _scrollController.jumpTo(index * itemHeight);
    }
  }


  Future<void> _loadUsers() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final usersStream = _chatService.getUsersStreamExcludingBlockedAndDeleted();
      final users = await usersStream.first;
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
    await _chatService.refreshData();
    await _loadUsers();
  }

  // Blocage d'un utilisateur
  void _blockUser(BuildContext context, String userId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Bloquer l'Utilisateur"),
        content: const Text("Etes-vous sûr de vouloir bloquer cette personne ?"),
        actions: [
          TextButton(
            onPressed: () => Get.back(),

            child:  Text('Non', style: TextStyle(
                fontSize: 15.0,
                fontWeight: FontWeight.normal,
                color: Theme.of(context).colorScheme.background
            ),),
          ),
          TextButton(
            onPressed: () {
              MyServices().blockUser(userId);
              _refreshUsers();
              Get.back();
              Get.snackbar(
                "Bloquer",
                "Utilisateur bloqué avec succès!",
                snackPosition: SnackPosition.TOP,
                backgroundColor: Colors.red.withOpacity(0.7)
              );
            },
            child:  Text('Bloquer', style: TextStyle(
                fontSize: 15.0,
                fontWeight: FontWeight.normal,
                color: Theme.of(context).colorScheme.background
            ),),
          ),
        ],
      ),
    );
  }

  // Suppression d'un utilisateur avec sa conversation
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
        content:
        const Text("Etes-vous sûr de vouloir signaler cet utilisateur ?"),
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



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: MyAppBar(
        text: 'Home',
      ),
      drawer: const MyDrawer(
        userName: "",
        userEmail: "",
        userImage: "",
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          /*Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 5),
            child: SizedBox(
              height: 46,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  color: Theme.of(context).colorScheme.primary,
                ),
                padding: const EdgeInsets.only(top: 10, left: 10, bottom: 8, right: 10),
                margin: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 18.0),
                        child: TextField(
                          controller: _searchController,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.tertiary,
                          ),
                          cursorColor: Theme.of(context).colorScheme.primary,
                          maxLines: 1,
                          decoration: InputDecoration(
                            suffixIcon: IconButton(
                              onPressed: () => findUsers(_searchController.text),
                              icon: Icon(
                                Icons.search,
                                color: Theme.of(context).colorScheme.tertiary,
                              ),
                            ),
                            hintStyle: TextStyle(
                              color: Theme.of(context).colorScheme.tertiary,
                            ),
                            isDense: true,
                            border: InputBorder.none,
                            hintText: 'Recherche',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),*/
          Expanded(
            child: _isLoading
                ? Center(
              child: LoadingAnimationWidget.inkDrop(
                color: Theme.of(context).colorScheme.secondary,
                size: 35,
              ),
            )
                : _userList.isEmpty
                ? Center(
              child: Text(
                _searchErrorMessage.isEmpty
                    ? "Aucun utilisateur disponible"
                    : _searchErrorMessage,
              ),
            )
                : RefreshIndicator(
              backgroundColor: Theme.of(context).colorScheme.secondary,
              onRefresh: _refreshUsers,
              child: ListWheelScrollView(
                controller: _scrollController,  // Ajout du contrôleur
                physics: const BouncingScrollPhysics(),
                itemExtent: 600,
                diameterRatio: 3.0,
                perspective: 0.003,
                children: _userList.map((userData) {
                  return _builderListItem(userData, context);
                }).toList(),
              ),
            ),
          ),
        ],
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
          padding: const EdgeInsets.all(10.0),
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
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  icon: Icons.report,
                  label: 'Signaler',
                  borderRadius: BorderRadius.circular(23),
                  padding: const EdgeInsets.all(10),
                ),
              ],
            ),
            child: MyUserTileFromeHomeScreen(
              text: userData["email"],
              name: userData["lastName"],
              firstName: userData["firstName"],
              onTap: () {
               /* Get.to(() => ChatScreen(
                  receiverEmail: userData["email"],
                  receiverID: userData["uid"],
                  receiverFirstName: userData["firstName"],
                  receiverLastName: userData["lastName"],
                  receiverImagePath: userData["profileImageUrl"],
                ));*/
                Get.to(() => ChatScreen(
                  receiverEmail: userData["email"],
                  receiverID: userData["uid"],
                  receiverFirstName: userData["firstName"],
                  receiverLastName: userData["lastName"],
                  receiverImagePath: 'https://picsum.photos/seed/${random.nextInt(1000)}/300/300',
                ));
              },
              onTapPro: () {
                Get.to(() => ProfileScreen(
                  userId: userData["uid"],
                  userEmail: userData["email"],
                  userFirstName: userData["firstName"],
                  userImagePath: 'https://picsum.photos/seed/${random.nextInt(1000)}/300/300',
                  // userImagePath: userData["profileImageUrl"],
                  userLastName: userData["lastName"],
                ));
              },
            ),
          ),
          ),
      );
    }
    return const SizedBox();
  }
}

