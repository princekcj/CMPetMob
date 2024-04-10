import 'package:cmpets/core/app_export.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';


import '../../routes/app_routes.dart';
import '../product_text_search/product_text_search.dart';

class ItemNotFoundSlideScreen extends StatelessWidget {
  final List<PageViewModel> listPagesViewModel = [
    PageViewModel(
      title: "It’s not you…or Us.",
      body: "Unfortunately, during a products lifecycle, their barcodes can change, and national database isn’t updated. But don’t worry you can still find your item, just use our manual search instead and type what you’re looking for.",
      image: Image.asset(ImageConstant.slide7, height: 450),
      decoration: const PageDecoration(
        imagePadding: EdgeInsets.only(top: 65.0),
      ),
    ),
    PageViewModel(
      title: "",
      body: "Try typing your product instead (on screen showing typing e.g. Mars Bar). ",
      image: Image.asset(ImageConstant.slide5),
    ),
    PageViewModel(
      title: "",
      body: " Choose your product and enjoy results as usual!",
      image: Image.asset(ImageConstant.slide4),
    ),
    // Add more pages as needed
  ];

  @override
  Widget build(BuildContext context) {
    String? _userId = FirebaseAuth.instance.currentUser?.uid;


    return IntroductionScreen(
      pages: listPagesViewModel,
      showSkipButton: true,
      skip: const Icon(Icons.skip_next),
      next: const Text("Next"),
      done: const Text("Done", style: TextStyle(fontWeight: FontWeight.w700)),
      onDone: () async {
        // Handle action when Done button is pressed
        String _preferencesKey = '$_userId';
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setBool('$_preferencesKey-item-not-found', true);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => productSearchScreen(),
          ),
        );
      },
      onSkip: () async {
        // Handle action when Skip button is pressed
        String _preferencesKey = '$_userId';
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setBool('$_preferencesKey-item-not-found', true);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => productSearchScreen(),
          ),
        );
      },
      dotsDecorator: DotsDecorator(
        size: const Size.square(10.0),
        activeSize: const Size(20.0, 10.0),
        activeColor: Color(0xFF008C8C),
        color: Colors.black26,
        spacing: const EdgeInsets.symmetric(horizontal: 3.0),
        activeShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25.0),
        ),
      ),
    );
  }
}
