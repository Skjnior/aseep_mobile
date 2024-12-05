import 'dart:io';

import 'package:aseep/components/myButton.dart';
import 'package:aseep/screens/home_screen.dart';
import 'package:aseep/services/auth/auth_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../../components/myTextField.dart';
import '../../services/chat/chat_services.dart';

class SignupScreen extends StatefulWidget {
  SignupScreen({super.key, required this.onTap});

  final void Function()? onTap;

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _pwController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _confirmPwController = TextEditingController();
  final TextEditingController _matriculeController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();

  DateTime? _selectedDate;
  File? _selectedImage;
  String _uploadedImageUrl = "";

  bool isLoading = false;

  final _auth = AuthService();
  String? _selectedNiveau;

  final List<String> _niveauOptions = [
    "1ère année",
    "2ème année",
    "3ème année",
    "4ème année",
    "5ème année",
    "Diplomer",
  ];

  // Liste pour stocker les niveaux sélectionnés
  List<String> _selectedNiveaux = [];

  /// Méthode pour gérer l'inscription
  /// Méthode pour gérer l'inscription
  Future<void> signup(BuildContext context) async {
    if (!mounted) return; // Vérifie si le widget est monté avant de procéder
    setState(() {
      isLoading = true; // Activer le chargement
    });

    try {
      // Vérification si les mots de passe correspondent
      if (_pwController.text != _confirmPwController.text) {
        if (mounted) {
          setState(() {
            isLoading = false; // Désactiver le chargement
          });
        }
        _showErrorDialog(context, "Les mots de passe ne correspondent pas !");
        return;
      }

      // Vérification des champs obligatoires
      if (_emailController.text.isEmpty ||
          _firstNameController.text.isEmpty ||
          _lastNameController.text.isEmpty ||
          _matriculeController.text.isEmpty) {
        if (mounted) {
          setState(() {
            isLoading = false; // Désactiver le chargement
          });
        }
        _showErrorDialog(context, "Tous les champs sont obligatoires !");
        return;
      }

      // Validation de l'email
      if (!_isValidEmail(_emailController.text)) {
        if (mounted) {
          setState(() {
            isLoading = false; // Désactiver le chargement
          });
        }
        _showErrorDialog(context, "Veuillez entrer un email valide !");
        return;
      }

      // Vérifier si la matricule existe déjà
      final querySnapshot = await FirebaseFirestore.instance
          .collection('Users')
          .where('matricule', isEqualTo: _matriculeController.text)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        if (mounted) {
          setState(() {
            isLoading = false; // Désactiver le chargement
          });
        }
        _showErrorDialog(context, "Cette matricule existe déjà !");
        return;
      }

      // Créer l'utilisateur avec Firebase Authentication
      final userCredential = await _auth.signUpWithEmailAndPassword(
        _emailController.text,
        _pwController.text,
      );

      final user = userCredential.user;

      if (user != null) {
        // Vérifier et télécharger la photo
        bool imageUploadFailed = false;
        String uploadedImageUrl = "";

        if (_selectedImage != null) {
          try {
            uploadedImageUrl = await _uploadImageToFirebase();
          } catch (e) {
            print("Erreur lors du téléchargement de l'image : $e");
            uploadedImageUrl = "";
            imageUploadFailed = true;
          }
        }

        // Enregistrer les informations dans Firestore
        await FirebaseFirestore.instance.collection('Users').doc(user.uid).set({
          'uid': user.uid,
          'email': user.email,
          'firstName': _firstNameController.text,
          'lastName': _lastNameController.text,
          'matricule': _matriculeController.text,
          'niveaux': _selectedNiveaux,
          'birthDate': _selectedDate?.toIso8601String(),
          'profileImageUrl': uploadedImageUrl,
        });

        if (imageUploadFailed && mounted) {
          _showErrorDialog(
            context,
            "Votre compte a été créé, mais votre photo de profil n'a pas pu être téléchargée. Veuillez mettre à jour votre profil ultérieurement.",
          );
        }

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomeScreen()),
          );
        }
      } else {
        throw Exception("L'utilisateur est null après l'inscription.");
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog(context, e.toString());
      } else {
        print("Erreur hors contexte valide : $e");
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false; // Désactiver le chargement après le traitement
        });
      }
    }
  }



  // Chat & auth service
  final MyServices _chatService = MyServices();
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


  Future<void> _refreshUsers() async {
    await _chatService.refreshData(); // Optional for server updates
    await _loadUsers(); // Reload users locally
  }



  // Méthode pour afficher une boîte de dialogue de sélection multiple
  Future<void> _showMultiSelectDialog() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter dialogSetState) {
            return AlertDialog(
              backgroundColor: Theme.of(context).colorScheme.background,
              title: const Text('Sélectionner les niveaux'),
              content: SizedBox(
                width: double.maxFinite,
                child: ListView(
                  children: _niveauOptions.map((niveau) {
                    return CheckboxListTile(
                      title: Text(niveau),
                      value: _selectedNiveaux.contains(niveau),
                      onChanged: (bool? isSelected) {
                        dialogSetState(() {
                          if (isSelected == true) {
                            if (!_selectedNiveaux.contains(niveau)) {
                              _selectedNiveaux.add(niveau);
                            }
                          } else {
                            _selectedNiveaux.remove(niveau);
                          }
                        });
                        // Met à jour immédiatement l'état principal
                        setState(() {});
                      },
                    );
                  }).toList(),
                ),
              ),
              actions: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child:  Text(
                    "Annuler",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.tertiary,
                    ),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child:  Text(
                      "Confirmer",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.tertiary,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }


  /// Méthode pour sélectionner une image
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  /// Méthode pour télécharger l'image dans Firebase Storage
  Future<String> _uploadImageToFirebase() async {
    final storageRef = FirebaseStorage.instance.ref();
    final imageRef = storageRef.child("profile_images/${DateTime.now().toIso8601String()}.jpg");

    await imageRef.putFile(_selectedImage!);
    return await imageRef.getDownloadURL();
  }

  /// Sélection de la date
  void _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(1000),
      lastDate: DateTime(2101),
      barrierColor: const Color(0xff2983A6), // Couleur de fond derrière le DatePicker
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: const Color(0xff2983A6), // Couleur principale (entête et sélection)
            colorScheme: const ColorScheme.light(
              primary: Color(0xff2983A6), // Couleur pour les éléments sélectionnés
            ),
            buttonTheme: const ButtonThemeData(
              textTheme: ButtonTextTheme.primary, // Couleur des boutons OK/Annuler
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }


  /// Afficher un message d'erreur
  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Erreur"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  /// Fonction pour vérifier si l'email est valide
  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  /// Fonction pour vérifier si le matricule est valide
  bool _isValidMatricule(String matricule) {
    // Exemple de validation : vérifier si le matricule est un nombre
    return matricule.isNotEmpty && int.tryParse(matricule) != null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2983A6),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Avatar avec Neumorphism
                    neumorphicContainer(
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: neumorphicContainer(
                          child: CircleAvatar(
                            radius: 40,
                            backgroundColor: Theme.of(context).colorScheme.secondary,
                            backgroundImage: _selectedImage != null
                                ? FileImage(_selectedImage!)
                                : null,
                            child: _selectedImage == null
                                ? const Icon(
                              Icons.camera_alt,
                              size: 20,
                              color: Colors.white,
                            )
                                : null,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // TextField avec Neumorphism
                    neumorphicContainer(
                      child: MyTextField(
                        controller: _firstNameController,
                        obscureText: false,
                        hintext: "Prénom",
                        myIcon: Icons.person,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Le Prenom est obligatoire";
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 10),
                    neumorphicContainer(
                      child: MyTextField(
                        controller: _lastNameController,
                        obscureText: false,
                        hintext: "Nom",
                        myIcon: Icons.person_outline,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Le nom est obligatoire";
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 10),
                    neumorphicContainer(
                      child: MyTextField(
                        controller: _matriculeController,
                        obscureText: false,
                        hintext: "Matricule",
                        myIcon: Icons.numbers,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "La matricule est obligatoire";
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 10),
                    neumorphicContainer(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 25.0),
                        child: GestureDetector(
                          onTap: () async {
                            // Ouvre le dialogue pour la sélection multiple
                            await _showMultiSelectDialog();
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              border: Border.all(color: Theme.of(context).colorScheme.secondary),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                 const Icon(Icons.school),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    _selectedNiveaux.isNotEmpty
                                        ? _selectedNiveaux.join(", ")
                                        : "Sélectionner un niveau",
                                    style: TextStyle(
                                      color: _selectedNiveaux.isNotEmpty
                                          ? Theme.of(context).colorScheme.inversePrimary
                                          : Theme.of(context).colorScheme.inversePrimary,
                                    ),
                                  ),
                                ),
                                 const Icon(
                                    Icons.arrow_drop_down,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    neumorphicContainer(
                      child: MyTextField(
                        controller: _emailController,
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
                    const SizedBox(height: 10),
                    neumorphicContainer(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 25.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Theme.of(context).colorScheme.secondary,
                                ),
                                onPressed: _selectDate,
                                child: Text(
                                  _selectedDate == null
                                      ? "Date de naissance"
                                      : "Date: ${DateFormat('dd/MM/yyyy').format(_selectedDate!)}",
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.inversePrimary,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    neumorphicContainer(
                      child: MyTextField(
                        controller: _pwController,
                        obscureText: true,
                        hintext: "Mot de passe",
                        myIcon: Icons.lock,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Le mot de passe est obligatoire";
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 10),
                    neumorphicContainer(
                      child: MyTextField(
                        controller: _confirmPwController,
                        obscureText: true,
                        hintext: "Confirmer le mot de passe",
                        myIcon: Icons.lock_outline,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Ce champs est obligatoire";
                          }
                          return null;
                        },
                      ),
                    ),



                    const SizedBox(height: 15),
                    // Bouton avec Neumorphism
                    const SizedBox(height: 15),
                    isLoading ? neumorphicContainer(
                      child: LoadingAnimationWidget.inkDrop(
                          color: const Color(0xFF122640),
                          size: 35
                      ),
                    )
                        : neumorphicContainer(
                          child: MyButton(
                            text: "S'inscrire",
                            onTap: isLoading ? null : () {
                          setState(() {
                            _refreshUsers();
                          });
                          signup(context);
                          },
                          ),
                        ),
                    const SizedBox(height: 15),
                    // Texte pour la connexion
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Vous êtes membre de l'EPI ? ",
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.tertiary,
                          ),
                        ),
                        GestureDetector(
                          onTap: widget.onTap,
                          child:  Text(
                            "Se connecter",
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
        ),
      ),
    );
  }
  Widget neumorphicContainer({required Widget child,}) {
    return Container(
      padding: const EdgeInsets.all(8),
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
