import 'dart:io';
import 'package:aseep/components/myButton.dart';
import 'package:aseep/components/myTextField.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../models/filiere.dart';
import '../../services/filiere_service.dart';

class CreateFilierePage extends StatefulWidget {
  const CreateFilierePage({Key? key}) : super(key: key);

  @override
  _CreateFilierePageState createState() => _CreateFilierePageState();
}

class _CreateFilierePageState extends State<CreateFilierePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _sigleController = TextEditingController();
  final TextEditingController _imagePathController = TextEditingController();
  final TextEditingController _chefDepartementController = TextEditingController();
  final TextEditingController _domaineController = TextEditingController();
  final TextEditingController _sloganController = TextEditingController();
  final TextEditingController _niveauController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  bool _isSubmitting = false;
  File? _selectedImage;
  String _uploadedImageUrl = "";

  @override
  void dispose() {
    _nameController.dispose();
    _sigleController.dispose();
    _imagePathController.dispose();
    _chefDepartementController.dispose();
    _domaineController.dispose();
    _sloganController.dispose();
    _niveauController.dispose();
    super.dispose();
  }

  /// Méthode pour télécharger l'image dans Firebase Storage
  Future<String> _uploadImageToFirebase() async {
    if (_selectedImage != null) {
      try {
        final storageRef = FirebaseStorage.instance.ref().child('filieres/${DateTime.now().millisecondsSinceEpoch}.jpg');
        final uploadTask = storageRef.putFile(_selectedImage!);
        final snapshot = await uploadTask.whenComplete(() {});
        final imageUrl = await snapshot.ref.getDownloadURL();
        return imageUrl;
      } catch (e) {
        throw "Erreur lors du téléchargement de l'image : $e";
      }
    }
    return '';
  }

  /// Méthode pour gérer la création de la filière
  Future<void> createFiliere(BuildContext context) async {
    // Vérification des champs obligatoires
    if (_nameController.text.isEmpty || _sigleController.text.isEmpty) {
      _showErrorDialog(context, "Le nom et la description de la filière sont obligatoires !");
      return;
    }

    try {
      // Vérification de l'image de la filière
      bool imageUploadFailed = false;
      String uploadedImageUrl = "";

   /*   if (_selectedFiliereImage != null) {
        try {
          uploadedImageUrl = await _uploadImageToFirebase();
        } catch (e) {
          print("Erreur lors du téléchargement de l'image de la filière : $e");
          uploadedImageUrl = "";
          imageUploadFailed = true; // Marquer l'échec du téléchargement de l'image
        }
      }*/

      // Créer la filière dans Firestore
      await FirebaseFirestore.instance.collection('Filieres').add({
        'name': _nameController.text,
        'sigle': _sigleController.text,
        'chefDepartement': _chefDepartementController.text,
        'domaine': _domaineController.text,
        'slogan': _sloganController.text,
        'niveau': _selectedNiveaux, // Enregistrer la liste des niveaux sélectionnés
        'description': _descriptionController.text,
        'imageUrl': uploadedImageUrl,
        'createdAt': Timestamp.now(),
      });



      // Afficher un message si l'image de la filière n'a pas pu être téléchargée
      if (imageUploadFailed) {
        if (context.mounted) {
          _showErrorDialog(
            context,
            "La filière a été créée, mais l'image n'a pas pu être téléchargée. Veuillez mettre à jour l'image de la filière ultérieurement.",
          );
        }
      }

      // Naviguer vers l'écran de la liste des filières ou autre écran pertinent
      if (context.mounted) {
          Get.back();
      }
    } catch (e) {
      if (context.mounted) {
        _showErrorDialog(context, "Erreur lors de la création de la filière : ${e.toString()}");
      } else {
        print("Erreur hors contexte valide : $e");
      }
    }
  }


  /// Méthode pour télécharger l'image dans Firebase Storage et mettre à jour la filière
  Future<void> _uploadImageToFirebaseIfNeeded(String filiereId) async {
    if (_selectedImage != null) {
      try {
        final imageUrl = await _uploadImageToFirebase();
        setState(() {
          _uploadedImageUrl = imageUrl;
        });

        // Une fois l'image téléchargée, mettez à jour la filière dans Firestore
        final filiereService = Provider.of<FiliereService>(context, listen: false);

        // Utilisation du Map pour les données mises à jour
        final updatedData = {
          'image': _uploadedImageUrl, // Mettez à jour le champ image avec l'URL
        };

        // Appel à la méthode updateFiliere avec l'ID et les données mises à jour
        await filiereService.updateFiliere(filiereId, updatedData);

      } catch (e) {
        if (context.mounted) {
          _showErrorDialog(context, "Erreur lors du téléchargement de l'image : $e");
        }
      }
    }
  }

  /// Méthode pour afficher un message d'erreur
  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Erreur'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  /// Méthode pour sélectionner et uploader l'image
  Future<void> _pickAndUploadImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });

      // Essayer de télécharger l'image
      await _uploadImageToFirebaseIfNeeded('');
    }
  }


  String? _selectedNiveau;

  final List<String> _niveauOptions = [
    "1ère année",
    "2ème année",
    "3ème année",
    "4ème année",
    "5ème année",
  ];

  // Liste pour stocker les niveaux sélectionnés
  List<String> _selectedNiveaux = [];

