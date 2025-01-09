import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class IntroductionScreen3 extends StatelessWidget {
  const IntroductionScreen3({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          color: Colors.green,
        ),
        Positioned(
          bottom: 40,
          left: 0,
          right: 0,
          child: Center(
            child: SizedBox(
              width: 100.0,
              height: 200.0,
              child: Shimmer.fromColors(
                baseColor: Theme.of(context).colorScheme.primary, // Couleur de base en bas
                highlightColor: Theme.of(context).colorScheme.tertiary, // Couleur lumineuse en haut
                direction: ShimmerDirection.btt, // Direction de bas vers haut
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.keyboard_arrow_up_outlined,
                      size: 40,
                    ),
                    Icon(
                      Icons.keyboard_arrow_up_outlined,
                      size: 40,
                    ),
                    Icon(
                      Icons.keyboard_arrow_up_outlined,
                      size: 40,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
