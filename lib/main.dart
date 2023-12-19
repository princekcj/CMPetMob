import 'dart:convert';
import 'dart:developer';

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
        visualDensity: VisualDensity.standard,
        fontFamily: 'CenturyGothic',
      ),
      title: 'cmpets',
      debugShowCheckedModeBanner: false,
      initialRoute: AppRoutes.initialLoginAdobeExpressOneContainerScreen,
      onGenerateRoute: AppRoutes.generateRoute,
      routes: AppRoutes.routes,
    );
  }
}
