import 'dart:convert';
import 'dart:developer';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cmpets/presentation/barcode_screen/barcode_screen.dart';
import 'package:cmpets/presentation/home_adobe_express_one_screen/home_adobe_express_one_screen.dart';
import 'package:cmpets/presentation/initial_login_adobe_express_one_container_screen/initial_login_adobe_express_one_container_screen.dart';
import 'package:cmpets/presentation/search_screen/search_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'auth/Auth_provider.dart';
import 'core/utils/allAssetImg.dart';
import 'core/utils/trial_tracking_utils.dart';
import 'core/utils/trial_util.dart';
import 'firebase_options.dart';
import 'package:cmpets/routes/app_routes.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';

Future<void> main() async {
  final binding = WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseFirestore.instance.settings =
      Settings(
          persistenceEnabled: true,
      );
  runApp(ProviderScope(child: MyApp()));

// Initialize Firebase Analytics
  FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  analytics.logAppOpen();

  // thing to add
  List<String> testDeviceIds = ['33BE2250B43518CCDA7DE426D04EE231'];
  await MobileAds.instance.initialize().then(
    (InitializationStatus status) {
      MobileAds.instance.updateRequestConfiguration(
        RequestConfiguration(
          tagForChildDirectedTreatment:
              TagForChildDirectedTreatment.unspecified,
          testDeviceIds: testDeviceIds,
        ),
      );
      debugPrint('Initialization done: ${status.adapterStatuses}');
    },
  );

  FlutterError.onError = (errorDetails) {
    FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
  };
  // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Precache pet images
    ImageCachingUtils.precachePetImages(context);

    // Create an instance of TimeTrackingUtils
    TimeTrackingUtils timeTrackingUtils = TimeTrackingUtils();

    // Check if the user is authenticated
    bool userAuthenticated = isAuthenticated();

    // Variable to hold the home widget
    Widget homeWidget;

    if (userAuthenticated) {
      // Get the current user
      User? currentUser = FirebaseAuth.instance.currentUser;

      // Call the function to update trial time flag if needed
      bool trialTimeCompleted = timeTrackingUtils.updateTrialTimeFlagIfNeeded(currentUser);

      // If trial time is not completed, show a popup if needed
      if (!trialTimeCompleted) {
        // Calculate remaining days in the trial period
        int remainingDays = calculateRemainingTrialDays(currentUser);

        // Check if popup needs to be shown
        bool showPopup = shouldShowPopup();

        // If remaining days are less than 10 and the popup has not been shown for the current date, show the popup
        if (remainingDays < 5 && showPopup) {
          // Show the popup
          showTrialPopup(context, remainingDays);
        }
      }

      // Set the home widget to BarcodeScanScreen for authenticated users
      homeWidget = BarcodeScanScreen();
    } else {
      // Set the home widget to InitialLoginAdobeExpressOneContainerScreen for non-authenticated users
      homeWidget = InitialLoginAdobeExpressOneContainerScreen();
    }

    // Return MaterialApp with the home widget
    return MaterialApp(
      home: homeWidget,
      theme: ThemeData(
        // Your theme data here...
      ),
      title: 'cmpets',
      debugShowCheckedModeBanner: false,
      initialRoute: AppRoutes.initialLoginAdobeExpressOneContainerScreen,
      onGenerateRoute: AppRoutes.generateRoute,
      routes: AppRoutes.routes,
    );
  }
}
