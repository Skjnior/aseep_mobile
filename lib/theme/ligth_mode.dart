import 'package:flutter/material.dart';



/// Light mode
ThemeData lightMode = ThemeData(
  colorScheme: ColorScheme.light(
    background: Color(0xFF2983A6),
    primary: Color(0xFFFFFBF8).withOpacity(.3),
    secondary: Color(0xFF122640).withOpacity(.2),
    tertiary: Color(0xFFFFFFFF),
    inversePrimary: Color(0xFFFFFFFF).withOpacity(.9),
  ),
);



/// Dark mode
ThemeData darkMode = ThemeData(
  colorScheme: ColorScheme.light(
    background: Color(0xFF122640),
    primary: Color(0xFFFFFFFF).withOpacity(.3),
    secondary: Color(0xFFFFFFFF).withOpacity(.2),
    tertiary: Color(0xFFFFFBF8).withOpacity(.3),
    inversePrimary: Color(0xFFFFFFFF).withOpacity(.9),
  ),
);