import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cmpets/core/app_export.dart';

import '../../presentation/barcode_screen/barcode_screen.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final double height;
  final List<Widget>? actions;
  final Function(int)? onButtonPressed;

  CustomAppBar({
    Key? key,
    required this.height,
    this.actions,
    this.onButtonPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      color: Color(0xFF008C8C),
      shape: const CircularNotchedRectangle(),
      notchMargin: 5,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            icon: Image.asset(ImageConstant.homebutton),
            onPressed: () {
              // Check if the current route is not already the home route
              if (ModalRoute.of(context)!.settings.name != AppRoutes.homeAdobeExpressOneScreen) {
                Navigator.pushReplacementNamed(context, AppRoutes.homeAdobeExpressOneScreen);
              }
            },
            color: Colors.black,
            iconSize: 52,
          ),
          SizedBox(width: 60), // Adjust the width to your desired spacing
          IconButton(
            icon: Image.asset(ImageConstant.pawsbutton),
            onPressed: () {
              // Check if the current route is not already the myPets route
              if (ModalRoute.of(context)!.settings.name != AppRoutes.myPetsScreen) {
                Navigator.pushReplacementNamed(context, AppRoutes.myPetsScreen);
              }
            },
            color: Colors.white,
            iconSize: 52,
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(height);
}
