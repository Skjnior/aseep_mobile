import 'dart:math';
import 'package:aseep/services/chat/chat_services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aseep/screens/chat/chat_screen.dart';
import 'package:intl/intl.dart';
import '../components/myAppBar.dart';

class MyProfileScreen extends StatefulWidget {
  MyProfileScreen({
    super.key,
  });

  @override
  _MyProfileScreenState createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends State<MyProfileScreen> {
  final MyServices _chatService = MyServices();
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _birthDateController = TextEditingController();

  // Formater la date
  String formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);  // Format jour/mois/année
  }

  Future<void> _saveChanges(String userId) async {
    if (_formKey.currentState!.validate()) {
      // Récupérer les nouvelles valeurs du formulaire
      String firstName = _firstNameController.text;
      String lastName = _lastNameController.text;
      String birthDate = _birthDateController.text;

      try {
        await FirebaseFirestore.instance.collection('Users').doc(userId).update({
          'firstName': firstName,
          'lastName': lastName,
          'birthDate': birthDate,
        });

        setState(() {
          // Revenir à l'état non modifiable
        });
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Modifications enregistrées')));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Erreur lors de l\'enregistrement des modifications')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: MyAppBar(
        text: 'Profile',
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('Users').doc(FirebaseAuth.instance.currentUser?.uid).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Erreur lors de la récupération des données.'));
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('Aucune donnée disponible.'));
          }

          final userData = snapshot.data!.data() as Map<String, dynamic>;

          _firstNameController.text = userData['firstName'];
          _lastNameController.text = userData['lastName'];

          // Vérification si la date de naissance est un Timestamp
          DateTime? birthDate;
          if (userData['birthDate'] is Timestamp) {
            // Convertir le Timestamp en DateTime si c'est un Timestamp
            birthDate = (userData['birthDate'] as Timestamp).toDate();
          } else if (userData['birthDate'] is String) {
            // Si c'est une chaîne, la convertir en DateTime si possible
            birthDate = DateTime.tryParse(userData['birthDate']);
          }

          // Si birthDate est null, tu peux lui affecter une valeur par défaut, ou laisser la gestion dans l'UI.
          birthDate ??= DateTime.now();

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Image de profil
                CircleAvatar(
                  radius: 60,
                  backgroundImage: const AssetImage("assets/images/moi.jpeg"),
                  onBackgroundImageError: (_, __) => Icon(
                    Icons.person,
                    size: 60,
                    color: Colors.grey.shade400,
                  ),
                ),
                const SizedBox(height: 20),

                // Nom complet
                Text(
                  "${userData['firstName']} ${userData['lastName']}",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.inversePrimary,
                  ),
                ),
                Column(
                  children: [
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 150),
                      child: Divider(
                        color: Theme.of(context).colorScheme.inversePrimary,
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 100),
                      child: Divider(
                        color: Theme.of(context).colorScheme.inversePrimary,
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 70),
                      child: Divider(
                        color: Theme.of(context).colorScheme.inversePrimary,
                      ),
                    ),

                  ],
                ),
                const SizedBox(height: 10),

                Container(
                  margin: EdgeInsets.symmetric(horizontal: 10),
                  child: Center(
                    child:  Row(
                      children: [
                        Text(
                            "Informations",
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.inversePrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.bold
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                // Informations utilisateur sous forme de carte
                Card(
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  color: Theme.of(context).colorScheme.secondary,
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.email, color: Colors.blueAccent),
                            const SizedBox(width: 10),
                            Text(
                              "Email: ${userData['email']}",
                              style: TextStyle(
                                fontSize: 16,
                                color: Theme.of(context).colorScheme.inversePrimary,
                              ),
                            ),
                          ],
                        ),
                        Divider(
                          color: Theme.of(context).colorScheme.inversePrimary,
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            const Icon(Icons.perm_identity, color: Colors.blueAccent),
                            const SizedBox(width: 10),
                            Text(
                              "Nom: ${userData['firstName']} ${userData['lastName']}",
                              style: TextStyle(
                                fontSize: 16,
                                color: Theme.of(context).colorScheme.inversePrimary,
                              ),
                            ),
                          ],
                        ),
                        Divider(
                          color: Theme.of(context).colorScheme.inversePrimary,
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            const Icon(Icons.cake, color: Colors.blueAccent),
                            const SizedBox(width: 10),
                            Text(
                              "Date: ${formatDate(birthDate)}",
                              style: TextStyle(
                                fontSize: 16,
                                color: Theme.of(context).colorScheme.inversePrimary,
                              ),
                            ),
                          ],
                        ),
                        Divider(
                          color: Theme.of(context).colorScheme.inversePrimary,
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            const Icon(Icons.numbers, color: Colors.blueAccent),
                            const SizedBox(width: 20),
                            Text(
                              "Matricule: ${userData['matricule']}",
                              style: TextStyle(
                                fontSize: 16,
                                color: Theme.of(context).colorScheme.inversePrimary,
                              ),
                            ),
                          ],
                        ),
                        Divider(
                          color: Theme.of(context).colorScheme.inversePrimary,
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            const Icon(Icons.school, color: Colors.blueAccent),
                            const SizedBox(width: 10),
                            Text(
                              "Niveau: ${userData['niveaux']}",
                              style: TextStyle(
                                fontSize: 16,
                                color: Theme.of(context).colorScheme.inversePrimary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 40,),
                // Bouton Modifier pour ouvrir le BottomSheet
                Container(
                  child: Center(
                    child: Column(
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.secondary,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () {
                            // Ouvrir BottomSheet pour modifier le profil
                            showModalBottomSheet(
                              backgroundColor: Theme.of(context).colorScheme.background,
                              context: context,
                              builder: (BuildContext context) {
                                return Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Form(
                                    key: _formKey,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        TextFormField(
                                          controller: _firstNameController,
                                          decoration: const InputDecoration(labelText: 'Prénom'),
                                        ),
                                        TextFormField(
                                          controller: _lastNameController,
                                          decoration: const InputDecoration(labelText: 'Nom'),
                                        ),
                                        TextFormField(
                                          controller: _birthDateController,
                                          decoration: const InputDecoration(labelText: 'Date de naissance'),
                                        ),
                                        const SizedBox(height: 20),
                                       Row(
                                         children: [
                                           ElevatedButton(
                                             style: ElevatedButton.styleFrom(
                                               backgroundColor: Theme.of(context).colorScheme.secondary,
                                               padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                               shape: RoundedRectangleBorder(
                                                 borderRadius: BorderRadius.circular(10),
                                               ),
                                             ),
                                             onPressed: () {
                                               _saveChanges(userData['uid']);
                                               Navigator.pop(context);
                                             },
                                             child: Text(
                                               'Enregistrer',
                                               style: TextStyle(
                                                   color: Theme.of(context).colorScheme.inversePrimary
                                               ),
                                             ),
                                           ),
                                           const SizedBox(width: 10),
                                           ElevatedButton(
                                             style: ElevatedButton.styleFrom(
                                               backgroundColor: Theme.of(context).colorScheme.secondary,
                                               padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                               shape: RoundedRectangleBorder(
                                                 borderRadius: BorderRadius.circular(10),
                                               ),
                                             ),
                                             onPressed: () => Navigator.pop(context),
                                             child: const Text(
                                               'Annuler',
                                               style: TextStyle(
                                                   color: Colors.red
                                               ),
                                             ),
                                           ),
                                         ],
                                       )
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                          child: Text(
                            'Modifier',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.inversePrimary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10,),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.secondary,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () => Navigator.pop(context),
                          child: const Text(
                            'Se deconnecter',
                            style: TextStyle(
                                color: Colors.red
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      )

    );
  }
}
