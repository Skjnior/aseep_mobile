import 'package:flutter/material.dart';


class MyAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String text;
  MyAppBar({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      iconTheme: IconThemeData(
        color: Theme.of(context).colorScheme.tertiary,
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
      foregroundColor: Colors.grey,
      centerTitle: true,
      title:  Text(
        text,
        style: TextStyle(
          color: Theme.of(context).colorScheme.tertiary,
        ),
      ),
    );
  }
  // Définir la taille préférée de la barre d'application
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}