import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

class FiliereDetailsScreen extends StatelessWidget {
  final String description;
  final String slogan;
  final String name;
  final int nombreNiveaux;
  final String? imageUrl;

  FiliereDetailsScreen({
    Key? key,
    required this.description,
    required this.slogan,
    required this.name,
    required this.nombreNiveaux,
    this.imageUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Définir l'image à afficher, soit l'image de l'utilisateur, soit l'image par défaut
    String imageToDisplay = imageUrl ?? 'https://picsum.photos/seed/picsum/200/300';

    return Scaffold(
      appBar: AppBar(
        title: Text(name),
        backgroundColor: Theme.of(context).colorScheme.secondary,
        elevation: 4,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image de la filière en grand
              ClipOval(
                child: Image.network(
                  imageToDisplay,
                  width: 150,
                  height: 150,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Image.network(
                      'https://picsum.photos/seed/picsum/200/300',
                      width: 150,
                      height: 150,
                      fit: BoxFit.cover,
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              // Nom de la filière
              Text(
                name,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 10),
              // Nombre de niveaux
              Text(
                "$nombreNiveaux ${nombreNiveaux == 1 ? 'Classe' : 'Classes'}",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 20),
              // Description de la filière
              Text(
                description,
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 20),
              // Slogan animé
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: TypewriterAnimatedTextKit(
                  text: ['"${slogan}"'], // Ajouter les guillemets autour du slogan
                  textStyle: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  speed: const Duration(milliseconds: 100),
                ),
              ),
              const SizedBox(height: 30),
              // Bouton pour revenir en arrière
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: Text(
                  "Retour",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
