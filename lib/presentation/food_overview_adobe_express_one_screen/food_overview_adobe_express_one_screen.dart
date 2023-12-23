import 'dart:convert';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cmpets/core/app_export.dart';
import 'package:cmpets/widgets/app_bar/topappbar.dart';
import 'package:cmpets/widgets/app_bar/custom_app_bar.dart';
import 'package:cmpets/widgets/app_bar/topappbar.dart' as top_bar;
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/utils/analytics_utils.dart' as analytics_utils;
import '../../services/pets_utils.dart';
import '../../widgets/app_bar/custom_app_drawer.dart';

class FoodOverviewAdobeExpressOneScreen extends StatefulWidget {
  final String? pageTitle;
  final Map<String, dynamic> searchResults;

  FoodOverviewAdobeExpressOneScreen({
    Key? key,
    this.pageTitle,
    required this.searchResults,
  }) : super(key: key);

  @override
  _FoodOverviewAdobeExpressOneScreenState createState() =>
      _FoodOverviewAdobeExpressOneScreenState();
}

class _FoodOverviewAdobeExpressOneScreenState
    extends State<FoodOverviewAdobeExpressOneScreen> {
  late Future<List<Map<String, String>>> jsonData;
  late List<String> presentPets = [];
  late List<Map<String, String>> jsonResults;
  bool showMore = false;
  int personalTrueCount = 0;

  @override
  void initState() {
    super.initState();
    jsonData = _initializeJsonResults();
  }

  late final List<String> petTypes;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<List<Map<String, String>>> _initializeJsonResults() async {
    List<Map<String, String>> tempJsonResults = [];
    jsonResults = [];

    final dynamic titles = widget.searchResults['titles'];

    // Extract additional data from the JSON here
    final String petName = widget.searchResults['name'];
    final String ingredientDescription =
        titles['description'].toString(); // Cast to String
    final String dogDescription = titles['dog'].toString(); // Cast to String
    final String dogValue = titles['dog_value'].toString(); // Cast to String
    final String catDescription = titles['cat'].toString(); // Cast to String
    final String catValue = titles['cat_value'].toString(); // Cast to String
    final String parrotDescription =
        titles['parrot'].toString(); // Cast to String
    final String parrotValue =
        titles['parrot_value'].toString(); // Cast to String
    final String rabbitDescription =
        titles['rabbit'].toString(); // Cast to String
    final String rabbitValue =
        titles['rabbit_value'].toString(); // Cast to String
    final String beardedDragonDescription =
        titles['bearded_dragon'].toString(); // Cast to String
    final String beardedDragonValue =
        titles['bearded_dragon_value'].toString(); // Cast to String
    final String guineaPigDescription =
        titles['guinea_pig'].toString(); // Cast to String
    final String guineaPigValue =
        titles['guinea_pig_value'].toString(); // Cast to String
    final String hamsterDescription =
        titles['hamster'].toString(); // Cast to String
    final String hamsterValue =
        titles['hamster_value'].toString(); // Cast to String

    print(widget.searchResults);
    print(_getImageBasedOnTitles('dog', dogValue));

    final Map<String, String> dogData = {
      'header': widget.pageTitle ?? 'Unknown',
      'left': ImageConstant.charles,
      // You can change this to the appropriate image
      'right': _getImageBasedOnTitles('dog', dogValue),
      'petName': petName,
      'petType': 'dog',
      'Description': dogDescription,
      'ingredientDescription': ingredientDescription,
      'Value': dogValue,
    };

    final Map<String, String> catData = {
      'header': widget.pageTitle ?? 'Unknown',
      'left': ImageConstant.cat, // You can change this to the appropriate image
      'right': _getImageBasedOnTitles('cat', catValue),
      'petName': petName,
      'petType': 'cat',
      'Description': catDescription,
      'ingredientDescription': ingredientDescription,
      'Value': catValue,
    };

    final Map<String, String> parrotData = {
      'header': widget.pageTitle ?? 'Unknown',
      'left': ImageConstant.parrot,
      // You can change this to the appropriate image
      'right': _getImageBasedOnTitles('parrot', parrotValue),
      'petName': petName,
      'petType': 'parrot',
      'Description': parrotDescription,
      'ingredientDescription': ingredientDescription,
      'Value': parrotValue,
    };

    final Map<String, String> rabbitData = {
      'header': widget.pageTitle ?? 'Unknown',
      'left': ImageConstant.rabbit,
      // You can change this to the appropriate image
      'right': _getImageBasedOnTitles('rabbit', rabbitValue),
      'petName': petName,
      'petType': 'rabbit',
      'Description': rabbitDescription,
      'ingredientDescription': ingredientDescription,
      'Value': rabbitValue,
    };

    final Map<String, String> beardedDragonData = {
      'header': widget.pageTitle ?? 'Unknown',
      'left': ImageConstant.dragon,
      // You can change this to the appropriate image
      'right': _getImageBasedOnTitles('bearded_dragon', beardedDragonValue),
      'petName': petName,
      'petType': 'bearded_dragon',
      'Description': beardedDragonDescription,
      'Value': beardedDragonValue,
    };

    final Map<String, String> guineaPigData = {
      'header': widget.pageTitle ?? 'Unknown',
      'left': ImageConstant.guinea,
      // You can change this to the appropriate image
      'right': _getImageBasedOnTitles('guinea_pig', guineaPigValue),
      'petName': petName,
      'petType': 'guinea_pig',
      'Description': guineaPigDescription,
      'ingredientDescription': ingredientDescription,
      'Value': guineaPigValue,
    };

    final Map<String, String> hamsterData = {
      'header': widget.pageTitle ?? 'Unknown',
      'left': ImageConstant.hamster,
      // You can change this to the appropriate image
      'right': _getImageBasedOnTitles('hamster', hamsterValue),
      'petName': petName,
      'petType': 'hamster',
      'Description': hamsterDescription,
      'ingredientDescription': ingredientDescription,
      'Value': hamsterValue,
    };

    jsonResults.add(dogData);
    jsonResults.add(catData);
    jsonResults.add(parrotData);
    jsonResults.add(rabbitData);
    jsonResults.add(beardedDragonData);
    jsonResults.add(guineaPigData);
    jsonResults.add(hamsterData);

    print("this is old results $jsonResults");


    // Reorder tempJsonResults based on presentPets only if presentPets is not empty
    final userId = _auth.currentUser?.uid;
    jsonResults = await PetUtils.updateJsonResultsWithFirestoreImages(
      jsonResults,
      userId!,
      widget.pageTitle,
    );

    print("Before Reordering: $jsonResults");

    jsonResults.sort((a, b) {
      final bool isPersonalA = a['personal'] == 'true';
      final bool isPersonalB = b['personal'] == 'true';

      if (isPersonalA && !isPersonalB) {
        return -1; // Move item with personal = true to the front
      } else if (!isPersonalA && isPersonalB) {
        return 1; // Move item with personal = true to the front
      } else {
        return 0;
      }
    });

// Count the number of items in jsonResults with ['personal'] == 'true'
    setState(() {
      personalTrueCount = jsonResults.where((item) => item['personal'] == 'true').length;

    });

    print("Number of items with ['personal'] == 'true': $personalTrueCount");

    print("After Reordering: $jsonResults");
    return jsonResults;
  }

  Future<List<String>> _fetchPetTypes() async {
    final user = _auth.currentUser;

    if (user != null) {
      final userId = user.uid;
      final petTypesResult = await PetUtils.getPetTypesForUser(userId);

      if (petTypesResult != null) {
        petTypes = petTypesResult;
        print('User has the following pet types: $petTypes');
        return petTypes;
      } else {
        print('Failed to fetch pet types.');
        return [];
      }
    } else {
      print('User is not authenticated.');
      return [];
    }
  }

  String _getImageBasedOnTitles(String petType, String petValue) {
    if (petType == 'dog') {
      if (petValue == '1') {
        return ImageConstant.yellowpaw;
      } else if (petValue == '2') {
        return ImageConstant.greenpaw;
      }
    } else if (petType == 'cat') {
      if (petValue == '1') {
        return ImageConstant.yellowpaw;
      } else if (petValue == '2') {
        return ImageConstant.greenpaw;
      }
    } else if (petType == 'parrot') {
      if (petValue == '1') {
        return ImageConstant.yellowpaw;
      } else if (petValue == '2') {
        return ImageConstant.greenpaw;
      }
    } else if (petType == 'rabbit') {
      if (petValue == '1') {
        return ImageConstant.yellowpaw;
      } else if (petValue == '2') {
        return ImageConstant.greenpaw;
      }
    } else if (petType == 'bearded_dragon') {
      if (petValue == '1') {
        return ImageConstant.yellowpaw;
      } else if (petValue == '2') {
        return ImageConstant.greenpaw;
      }
    } else if (petType == 'guinea_pig') {
      if (petValue == '1') {
        return ImageConstant.yellowpaw;
      } else if (petValue == '2') {
        return ImageConstant.greenpaw;
      }
    } else if (petType == 'hamster') {
      if (petValue == '1') {
        return ImageConstant.yellowpaw;
      } else if (petValue == '2') {
        return ImageConstant.greenpaw;
      }
    }
    return ImageConstant.redpaw; // Default value for other cases
  }

  @override
  Widget build(BuildContext context) {
    analytics_utils.logScreenUsageEvent('Search_ingredient');
    return Scaffold(
      resizeToAvoidBottomInset: false, // fluter 2.x
      endDrawer: CustomDrawer(),
      appBar: CustomTopAppBar(
        Enabled: true,
        onTapArrowLeft: (context) {
          Navigator.pop(context);
        },
      ),
      body: FutureBuilder(
        future: jsonData,
        // Assuming you've defined jsonData as a Future<List<Map<String, String>>>
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: Color(0xFF008C8C)));
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            int lenInUse;
            print("person num is $personalTrueCount");
            if (personalTrueCount == 0) {
              lenInUse = jsonResults.length;
            } else {
              lenInUse = personalTrueCount;
            }

            return SingleChildScrollView(
              child: Column(
                children: [
                  // Header with the title 'Peanuts'
                  buildHeader(widget.pageTitle ?? 'Food Header'),

                  // Iterable rectangles with margin between them
                  FractionallySizedBox(
                    widthFactor: 0.8,
                    child: Column(
                      children: [
                        ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: showMore ? jsonResults.length : lenInUse,
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: () {
                                final String description = jsonResults[index]
                                        ['Description'] ??
                                    'Default Description';
                                final String ingredientDescription =
                                    jsonResults[index]
                                            ['ingredientDescription'] ??
                                        'Default Description';
                                _showPopupDialog(
                                    context,
                                    description,
                                    ingredientDescription,
                                    jsonResults[index]['header']!);
                              },
                              child: Container(
                                margin: EdgeInsets.symmetric(vertical: 10.0),
                                child:
                                    buildIterableRectangle(jsonResults[index]),
                              ),
                            );
                          },
                        ),
                        if (lenInUse < jsonResults.length)
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                showMore = !showMore;
                              });
                            },
                            child: Container(
                              margin: EdgeInsets.only(top: 16.0, bottom: 8.0),
                              child: Text(
                                showMore
                                    ? 'Show My Pets Only'
                                    : 'See Other Animals',
                                style: TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  SizedBox(height: 130.0,)
                ],
              ),
            );
          }
        },
      ),
      extendBody: true,
      floatingActionButton: Container(height: 100.0, width:100.0, child: FittedBox(child: FloatingActionButton(
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

  void _showPopupDialog(BuildContext context, String? description,
      String? ingredientDescription, String Title) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: Container(
            height: 340.0,
            padding: EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                    child: Text(
                  'Ingredient Advice',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
                )),
                SizedBox(height: 10.0),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 100,
                        padding: EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Center(
                          child: Text(
                            (ingredientDescription == null ||
                                    ingredientDescription == '')
                                ? Title
                                : ingredientDescription,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20.0),
                Container(
                  height: 140,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      // Adjust the horizontal padding as needed
                      child: Text(description ?? 'Full Info Text'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget buildHeader(String title) {
    return Container(
      padding: EdgeInsets.all(16.0),
      alignment: Alignment.center,
      child: Text(
        title,
        style: TextStyle(
            color: Colors.grey, fontSize: 18.0, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget buildIterableRectangle(Map<String, String> images) {
    return Container(
      height: 80.0,
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 14.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.black,
                width: 2,
              ),
            ),
              child: ClipOval(
                child: images['left'] != null && images['left']!.startsWith('https')
                    ? CachedNetworkImage(
                  imageUrl: images['left']!, // Use the left image URL from JSON
                  placeholder: (context, url) => CircularProgressIndicator(),
                  fit: BoxFit.cover,
                )
                    : Image.asset(
                  images['left']!, // Use the left image path from JSON
                  fit: BoxFit.cover,
                ),
              ),
          ),
          Text('Click for more info',
              style: TextStyle(
                  fontStyle: FontStyle.italic,
                  fontSize: 12.0,
                  fontWeight: FontWeight.bold)),
          Image.asset(
            images['right']!,
            // Use the right image path from JSON
          ),
        ],
      ),
    );
  }
}
