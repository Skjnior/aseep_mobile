import 'package:flutter/material.dart';

class MyButton extends StatelessWidget {
  final String text;
  final void Function()? onTap;
  MyButton({
    super.key,
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
     child: Stack(
       children: [
         Container(
           width: 250,
           decoration: BoxDecoration(
             color: Theme.of(context).colorScheme.secondary,
             borderRadius: BorderRadius.circular(25),
           ),
           padding: const EdgeInsets.all(25),
           margin: const EdgeInsets.symmetric(horizontal: 25),
           child: Center(
             child: Text(
                 text,
               style: const TextStyle(
                 color: Color(0xFFF29849),
                 fontSize: 16,
                 fontWeight: FontWeight.bold
               ),
             ),
           ),
         ),

         Positioned(
           right: 50,
           top: -30,
           child: Container(
             padding: const EdgeInsets.all(70),
             decoration: BoxDecoration(
                 color: Colors.transparent,
                 shape: BoxShape.circle,
                 border: Border.all(width: 15, color: const Color(0xFF122745))
             ),
           ),
         ),

         Positioned(
           left: 40,
           top: 28,
           child: Container(
             padding: const EdgeInsets.all(15),
             decoration: BoxDecoration(
                 color: Colors.transparent,
                 shape: BoxShape.circle,
                 border: Border.all(width: 10, color: const Color(0xFF122640))
             ),
           ),
         ),
       ],
     ),
    );
  }
}