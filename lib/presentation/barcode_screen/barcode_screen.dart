import 'dart:convert';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:cmpets/widgets/app_bar/topappbar.dart' as top_bar;
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/utils/color_constant.dart';
import '../../core/utils/image_constant.dart';
import '../../routes/app_routes.dart';
import '../../services/search_by_barcode.dart';
import '../../widgets/app_bar/custom_app_bar.dart';
import '../../widgets/app_bar/custom_app_drawer.dart';
import '../ingredient_screen/ingredient_screen.dart';
import '../product_ingredients_screen/product_ingredients_screen.dart';
import '../product_text_search/product_text_search.dart';
import '../search_screen/search_screen.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import '../../core/utils/analytics_utils.dart' as analytics_utils;


class BarcodeScanScreen extends StatefulWidget {
  @override
  _BarcodeScanScreenState createState() => _BarcodeScanScreenState();
}

class _BarcodeScanScreenState extends State<BarcodeScanScreen> {
  bool isMenuOpen = false;
  bool isLoading = false;
  String snackBarMessage = '';
  String barcodeResultText = ''; // Clear previous barcode result text
  bool _nativeAdIsLoaded = false;
  bool emailSent = false;
  int emailAttemptCount = 0;
  NativeAd? _nativeAd;
  late String adUnitId; // Replace with your actual AdMob ad unit ID

  @override
  void initState() {
    super.initState();
    // Start fetching the latest posts
    _initGoogleMobileAds();
    if (Platform.isAndroid) {
      setState(() {
        adUnitId = "ca-app-pub-3940256099942544/2247696110";
      });
    } else if (Platform.isIOS) {
      setState(() {
        adUnitId = "ca-app-pub-3940256099942544/3986624511";
      });
    } else {
      throw UnsupportedError("Unsupported platform");
    }


    // Create the ad objects and load ads.
    _nativeAd = NativeAd(
      adUnitId: adUnitId,
      request: AdRequest(),
      listener: NativeAdListener(
        onAdLoaded: (Ad ad) {
          print('$NativeAd loaded.');
          setState(() {
            _nativeAdIsLoaded = true;
          });
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          print('$NativeAd failedToLoad: $error');
          ad.dispose();
        },
        onAdOpened: (Ad ad) => print('$NativeAd onAdOpened.'),
        onAdClosed: (Ad ad) => print('$NativeAd onAdClosed.'),
      ),
      nativeTemplateStyle: NativeTemplateStyle(
        templateType: TemplateType.medium,
        mainBackgroundColor: Colors.white12,
        callToActionTextStyle: NativeTemplateTextStyle(
          size: 16.0,
        ),
        primaryTextStyle: NativeTemplateTextStyle(
          textColor: Colors.black38,
          backgroundColor: Colors.white70,
        ),
      ),
    )..load();
  }

  void toggleMenu() {
    setState(() {
      isMenuOpen = !isMenuOpen;
    });
  }

  List<String> _barcodeResult = [];

