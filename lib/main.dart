import 'dart:async';
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
import 'package:flutter_downloader/flutter_downloader.dart';
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
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:firebase_analytics/observer.dart';

Future<void> deliverProduct(PurchaseDetails purchaseDetails, User user) async {
  // IMPORTANT!! Always verify purchase details before delivering the product.
  // Reference to the user document in Firestore
  DocumentReference<Map<String, dynamic>> userDoc =
  FirebaseFirestore.instance.collection('users').doc(user.uid);

  // Set the initial 'purchased_full_version' field to false
  await userDoc.set({'purchased_full_version': true});
}

Future<bool> _verifyPurchase(PurchaseDetails purchaseDetails) {
  // IMPORTANT!! Always verify a purchase before delivering the product.
  // For the purpose of an example, we directly return true.
  return Future<bool>.value(true);
}

void _listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) {
  User? currentUser = FirebaseAuth.instance.currentUser;
   bool hasActiveSubscription = false;

  purchaseDetailsList.forEach((PurchaseDetails purchaseDetails) async {
    if (purchaseDetails.status == PurchaseStatus.pending) {
    } else {
      if (purchaseDetails.status == PurchaseStatus.error) {

      } else if (purchaseDetails.status == PurchaseStatus.purchased ||
          purchaseDetails.status == PurchaseStatus.restored) {
        bool valid = await _verifyPurchase(purchaseDetails);
        if (valid) {
          deliverProduct(purchaseDetails, currentUser!);
          if (purchaseDetails.productID == '1yr') {
            hasActiveSubscription = true;
          }
        } else {

        }
      }
      if (purchaseDetails.pendingCompletePurchase) {
        await InAppPurchase.instance
            .completePurchase(purchaseDetails);
      }
    }
  });
  if (!hasActivePurchase) {
      DocumentReference<Map<String, dynamic>> userDoc =
    FirebaseFirestore.instance.collection('users').doc(currentUser.uid);  
    await userDoc.set({'purchased_full_version': false}, SetOptions(merge: true));
  }
}

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

  // Initialize in-app purchases
  late StreamSubscription<List<PurchaseDetails>> _subscription;
  final iapConnection = InAppPurchase.instance;

  final bool available = await iapConnection.isAvailable();
  if (available) {
    final purchaseUpdated = iapConnection.purchaseStream;
    _subscription =
        purchaseUpdated.listen((List<PurchaseDetails> purchaseDetailsList) {
          _listenToPurchaseUpdated(purchaseDetailsList);
        }, onDone: () {
          _subscription.cancel();
        }, onError: (Object error) {
          // handle error here.
        });
  }

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
      bool showPopup = shouldShowPopup();


      // If trial time is not completed, show a popup if needed
      if (trialTimeCompleted) {
        homeWidget = FutureBuilder<int>(
          future: calculateRemainingTrialDays(currentUser),
          builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasData && snapshot.data! <= 0) {
                // Handle the asynchronous nature of isFullVersionPurchased
                timeTrackingUtils.isFullVersionPurchased(currentUser).then((bool isPurchased) {
                  // Rest of your code where you use isPurchased
                  // Make sure to handle the logic dependent on isPurchased here
                  if (!isPurchased) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      showTrialEndedPopup(context, snapshot.data!, currentUser!);
                    });
                  }
                });
              }
              return BarcodeScanScreen();
            } else {
              return CircularProgressIndicator();
            }
          },
        );
      } else if (!trialTimeCompleted && showPopup){
        // Set the home widget to BarcodeScanScreen for authenticated users
        homeWidget = FutureBuilder<int>(
          future: calculateRemainingTrialDays(currentUser),
          builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasData && snapshot.data! < 7) {
                timeTrackingUtils.isFullVersionPurchased(currentUser).then((bool isPurchased) {
                  // Rest of your code where you use isPurchased
                  // Make sure to handle the logic dependent on isPurchased here
                  if (!isPurchased) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      showTrialPopup(context, snapshot.data!);
                    });
                  };
                });
              }
              return BarcodeScanScreen();
            } else {
              return CircularProgressIndicator();
            }
          },
        );
      } else {
        // Set the home widget to BarcodeScanScreen for authenticated users
        homeWidget = BarcodeScanScreen();
      }
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
