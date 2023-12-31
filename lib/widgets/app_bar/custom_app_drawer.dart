import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:social_media_buttons/social_media_icons.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../presentation/home_adobe_express_one_screen/home_adobe_express_one_screen.dart';
import '../../presentation/my_account_adobe_express_1_one_screen/my_account_adobe_express_1_one_screen.dart';
import '../../presentation/mypets_screen/mypets_screen.dart';
import '../../services/url_launchers.dart' as launch;
import '../../routes/app_routes.dart';
import '../../services/url_launchers.dart';

class CustomDrawer extends StatelessWidget {
  final String? userName = FirebaseAuth.instance.currentUser?.displayName;
  final String? userEmail = FirebaseAuth.instance.currentUser?.email;


  @override
  Widget build(BuildContext context) {
    UrlLauncherUtils urlLauncherUtils = UrlLauncherUtils();

    return Drawer(
      child: Container(
        color: Color(0xFF008C8C),
        child: Column(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color:
                Color(0xFF008C8C), // Customize the header background color
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.person,
                        color: Colors.white,
                        size: 24,
                      ),
                      SizedBox(width: 8),
                      Text(
                        userName ?? 'Guest',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.email,
                        color: Colors.white,
                        size: 18,
                      ),
                      SizedBox(width: 8),
                      Text(
                        userEmail ?? 'guestuser@email.com',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            ListTile(
              title: Text(
                'Home',
                style: TextStyle(fontSize: 14, color: Colors.white),
              ),
              onTap: () {
                if (ModalRoute.of(context)!.settings.name != AppRoutes.homeAdobeExpressOneScreen) {
                  Navigator.pushReplacement(
                    context,
                    AppRoutes.generateRoute(
                      RouteSettings(name: AppRoutes.homeAdobeExpressOneScreen),
                    ),
                  );
                }
                },
            ),
            ListTile(
              title: Text(
                'Search',
                style: TextStyle(fontSize: 14, color: Colors.white),
              ),
              onTap: () {
                if (ModalRoute.of(context)!.settings.name != AppRoutes.searchScreen) {
                  Navigator.pushReplacement(
                    context,
                    AppRoutes.generateRoute(
                      RouteSettings(name: AppRoutes.searchScreen),
                    ),
                  );
                }              // Handle Search tap
              },
            ),
            ListTile(
              title: Text(
                'Pet Profiles',
                style: TextStyle(fontSize: 14, color: Colors.white),
              ),
              onTap: () {
                if (ModalRoute.of(context)!.settings.name != AppRoutes.myPetsScreen) {
                  Navigator.pushReplacement(
                    context,
                    AppRoutes.generateRoute(
                      RouteSettings(name: AppRoutes.myPetsScreen),
                    ),
                  );
                }                // Handle Pet Profiles tap
              },
            ),
            ListTile(
              title: Text(
                'My Account',
                style: TextStyle(fontSize: 14, color: Colors.white),
              ),
              onTap: () {
                if (ModalRoute.of(context)!.settings.name != AppRoutes.myAccountAdobeExpress1OneScreen) {
                  Navigator.pushReplacement(
                    context,
                    AppRoutes.generateRoute(
                      RouteSettings(name: AppRoutes.myAccountAdobeExpress1OneScreen),
                    ),
                  );
                }                // Handle My Account tap
              },
            ),
            // Use an ExpansionTile for 'Help' to display options
            ExpansionTile(
              title: Text('Help', style: TextStyle(fontSize: 14, color: Colors.white)),
              children: [
                ListTile(
                  title: Text('Help Centre', style: TextStyle(fontSize: 10, color: Colors.white)),
                  onTap: () {
                    final Uri helpCenterURL = Uri.parse('https://cmpet.co.uk/index.php/help-centre/');
                    urlLauncherUtils.launchInBrowser(helpCenterURL)
                    ;
                    // Handle 'test 1' selection
                  },
                ),
                ListTile(
                  title: Text(
                    'Email Us: support@cmpet.co.uk',
                    style: TextStyle(fontSize: 10, color: Colors.white),
                  ),
                  onTap: () {
                    urlLauncherUtils.launchEmail('support@cmpet.co.uk');
                    },
                ),
                ListTile(
                  title: Text('Website', style: TextStyle(fontSize: 10, color: Colors.white)),
                  onTap: () {
                    final Uri helpCenterURL = Uri.parse('https://cmpet.co.uk');
                    urlLauncherUtils.launchInBrowser(helpCenterURL);
                    // Handle 'test 1' selection
                  },
                ),
              ],
            ),
            SizedBox(height: 20.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(
                    Icons.facebook,
                    size: 26,
                  ),
                  onPressed: () {
                    // Handle Facebook button press
                    final Uri fbURL = Uri.parse('https://www.facebook.com/people/Can-My-Pet/100064808752362');
                    urlLauncherUtils.launchInBrowser(fbURL);
                  },
                  color: Colors.white,
                ),
                SizedBox(width: 20.0),
                IconButton(
                  icon: Icon(
                    SocialMediaIcons.instagram,
                    size: 26,
                  ),
                  onPressed: () {
                    // Handle Instagram button press
                    final Uri instagramURL = Uri.parse('https://www.instagram.com/canmypetltd');

                    _launchInBrowser(instagramURL);
                  },
                  color: Colors.white,
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

