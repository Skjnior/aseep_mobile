import 'package:flutter/material.dart';



/// Light mode
ThemeData lightMode = ThemeData(
  colorScheme: ColorScheme.light(
    background: Colors.grey.shade300,
    primary: Colors.grey.shade500,
    secondary: Colors.grey.shade200,
    tertiary: Colors.white,
    inversePrimary: Colors.grey.shade900,
  ),
);



/// Dark mode
ThemeData darkMode = ThemeData(
    colorScheme: ColorScheme.dark(
      background: Colors.grey.shade900,
      primary: Colors.grey.shade600,
      secondary: Color.fromARGB(255, 57, 57, 57),
      tertiary: Colors.grey.shade800,
      inversePrimary: Colors.grey.shade300,
    )
);