  Future<void> _scanBarcode() async {
    setState(() {
      isLoading = true;
    });

    String barcodeResult = await FlutterBarcodeScanner.scanBarcode(
      '#008c8c',
      'Cancel',
      true,
      ScanMode.BARCODE,
    );

    //String barcodeResult = '3017620429487';

    if (!mounted) return;

    List<String> productIngredients = [];

    final barcodeData = await json.decode(barcodeResult);

    if (barcodeResult == '-1') {
      setState(() {
        isLoading = false;
        snackBarMessage = 'Cancelled Scan';
      });

      // Show a red snackbar
      final snackBar = SnackBar(
        content: Text(snackBarMessage, style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.red,
      );

      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } else if (barcodeData is Map<String, dynamic>) {
      setState(() {
        isLoading = false;
        snackBarMessage = 'Product not found';
      });

      // Show a red snackbar
      final snackBar = SnackBar(
        content: Text(snackBarMessage, style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.red,
      );

      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } else if (barcodeResult.isNotEmpty && barcodeResult != '-1' ) {
      try {
        // Product found, proceed to fetch ingredients
        productIngredients = await searchProductIngredientsByBarcode(barcodeResult);
        for (String input in productIngredients) {
          capitalizeFirstLetter(input);
        }
        setState(() {
          _barcodeResult = productIngredients;
          isLoading = false;
        });
        analytics_utils.logScanEvent(FirebaseAuth.instance.currentUser);

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductListPage(
              productIngredients: _barcodeResult,
            ),
          ),
        );
      } catch (e) {
        // Handle the exception
        setState(() {
          isLoading = false;
          snackBarMessage = 'Error finding product: Barcode $barcodeResultText has no available product data. Please try using the Our Ingredients Search';
          barcodeResultText = barcodeResult; // Clear previous barcode result text
        });
        // Show a red snackbar
        final snackBar = SnackBar(
          content: Text(snackBarMessage, style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.red,
        );

        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        analytics_utils.logScanEvent(FirebaseAuth.instance.currentUser);


        try {
          if (!emailSent && emailAttemptCount < 1) {
            emailAttemptCount++; // Increment the email attempt count
            await sendNoBarcodeDataEmail(barcodeResultText);
            emailSent = true; // Mark that the email has been sent
          } // Send email
        } catch (error) {
          // Handle the error gracefully, e.g., log it
        }
        // You can also show an error message to the user if needed.

        _showProductSearchConfirmation();
      }
    } else {
      setState(() {
        isLoading = false;
        snackBarMessage = 'Product not found';
      });

      // Show a red snackbar
      final snackBar = SnackBar(
        content: Text(snackBarMessage, style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.red,
      );

      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  @override
  Widget build(BuildContext context) {
    analytics_utils.logScreenUsageEvent('Barcode');

    return Scaffold(
      resizeToAvoidBottomInset: false, // fluter 2.x
      endDrawer: CustomDrawer(),
      appBar: top_bar.CustomTopAppBar(
        Enabled: false,
        onTapArrowLeft: (context) {
          Navigator.pop(context);
        },
        onMenuPressed: toggleMenu,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch, // Align widgets to the start
        children: [
          if (_nativeAdIsLoaded) buildAdWidgetContainer(),
          if (!_nativeAdIsLoaded) Container(
            height: 200,
            child: Center(
              child: CircularProgressIndicator(color: Color(0xFF008C8C)),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 30),
                ElevatedButton(
                  onPressed: isLoading ? null : _scanBarcode,
                  child: isLoading
                      ? CircularProgressIndicator(color: Color(0xFF008C8C), strokeWidth: 2.0) // Show progress bar when loading
                      : Text('SCAN BARCODE', style: TextStyle(color: Colors.white) ,),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF008C8C),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0), // Adjust the value as needed
                      )),
                ),
                // Display the barcode result text
                SizedBox(height: 60),
                Row(
                  children: [
                    Expanded(
                      child: Divider(
                        color: Colors.grey,
                        height: 3,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        'OR',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Divider(
                        color: Colors.grey,
                        height: 3,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 60),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF008C8C),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0), // Adjust the value as needed
                      )),
                  onPressed: () {
                    if (ModalRoute.of(context)!.settings.name != AppRoutes.searchScreen) {
                      Navigator.pushReplacement(
                        context,
                        AppRoutes.generateRoute(
                          RouteSettings(name: AppRoutes.searchScreen),
                        ),
                      );
                    }
                  },
                  child: Text('SEARCH INGREDIENT', style: TextStyle(color: Colors.white)),
                ),
                SizedBox(height: 60),
              ],
            ),
          ),
        ],
      ),
      extendBody: true,
      floatingActionButton: Container(height: 80.0, width:80.0, child: FittedBox(child: FloatingActionButton(
        backgroundColor: Color(0xFF008C8C), // Set the background color to blue
        child: Image.asset(ImageConstant.searchbutton, width: 40, height: 40),
        shape: RoundedRectangleBorder(
          side: BorderSide(color: ColorConstant.fromHex('#a3ccff'), width: 2.0),
          borderRadius:
          BorderRadius.circular(28.0), // Adjust the border radius as needed
        ),
        onPressed: () {
          // Check if the current route is not already the search route

          if (ModalRoute.of(context)!.settings.name != AppRoutes.barcodeScreen) {
            Navigator.pushReplacement(
              context,
              AppRoutes.generateRoute(
                RouteSettings(name: AppRoutes.barcodeScreen),
              ),
            );
          }

        },
      ),),),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: CustomAppBar(
        height: 100,
        actions: [
          // Additional widgets, if any
        ],
        onButtonPressed: (index) {
          // Handle button press based on index
        },
      ),
    );
  }

  Future<void> sendNoBarcodeDataEmail(String Barcode) async {
    final email = Message()
      ..from = Address('ingredient.admin@cmpet.co.uk', 'admin')
      ..recipients.add('ingredient.admin@cmpet.co.uk')
      ..subject = 'No Data for Barcode: $Barcode'
      ..text = 'No data available for Barcode: $Barcode';

    final smtpServer = SmtpServer('smtp.ionos.co.uk', username: 'ingredient.admin@cmpet.co.uk', password: 'M1ss1ng_Ingred13nts_CMP3T?#', port: 587);

    try {
      await send(email, smtpServer);
    } catch (e) {
      print('Error sending email: $e');
    }
  }

  String capitalizeFirstLetter(String input) {
    if (input.isEmpty) {
      return input;
    }

    List<String> words = input.split(' ');
    for (int i = 0; i < words.length; i++) {
      if (words[i].isNotEmpty) {
        words[i] = words[i][0].toUpperCase() + words[i].substring(1);
      }
    }

    return words.join(' ');
  }
  // Function to build the AdWidget container
  Widget buildAdWidgetContainer() {
    // You can customize the ad placement here based on your design
    return Container(
      width: double.infinity,
      height: 200,
      child: AdWidget(ad: _nativeAd!), // Assuming _nativeAd is your NativeAd instance
    );
  }

  Future<InitializationStatus> _initGoogleMobileAds() {
    // TODO: Initialize Google Mobile Ads SDK
    return MobileAds.instance.initialize();
  }

  Future<void> _showProductSearchConfirmation() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Would you like to use the product search instead?'),
          actions: <Widget>[
            TextButton(
              child: Text('No'),
              onPressed: () {
                Navigator.of(context).pop();
                // Handle 'No' action if needed
              },
            ),
            TextButton(
              child: Text('Yes'),
              onPressed: () {


                Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => productSearchScreen(),
                ),
              );
                // Handle 'Yes' action if needed
                // For example, you can call the product search method here
              },
            ),
          ],
        );
      },
    );
  }

}
