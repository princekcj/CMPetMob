import 'package:flutter/material.dart';
import 'package:social_media_buttons/social_media_icons.dart';

import 'custom_app_drawer.dart';

class CustomTopAppBar extends StatefulWidget implements PreferredSizeWidget {
  final Function()? onMenuPressed;
  final Function(BuildContext)? onTapArrowLeft;
  final bool Enabled;

  const CustomTopAppBar({
    Key? key,
    this.onMenuPressed,
    this.onTapArrowLeft,
    required this.Enabled,
  }) : super(key: key);

  @override
  _CustomTopAppBarState createState() => _CustomTopAppBarState();

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}

class _CustomTopAppBarState extends State<CustomTopAppBar>
    with SingleTickerProviderStateMixin {
  bool isMenuOpen = false;


  late AnimationController _animationController;
  late Animation<Offset> _animation;

  @override
  void initState() {
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 250),
    );
    _animation = Tween<Offset>(
      begin: Offset(1.0, 0.0), // Off-screen to the right
      end: Offset.zero, // On-screen
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.decelerate),
    );
    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleMenu() {
    setState(() {
      isMenuOpen = !isMenuOpen;
    });

    if (isMenuOpen) {
      Scaffold.of(context).openEndDrawer(); // Open the drawer
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (isMenuOpen) {
          _toggleMenu();
        }
      },
      child: Stack(
        children: [
          Positioned.fill(
            child: SlideTransition(
              position: _animation, // Use the CustomDrawer widget here
            ),
          ),
          AnimatedContainer(
            duration: Duration(milliseconds: 100),
            height: isMenuOpen
                ? MediaQuery.of(context).size.height * 0.75
                : kToolbarHeight + MediaQuery.of(context).padding.top,
            decoration: BoxDecoration(
              color: Color(0xFF008C8C),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (Navigator.canPop(context) && widget.Enabled)
                        Visibility(
                          visible: Navigator.canPop(context),
                          child: IconButton(
                            icon: Icon(Icons.arrow_back),
                            onPressed: () {
                              Navigator.maybePop(context);
                            },
                            color: Colors.white,
                          ),
                        )
                      else
                        Container(),
                      // An empty container to take up space when the arrow is hidden
                      IconButton(
                        icon: Icon(Icons.menu),
                        onPressed: _toggleMenu,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
