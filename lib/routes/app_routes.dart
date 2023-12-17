import 'package:flutter/material.dart';
import 'package:cmpets/presentation/food_overview_adobe_express_one_screen/food_overview_adobe_express_one_screen.dart';
import 'package:cmpets/presentation/home_adobe_express_one_screen/home_adobe_express_one_screen.dart';
import 'package:cmpets/presentation/initial_login_adobe_express_one_container_screen/initial_login_adobe_express_one_container_screen.dart';
import 'package:cmpets/presentation/my_account_adobe_express_1_one_screen/my_account_adobe_express_1_one_screen.dart';
import 'package:cmpets/presentation/registration_adobe_express_one_screen/registration_adobe_express_one_screen.dart';
import 'package:cmpets/presentation/mypets_screen/mypets_screen.dart';
import 'package:cmpets/presentation/pet_info_screen/mypet_info_screen.dart';
import 'package:cmpets/presentation/search_screen/search_screen.dart';
import 'package:cmpets/presentation/barcode_screen/barcode_screen.dart';
import 'package:cmpets/presentation/product_ingredients_screen/product_ingredients_screen.dart';
import 'package:cmpets/presentation/ingredient_screen/ingredient_screen.dart';
import 'package:cmpets/presentation/app_navigation_screen/app_navigation_screen.dart';

import '../auth/Auth_provider.dart';

class AppRoutes {
  static const String foodOverviewAdobeExpressOneScreen =
      '/food_overview_adobe_express_one_screen';

  static const String homeAdobeExpressOneScreen =
      '/home_adobe_express_one_screen';

  static const String searchScreen = '/search_screen';

  static const String barcodeScreen = '/barcode_screen';

  static const String productScreen = '/product_screen';

  static const String ingredientScreen = '/ingredient_screen';


  static const String myPetInfoScreen = '/pet_info_screen';

  static const String myPetsScreen = '/mypets_screen';

  static const String initialLoginAdobeExpressOneContainerScreen =
      '/initial_login_adobe_express_one_container_screen';

  static const String myAccountAdobeExpress1OneScreen =
      '/my_account_adobe_express_1_one_screen';

  static const String registrationAdobeExpressOneScreen =
      '/registration_adobe_express_one_screen';

  static const String appNavigationScreen = '/app_navigation_screen';

  static Map<String, WidgetBuilder> routes = {
    foodOverviewAdobeExpressOneScreen: (context) => isAuthenticated()
        ? FoodOverviewAdobeExpressOneScreen(searchResults: {},)
        : InitialLoginAdobeExpressOneContainerScreen(),
    homeAdobeExpressOneScreen: (context) => isAuthenticated()
        ? HomeAdobeExpressOneScreen()
        : InitialLoginAdobeExpressOneContainerScreen(),
    initialLoginAdobeExpressOneContainerScreen: (context) {
      if (isAuthenticated()) {
        return HomeAdobeExpressOneScreen(); // Redirect to home screen
      } else {
        return InitialLoginAdobeExpressOneContainerScreen();
      }
    },
    myAccountAdobeExpress1OneScreen: (context) => isAuthenticated()
        ? MyAccountAdobeExpress1OneScreen()
        : InitialLoginAdobeExpressOneContainerScreen(),
    myPetInfoScreen: (context) => isAuthenticated()
        ? MyPetInfoScreen()
        : InitialLoginAdobeExpressOneContainerScreen(),
    searchScreen: (context) => isAuthenticated()
        ? SearchScreen()
        : InitialLoginAdobeExpressOneContainerScreen(),
    productScreen: (context) => isAuthenticated()
        ? IngredientPage(pageTitle: '', ingredientName: '',)
        : InitialLoginAdobeExpressOneContainerScreen(),
    ingredientScreen: (context) => isAuthenticated()
        ? ProductListPage(productIngredients: [],)
        : InitialLoginAdobeExpressOneContainerScreen(),
    barcodeScreen: (context) => isAuthenticated()
        ? BarcodeScanScreen()
        : InitialLoginAdobeExpressOneContainerScreen(),
    myPetsScreen: (context) => isAuthenticated()
        ? MyPetsScreen()
        : InitialLoginAdobeExpressOneContainerScreen(),
    registrationAdobeExpressOneScreen: (context) =>
        RegistrationAdobeExpressOneScreen(),
    appNavigationScreen: (context) => AppNavigationScreen()
  };


}
