import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:aseep/services/auth/auth_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import '../../components/myButton.dart';
import '../../components/myTextField.dart';
import '../../services/chat/chat_services.dart';

class LoginScreen extends StatefulWidget {
  /// action to go to register screen
  final void Function()? onTap;

  LoginScreen({super.key, required this.onTap});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailControler = TextEditingController();

  final TextEditingController _matriculeController = TextEditingController();

  final TextEditingController _pwControler = TextEditingController();

  bool isLoading = false;

  void login() async {
    final _auth = FirebaseAuth.instance;
    final _firestore = FirebaseFirestore.instance;
    setState(() {
      isLoading = true; // Activer le chargement
    });
    // Vérification des champs obligatoires
    if (_matriculeController.text.isEmpty) {
      setState(() {
        isLoading = false; // Désactiver le chargement
      });
      showErrorDialog('Le matricule est obligatoire');
      return;
    }

    if (_emailControler.text.isEmpty) {
      setState(() {
        isLoading = false; // Désactiver le chargement
      });
      showErrorDialog('L\'email est obligatoire');
      return;
    }

    if (_pwControler.text.isEmpty) {
      setState(() {
        isLoading = false; // Désactiver le chargement
      });
      showErrorDialog('Le mot de passe est obligatoire');
      return;
    }

    try {
      // Vérifier la matricule dans Firestore
      final matriculeSnapshot = await _firestore
          .collection('Users') // Assurez-vous que le nom est correct
          .where('matricule', isEqualTo: _matriculeController.text)
          .get();

      if (matriculeSnapshot.docs.isEmpty) {
        setState(() {
          isLoading = false; // Désactiver le chargement
        });
        showErrorDialog('La matricule saisie est invalide.');
        return;
      }

      if (matriculeSnapshot.docs.length > 1) {
        setState(() {
          isLoading = false; // Désactiver le chargement
        });
        showErrorDialog('Une erreur s\'est produite : matricule non unique.');
        return;
      }

      // Vérification que la matricule correspond bien à l'email
      final userDoc = matriculeSnapshot.docs.first;
      final userData = userDoc.data();
      if (userData['email'] != _emailControler.text) {
        setState(() {
          isLoading = false; // Désactiver le chargement
        });
        showErrorDialog('La matricule ne correspond pas à l\'email saisi.');
        return;
      }

      // Tentative de connexion
      await _auth.signInWithEmailAndPassword(
        email: _emailControler.text,
        password: _pwControler.text,
      );

      // Connexion réussie
      Get.snackbar(
        'Succès',
        'Connexion réussie',
        colorText: Theme.of(context).colorScheme.inversePrimary,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Theme.of(context).colorScheme.secondary
      );
    } catch (e) {
      showErrorDialog('Une erreur est survenue : ${e.toString()}');
    }
    finally {
      setState(() {
        isLoading = false; // Désactiver le chargement après le traitement
      });
    }
  }

  // Chat & auth service
  final MyServices _chatService = MyServices();
  final AuthService _authService = AuthService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // Local state for user list
  List<Map<String, dynamic>> _userList = [];

  Future<void> _loadUsers() async {
    setState(() {
      isLoading = true;
    });

    try {
      final usersStream = _chatService
          .getUsersStreamExcludingBlockedAndDeleted();
      final users = await usersStream.first; // Fetch first batch of users
      setState(() {
        _userList = users;
        isLoading = false;
      });
    } catch (e) {
      print("Erreur lors du chargement des utilisateurs : $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  /// Afficher une boîte de dialogue d'erreur
  void showErrorDialog(String message) {
    Get.dialog(
      AlertDialog(
        title: const Text('Erreur'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(top: 70),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
              DefaultTextStyle(
                style: const TextStyle(
                  fontSize: 24.0,
                  fontFamily: 'Horizon',
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF122640)
                ),
                child: Text(
                  "ASEEP-KOFI",
                  style: TextStyle(
                      fontSize: 23.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white
                  ),
                ),
              ),
                const SizedBox(height: 10),

                // Conteneur avec logo et effet *neumorphism*
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2983A6),
                    borderRadius: BorderRadius.circular(100),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withOpacity(0.3),
                        offset: const Offset(-10, -10),
                        blurRadius: 20,
                      ),
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        offset: const Offset(10, 10),
                        blurRadius: 20,
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/images/ourLogo.jpg',
                      fit: BoxFit.cover,
                      width: 120,
                      height: 120,
                    ),
                  ),
                ),
                const SizedBox(height: 15),

                // Champ matricule avec effet *neumorphism*
                _buildNeumorphicContainer(
                  child: MyTextField(
                    controller: _matriculeController,
                    obscureText: false,
                    hintext: "Matricule",
                    myIcon: Icons.credit_card,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Le matricule est obligatoire";
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 15),

                // Champ email avec effet *neumorphism*
                _buildNeumorphicContainer(
                  child: MyTextField(
                    controller: _emailControler,
                    obscureText: false,
                    hintext: "Adresse email",
                    myIcon: Icons.email,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Le mail est obligatoire";
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 15),

                // Champ mot de passe avec effet *neumorphism*
                _buildNeumorphicContainer(
                  child: MyTextField(
                    controller: _pwControler,
                    obscureText: true,
                    hintext: "Mot de passe",
                    myIcon: Icons.password,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Le mot de passe est obligatoire";
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 15),

                // Bouton de connexion avec effet *neumorphism*
                // Bouton de connexion
                isLoading ? _buildNeumorphicContainer(
                  child: LoadingAnimationWidget.inkDrop(
                      color: Color(0xFF122640),
                      size: 35
                  ),
                ) :
                _buildNeumorphicContainer(
                  child: MyButton(
                    text: "Se connecter",
                    onTap: () {
                      setState(() {
                        _loadUsers();
                      });
                      login();
                    },
                  ),
                ),
                const SizedBox(height: 15),

                // Texte pour l'inscription
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                     Text(
                      "Vous n'êtes pas membre de l'EPI ? ",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.tertiary,
                      ),
                    ),
                    GestureDetector(
                      onTap: widget.onTap,
                      child:  Text(
                        "S'inscrire",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.tertiary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Widget utilitaire pour appliquer l'effet *neumorphism* à un conteneur
  Widget _buildNeumorphicContainer({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF2983A6),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withOpacity(0.3),
            offset: const Offset(-4, -4),
            blurRadius: 6,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            offset: const Offset(4, 4),
            blurRadius: 6,
          ),
        ],
      ),
      child: child,
    );
  }
}

