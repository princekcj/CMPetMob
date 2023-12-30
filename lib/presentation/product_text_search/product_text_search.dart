import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:cmpets/core/app_export.dart';
import 'package:cmpets/widgets/app_bar/topappbar.dart' as top_bar;
import 'package:flutter_svg/flutter_svg.dart';

import '../../api/api_services.dart';
import '../../core/utils/analytics_utils.dart' as analytics_utils;
import '../../env.dart';
import '../../services/search_by_barcode.dart';
import '../../widgets/app_bar/custom_app_bar.dart';
import '../../widgets/app_bar/custom_app_drawer.dart';
import '../food_overview_adobe_express_one_screen/food_overview_adobe_express_one_screen.dart';
import '../product_ingredients_screen/product_ingredients_screen.dart';

class productSearchScreen extends StatefulWidget {
  const productSearchScreen({Key? key}) : super(key: key);

  @override
  _SearchAdobeExpressOneScreenState createState() =>
      _SearchAdobeExpressOneScreenState();
}


class _SearchAdobeExpressOneScreenState
    extends State<productSearchScreen> {

  List<Map<String, dynamic>> searchResults = [];
  TextEditingController searchController = TextEditingController();


  bool isMenuOpen = false;

  void toggleMenu() {
    setState(() {
      isMenuOpen = !isMenuOpen;
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    analytics_utils.logScreenUsageEvent('Search');

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
      body: Container(
        padding: EdgeInsets.symmetric(vertical: kToolbarHeight, horizontal: 16.0), // Add top and horizontal padding
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Search Bar with Search Icon
            TextField(
              controller: searchController, // Assign the controller here
              decoration: InputDecoration(
                hintText: 'Search...',
                prefixIcon: Icon(Icons.search),
                suffixIcon: TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: Color(0xFF008C8C),
                  ),
                  onPressed: () async {
                    final products_list = await searchProductsWithIngredients(searchController.text);
                    setState(() {
                      searchResults = products_list;
                    });

                  },
                  child: Text(
                    'Search',
                    style: TextStyle(
                      color: Colors.white, // Set the text color to black
                    ),
                  ),
                ),
              ),
              onChanged: (value) async {
                final products_list = await searchProductsWithIngredients(searchController.text);
                setState(() {
                  searchResults = products_list;
                });


              },
            ),
            SizedBox(height: 16), // Add some space between the search bar and the result list
            // Search Results List
            Expanded(
              child: ListView.builder(
                itemCount: searchResults.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () async {
                      analytics_utils.logSearchEvent();
                      final ingredients_list = searchResults[index]['ingredients'];
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProductListPage(
                            productIngredients: ingredients_list,
                          ),
                        ),
                      );
                    },
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0), // Adjust the horizontal spacing as needed
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        alignment: Alignment.center,
                        child: Text(searchResults[index]['productName']),
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 100,)
          ],
        ),
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
}
