import 'dart:convert';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'firebase_options.dart';
import 'package:cmpets/routes/app_routes.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
        inputDecorationTheme: InputDecorationTheme(
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.lightBlue),
          ),
        ),
        visualDensity: VisualDensity.standard,
        fontFamily: 'CenturyGothic',
        textTheme: TextTheme(
          labelLarge: TextStyle(color: Colors.white),
          // Default text color
          labelSmall: TextStyle(color: Colors.white),
          // Default text color
          labelMedium: TextStyle(color: Colors.white),
          // Default text color
          bodySmall: TextStyle(color: Colors.black),
          // Default text color
          bodyMedium: TextStyle(color: Colors.black), // Default text color
        ),
      ),
      title: 'cmpets',
      debugShowCheckedModeBanner: false,
      initialRoute: AppRoutes.initialLoginAdobeExpressOneContainerScreen,
      onGenerateRoute: AppRoutes.generateRoute,
      routes: AppRoutes.routes,
    );
  }
}