// Méthode pour afficher une boîte de dialogue de sélection multiple
  Future<void> _showMultiSelectDialog() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter dialogSetState) {
            return AlertDialog(
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
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("Annuler"),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("Confirmer"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Créer une Filière'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: _pickAndUploadImage,
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey,
                    backgroundImage: _selectedImage != null ? FileImage(_selectedImage!) : null,
                    child: _selectedImage == null
                        ? const Icon(
                      Icons.camera_alt,
                      size: 20,
                      color: Colors.white,
                    )
                        : null,
                  ),
                ),
                const SizedBox(height: 10),
                // Form fields
                MyTextField(
                  controller: _nameController,
                  obscureText: false,
                  hintext: "Nom",
                  myIcon: Icons.text_fields,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Le nom est obligatoire";
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 10),

                MyTextField(
                  controller: _sigleController,
                  obscureText: false,
                  hintext: "Sigle",
                  myIcon: Icons.tag,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Le sigle est obligatoire";
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 10),

                MyTextField(
                  controller: _chefDepartementController,
                  obscureText: false,
                  hintext: "Chef du département",
                  myIcon: Icons.person,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Le chef du département est obligatoire";
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 10),

                MyTextField(
                  controller: _domaineController,
                  obscureText: false,
                  hintext: "Domaine",
                  myIcon: Icons.business,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Le domaine est obligatoire";
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 10),

                MyTextField(
                  controller: _sloganController,
                  obscureText: false,
                  hintext: "Slogan",
                  myIcon: Icons.format_quote,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Le slogan est obligatoire";
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 10),

                MyTextField(
                  controller: _descriptionController,
                  obscureText: false,
                  hintext: "Description",
                  myIcon: Icons.format_quote,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "La description est obligatoire";
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 10),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: GestureDetector(
                    onTap: () async {
                      // Ouvre le dialogue pour la sélection multiple
                      await _showMultiSelectDialog();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.green),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.school, color: Colors.grey),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _selectedNiveaux.isNotEmpty
                                  ? _selectedNiveaux.join(", ")
                                  : "Sélectionner les niveaux",
                              style: TextStyle(
                                color: _selectedNiveaux.isNotEmpty
                                    ? Theme.of(context).colorScheme.primary
                                    : Colors.grey,
                              ),
                            ),
                          ),
                          const Icon(Icons.arrow_drop_down, color: Colors.grey),
                        ],
                      ),
                    ),
                  ),
                ),



                const SizedBox(height: 20),

                _isSubmitting
                    ? const CircularProgressIndicator()
                    : MyButton(
                  text: "S'inscrire",
                  onTap: () => createFiliere(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
