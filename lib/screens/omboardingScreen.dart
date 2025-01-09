import 'package:aseep/introduction_screens/introcduction_screen_3.dart';
import 'package:aseep/introduction_screens/introduction_screen_1.dart';
import 'package:aseep/introduction_screens/introduction_screen_2.dart';
import 'package:aseep/introduction_screens/introduction_screen_4.dart';
import 'package:aseep/services/auth/auth_gate.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OmbordingScreen extends StatefulWidget {
  const OmbordingScreen({super.key});

  @override
  State<OmbordingScreen> createState() => _OmbordingScreenState();
}

class _OmbordingScreenState extends State<OmbordingScreen> {
  // To control the pageview
  PageController _pageController = PageController();

  // To navigate pop on the last page
  bool onLastPage = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Page view for the onboarding
          PageView(
            scrollDirection: Axis.vertical,
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                onLastPage = (index == 3); // Last page reached
              });
            },
            children: [
              IntroductionScreen1(),
              const IntroductionScreen2(),
              const IntroductionScreen3(),
              const IntroductionScreen4(),
            ],
          ),

          // Dot indicators
          Container(
            margin: const EdgeInsets.only(top: 50),
            alignment: const Alignment(0, 0.75),
            child: onLastPage
                ? GestureDetector(
              // Done action
              onTap: () {
                // Navigate to AuthGate screen after onboarding
                Get.off(() => const AuthGate());
              },
              child: Container(
                padding: EdgeInsets.all(15),
                decoration: BoxDecoration(
                  border: Border.all(),
                  shape: BoxShape.circle,
                ),
                child: Text(
                    "OK",
                  style: TextStyle(
                      fontSize: 24,
                      color: Colors.black
                  ),
                ),
              ),
            )
                : GestureDetector(
              // Next action
              onTap: () {
                _pageController.nextPage(
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeIn,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
