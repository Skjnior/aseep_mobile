/*
import 'package:aseep/components/my_drawer.dart';
import 'package:aseep/screens/filiere/filiereDetails_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Importer le provider
import '../models/filiere.dart';
import '../services/filiere_service.dart';
import '../components/filiereTile.dart';  // Import du widget FiliereTile

class WelcomScreen extends StatelessWidget {
  WelcomScreen({super.key});

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.grey,
        centerTitle: true,
        title: Text("Acceuil"),
      ),

      body: _buildFilierList(context),
    );
  }

  // Utilisation d'un StreamBuilder pour écouter les changements dans la collection "filieres" de Firestore
  Widget _buildFilierList(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('Filieres').snapshots(),
      // Flux des documents dans la collection "Filieres"
      builder: (context, snapshot) {
        // Gestion des erreurs
        if (snapshot.hasError) {
          return const Center(child: Text("Erreur de chargement"));
        }

        // Affichage d'un indicateur de chargement lorsque la connexion est en attente
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        // Vérification si des données sont disponibles
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("Aucune filière disponible"));
        }

        // Traitement des données pour les transformer en liste de widgets
        var filieres = snapshot.data!.docs.map((doc) {
          return doc.data() as Map<String, dynamic>;
        }).toList();

        return RefreshIndicator(
          onRefresh: () async {
            // Rafraîchissement des données, Firestore gère déjà les mises à jour en temps réel via StreamBuilder
          },
          child: ListView.builder(
            itemCount: filieres.length,
            // Pas besoin de vérification de null ici, car la liste est déjà remplie
            itemBuilder: (context, index) {
              final filiere = filieres[index];

              // On compte le nombre de niveaux dans la liste "niveau"
              int nombreNiveaux = (filiere['niveau'] as List).length;

              return FiliereTile(
                name: filiere['name'] ?? 'Nom non disponible',
                slogan: filiere['slogan'] ?? 'Slogan non disponible',
                description: filiere['description'] ?? 'Description non disponible',
                nombreNiveaux: nombreNiveaux,
                // Nombre de niveaux calculé
                imageUrl: filiere['imageUrl'] ?? 'URL de l\'image non disponible',
                  onTap: () async {
                    // Appel à la méthode getFiliereById de FiliereService
                    final filiereService = Provider.of<FiliereService>(context, listen: false);
                    Map<String, dynamic>? filiereDetails = await filiereService.getFiliereById(filiere['id']);

                    if (filiereDetails != null) {
                      // Afficher les détails de la filière ou naviguer vers une nouvelle page avec ces informations
                      MaterialPageRoute(
                        builder: (context) => FiliereDetailsScreen(
                          name: filiereDetails['name'] ?? 'Nom non disponible',
                          slogan: filiereDetails['slogan'] ?? 'Slogan non disponible',
                          description: filiereDetails['description'] ?? 'Description non disponible',
                          nombreNiveaux: filiereDetails['nombreNiveaux'] ?? 0, // Assurez-vous que cette clé existe dans le service
                          imageUrl: filiereDetails['imageUrl'], // Peut être null, donc c'est OK
                        ),
                      );
                    } else {
                      print('Filière non trouvée');
                    }
                  }


              );
            },
          ),
        );
      },
    );
  }
}
*/
