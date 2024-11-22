import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';

class FiliereTile extends StatefulWidget {
  final String description;
  final String slogan;
  final String name;
  final int nombreNiveaux;
  final String? imageUrl;
  final void Function()? onTap;

  FiliereTile({
    super.key,
    required this.description,
    required this.slogan,
    required this.name,
    required this.nombreNiveaux,
    this.imageUrl,
    this.onTap,
  });

  @override
  _FiliereTileState createState() => _FiliereTileState();
}

class _FiliereTileState extends State<FiliereTile> with TickerProviderStateMixin {
  Color _splashColor = Colors.amber; // Couleur initiale du splash

  @override
  Widget build(BuildContext context) {
    // Définir l'image à afficher, soit l'image de l'utilisateur, soit l'image par défaut
    String imageToDisplay = widget.imageUrl ?? 'assets/images/ourLogo.jpg';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 25),
      child: Material(
        color: Theme.of(context).colorScheme.secondary,
        borderRadius: BorderRadius.circular(15),
        child: Container(
          child: InkWell(
            onTap: () {
              // Change la couleur du splash de manière dynamique
              setState(() {
                _splashColor = _splashColor == Colors.amber ? Colors.blue : Colors.amber; // Alterne entre 2 couleurs
              });
              // Appeler la fonction onTap si elle est définie
              if (widget.onTap != null) {
                widget.onTap!();
              }
            },
            splashColor: _splashColor, // Utilisation de la couleur dynamique
            borderRadius: BorderRadius.circular(15), // Rayon de bordure
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Image affichée en cercle
                      ClipOval(
                        child: Image.network(
                          imageToDisplay,
                          width: 50,  // Taille de l'image
                          height: 50,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Image.asset(
                              'assets/images/ourLogo.jpg', // Image par défaut en cas d'erreur
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 15),
                      // Nom de la filière et nombre de classes
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              widget.name,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            Text(
                              "${widget.nombreNiveaux} ${widget.nombreNiveaux == 1 ? "Classe" : "Classes"}",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Description de la filière
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Text(
                      widget.description,
                      maxLines: 2,
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.primary,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Slogan animé
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: TypewriterAnimatedTextKit(
                      text: ['"${widget.slogan}"'], // Ajouter les guillemets autour du slogan
                      textStyle: TextStyle(
                        fontSize: 16, // Ajuster la taille du texte ici
                        fontWeight: FontWeight.bold, // Rendre le texte plus affirmatif
                        color: Theme.of(context).colorScheme.primary,
                        overflow: TextOverflow.ellipsis, // S'il y a trop de texte, on l'abrège
                      ),
                      speed: const Duration(milliseconds: 100), // Ajuster la vitesse de l'animation de machine à écrire
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
