import 'dart:math';

import 'package:flutter/material.dart';

class MyUserTileFromeHomeScreen extends StatelessWidget {
  final String text;
  final String name;
  final String firstName;
  final String? imageUrl; // Ajouter une propriété imageUrl pour la photo de l'utilisateur
  final void Function()? onTap;
  final void Function()? onTapPro;

  MyUserTileFromeHomeScreen({
    super.key,
    required this.text,
    required this.name,
    required this.firstName,
    required this.onTap,
    required this.onTapPro,
    this.imageUrl, // Initialiser l'image si elle est fournie
  });

  @override
  Widget build(BuildContext context) {
    // Définir l'image à afficher, soit l'image de l'utilisateur, soit l'image par défaut
    String imageToDisplay = imageUrl ?? 'assets/images/ourLogo.jpg';
    final Random random = Random();
    return GestureDetector(
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondary,
          borderRadius: BorderRadius.circular(15),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
        child: Column(
          children: [
            ListTile(
              leading: GestureDetector(
                onTap: onTapPro,
                child: ClipOval(
                  child: Image.network(
                    imageToDisplay,
                    width: 40,
                    height: 40,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Image.network(
                        "https://picsum.photos/seed/${random.nextInt(1000)}/300/300",
                        width: 40,
                        height: 40,
                        fit: BoxFit.cover,
                      );
                    },
                  ),
                ),
              ),
              title: Text(
                "$firstName $name",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.inversePrimary,
                ),
              ),
              subtitle: Text(
                text,
                style: TextStyle(
                  overflow: TextOverflow.ellipsis,
                  color: Theme.of(context).colorScheme.inversePrimary,
                ),
              ),
              trailing: GestureDetector(
                onTap: onTap,
                child: Icon(
                  Icons.navigate_next_outlined,
                  color: Theme.of(context).colorScheme.inversePrimary,
                ),
              ),
            ),
            Divider(),
            // Image principale
            Container(
              height: 400, // Hauteur pour mieux gérer l'espace
              width: double.infinity,
              margin: const EdgeInsets.all(10),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.network(
                  imageToDisplay,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Image.network(
                      'https://picsum.photos/seed/${random.nextInt(1000)}/300/300',
                      fit: BoxFit.cover,
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
