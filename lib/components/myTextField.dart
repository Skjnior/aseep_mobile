import 'package:flutter/material.dart';

class MyTextField extends StatelessWidget {
  final String hintext;
  late IconData? myIcon;
  final TextEditingController controller;
  final bool obscureText;
  MyTextField({
    super.key,
    required this.hintext,
    required this.myIcon,
    required this.obscureText,
    required this.controller,
    required String? Function(dynamic value) validator,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: TextField(
        obscureText: obscureText,
        controller: controller,
        decoration: InputDecoration(
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Theme.of(context).colorScheme.tertiary),
              borderRadius: BorderRadius.circular(15)
            ),
            fillColor: Theme.of(context).colorScheme.secondary,
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
            ),
            filled: true,
            hintText: hintext,
            hintStyle: TextStyle(color: Theme.of(context).colorScheme.inversePrimary),
            prefixIcon: Icon(
              myIcon,
            )
        ),
      ),
    );
  }
}