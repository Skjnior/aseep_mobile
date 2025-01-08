import 'dart:math';

import 'package:flutter/material.dart';

class UserTile extends StatelessWidget {
  final String text;
  final String name;
  final String firstName;
  final String? imageUrl;  // Ajouter une propriété imageUrl pour la photo de l'utilisateur
  final void Function()? onTap;
  final void Function()? onTapPro;

  UserTile({
    super.key,
    required this.text,
    required this.name,
    required this.firstName,
    required this.onTap,
    required this.onTapPro,
    this.imageUrl,  // Initialiser l'image si elle est fournie
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
        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 25),
        padding: const EdgeInsets.only(left: 8,  top: 8, bottom: 8),
        child: ListTile(
          leading: GestureDetector(
            onTap: onTapPro,
            child: ClipOval(  // Utilisation de ClipOval pour rendre l'image ronde
              child: Image.network(
                imageToDisplay,
                width: 40,  // Vous pouvez ajuster la taille de l'image
                height: 40,
                fit: BoxFit.cover,  // S'assurer que l'image couvre bien la zone
                errorBuilder: (context, error, stackTrace) {
                  // Si l'image réseau échoue, afficher l'image par défaut
                  return Image.network(
                    "https://picsum.photos/seed/${random.nextInt(1000)}/300/300",
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  );
                },
              ),
            ),
          ),
          title: Text(
              "${firstName} ${name}",
            style:  TextStyle(
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
              child: Container(
                height: 90,
                width: 50,
                  child:  Icon(
                      Icons.navigate_next_outlined,
                    color: Theme.of(context).colorScheme.inversePrimary,
                  ),
              ),
          ),
        ),
      ),
    );
  }
}
