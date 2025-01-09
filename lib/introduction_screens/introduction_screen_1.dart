import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:story_view/controller/story_controller.dart';
import 'package:story_view/widgets/story_view.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class IntroductionScreen1 extends StatefulWidget {
  const IntroductionScreen1({super.key});

  @override
  State<IntroductionScreen1> createState() => _IntroductionScreen1State();
}

class _IntroductionScreen1State extends State<IntroductionScreen1> {
  final StoryController controller = StoryController();

  final int durationValeu = 7; // Durée de chaque élément

  @override
  Widget build(BuildContext context) {
    final List<StoryItem> storyItems = [
      StoryItem(
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 150, // Hauteur dynamique en fonction de 'hauteur'
              width: 350,
              margin: const EdgeInsets.only(left: 20, top: 80, right: 20),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20), // Coins arrondis
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20), // Applique les bords arrondis à l'image
                child: Image.asset(
                  "assets/images/ourLogo.jpg",
                  fit: BoxFit.cover, // Ajuste l'image pour couvrir toute la taille du conteneur
                ),
              ),
            ),
          ],
        ),
        duration: Duration(seconds: durationValeu), // Utilisation de la valeur de 'durationValeu'
      ),
      StoryItem(
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 150, // Hauteur dynamique en fonction de 'hauteur'
              width: 350,
              margin: const EdgeInsets.only(left: 20, top: 80, right: 20),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20), // Coins arrondis
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20), // Applique les bords arrondis à l'image
                child: Image.asset(
                  "assets/images/moi.jpeg",
                  fit: BoxFit.cover, // Ajuste l'image pour couvrir toute la taille du conteneur
                ),
              ),
            ),
          ],
        ),
        duration: Duration(seconds: durationValeu), // Utilisation de la valeur de 'durationValeu'
      ),
      StoryItem(
        Container(
          height: 150, // Hauteur dynamique en fonction de 'hauteur'
          width: 350,
          margin: const EdgeInsets.only(left: 20, top: 80, right: 20),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.asset(
              "assets/images/moi2.jpeg",
              fit: BoxFit.cover,
            ),
          ),
        ),
        duration: Duration(seconds: durationValeu),
      ),
      StoryItem(
        Container(
          height: 150, // Hauteur dynamique en fonction de 'hauteur'
          width: 350,
          margin: const EdgeInsets.only(left: 20, top: 80, right: 20),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.asset(
              "assets/images/souda.jpeg",
              fit: BoxFit.cover,
            ),
          ),
        ),
        duration: Duration(seconds: durationValeu),
      ),
    ];

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned(
            child: StoryView(
              indicatorColor: Theme.of(context).colorScheme.secondary,
              storyItems: storyItems,
              controller: controller,
              repeat: true,
              progressPosition: ProgressPosition.top,
            ),
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
                  direction: ShimmerDirection.btt, // Effet de bas en haut
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
          Positioned(
            bottom: 10,
            left: 0,
            right: 0,
            child: SmoothPageIndicator(
              controller: PageController(),
              count: storyItems.length,
              effect: WormEffect(
                dotHeight: 8,
                dotWidth: 8,
                spacing: 16,
                dotColor: Colors.white.withOpacity(0.5),
                activeDotColor: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
