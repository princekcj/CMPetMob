import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:cmpets/core/app_export.dart';
import 'package:cmpets/widgets/app_bar/topappbar.dart' as top_bar;
import 'package:flutter_svg/flutter_svg.dart';

import '../../api/api_services.dart';
import '../../core/utils/analytics_utils.dart' as analytics_utils;
import '../../env.dart';
import '../../widgets/app_bar/custom_app_bar.dart';
import '../../widgets/app_bar/custom_app_drawer.dart';
import '../food_overview_adobe_express_one_screen/food_overview_adobe_express_one_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  _SearchAdobeExpressOneScreenState createState() =>
      _SearchAdobeExpressOneScreenState();
}


class _SearchAdobeExpressOneScreenState
    extends State<SearchScreen> {
  ApiService apiService = ApiService(Env.key1, Env.key2); // Replace with your API key

  List<String> searchResults = [];
  List<Map<String, dynamic>> searchResultsObject = [];
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
                      final response = await apiService.searchByName(searchController.text);
                      final List<dynamic> responseData = json.decode(response);

                      // Parse the response data and extract appropriate objects and titles
                      final List<Map<String, dynamic>> parsedResults = [];
                      responseData.forEach((ingredient) {
                        parsedResults.add({
                          'name': ingredient['name'],
                          'titles': {
                            'description': ingredient['description'],
                            'dog': ingredient['dog_description'],
                            'dog_value': ingredient['dog'],
                            'cat': ingredient['cat_description'],
                            'cat_value': ingredient['cat'],
                            'parrot': ingredient['parrot_description'],
                            'parrot_value': ingredient['parrot'],
                            'rabbit': ingredient['rabbit_description'],
                            'rabbit_value': ingredient['rabbit'],
                            'bearded_dragon': ingredient['bearded_dragon_description'],
                            'bearded_dragon_value': ingredient['bearded_dragon'],
                            'guinea_pig': ingredient['guinea_pig_description'],
                            'guinea_pig_value': ingredient['guinea_pig'],
                            'hamster': ingredient['hamster_description'],
                            'hamster_value': ingredient['hamster'],
                          },
                        });
                      });

                      setState(() {
                        searchResults = parsedResults.map<String>((ingredient) => ingredient['name'].toString()).toList();
                        searchResultsObject = parsedResults;
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
                  final response = await apiService.searchByName(value);
                  final List<dynamic> responseData = json.decode(response);

                  // Parse the response data and extract appropriate objects and titles
                  final List<Map<String, dynamic>> parsedResults = [];
                  responseData.forEach((ingredient) {
                    parsedResults.add({
                      'name': ingredient['name'],
                      'titles': {
                        'description': ingredient['description'],
                        'dog': ingredient['dog_description'],
                        'dog_value': ingredient['dog'],
                        'cat': ingredient['cat_description'],
                        'cat_value': ingredient['cat'],
                        'parrot': ingredient['parrot_description'],
                        'parrot_value': ingredient['parrot'],
                        'rabbit': ingredient['rabbit_description'],
                        'rabbit_value': ingredient['rabbit'],
                        'bearded_dragon': ingredient['bearded_dragon_description'],
                        'bearded_dragon_value': ingredient['bearded_dragon'],
                        'guinea_pig': ingredient['guinea_pig_description'],
                        'guinea_pig_value': ingredient['guinea_pig'],
                        'hamster': ingredient['hamster_description'],
                        'hamster_value': ingredient['hamster'],
                      },
                    });
                  });

                  setState(() {
                    searchResults = parsedResults.map<String>((ingredient) => ingredient['name'].toString()).toList();
                    searchResultsObject = parsedResults;
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
                      onTap: () {
                        analytics_utils.logSearchEvent();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FoodOverviewAdobeExpressOneScreen(
                              pageTitle: searchResultsObject[index]['name'],
                              searchResults: searchResultsObject[index],
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
                          child: Text(searchResultsObject[index]['name']),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      extendBody: true,
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xFF008C8C), // Set the background color to blue
        child: Image.asset(ImageConstant.searchbutton, width: 40, height: 40),
        shape: RoundedRectangleBorder(
          side: BorderSide(color: ColorConstant.fromHex('#a3ccff'), width: 2.0),
          borderRadius: BorderRadius.circular(30.0), // Adjust the border radius as needed
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
      ),
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
