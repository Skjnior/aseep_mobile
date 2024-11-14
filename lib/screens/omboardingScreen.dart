import 'package:aseep/introduction_screens/introcduction_screen_3.dart';
import 'package:aseep/introduction_screens/introduction_screen_1.dart';
import 'package:aseep/introduction_screens/introduction_screen_2.dart';
import 'package:aseep/introduction_screens/introduction_screen_4.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import 'auth/login_screen.dart';
import 'home_screen.dart';

class OmbordingScreen extends StatefulWidget {
  const OmbordingScreen({super.key});

  @override
  State<OmbordingScreen> createState() => _OmbordingScreenState();
}

class _OmbordingScreenState extends State<OmbordingScreen> {

  // to controlle the pageview
  PageController _pageController = PageController();

  // to navigate pop on the last page
  bool onLastPage = false;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          /// Page view for the omboarding
          PageView(
            controller: _pageController,
            onPageChanged: (index){
              setState(() {
                onLastPage = (index == 3);
              });
            },
            children: const [
              IntroductionScreen1(),
              IntroductionScreen2(),
              IntroductionScreen3(),
              IntroductionScreen4(),
            ],
          ),
          /// Dot indicatiors
          Container(
            alignment: Alignment(0, 0.75),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GestureDetector(
                  /// action
                  onTap: (){
                    _pageController.jumpToPage(3);
                  },
                  child: Text(
                    "Skip",
                  ),
                ),

                /// Dot indicator
                SmoothPageIndicator(controller: _pageController, count: 4),

                /// Next or Done
                onLastPage
                    ? GestureDetector(
                  /// action
                  onTap: (){
                    // Navigator.push(context, MaterialPageRoute(builder: (context) => HomeScreen(),));
                    // Get.off(() => LoginScreen());
                  },
                  child: Text(
                      "Done",
                  ),
                )
                : GestureDetector(
                  /// action
                  onTap: (){
                    _pageController.nextPage(
                      duration: Duration(milliseconds: 500),
                      curve: Curves.easeIn,
                    );
                  },
                  child: Text(
                    "Next",
                  ),
                ),

              ],
            ),
          ),
        ],
      ),
    );
  }
}
