import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:cmpets/widgets/app_bar/topappbar.dart' as top_bar;
import '../../api/api_services.dart';
import '../../core/utils/color_constant.dart';
import '../../core/utils/image_constant.dart';
import '../../routes/app_routes.dart';
import '../../widgets/app_bar/custom_app_bar.dart';
import '../../core/utils/analytics_utils.dart' as analytics_utils;
import '../../widgets/app_bar/custom_app_drawer.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

class IngredientPage extends StatefulWidget {
  final String pageTitle;
  final String ingredientName;

  IngredientPage({
    required this.pageTitle,
    required this.ingredientName,
  });

  @override
  _IngredientPageState createState() => _IngredientPageState();
}

class _IngredientPageState extends State<IngredientPage> {
  bool emailSent = false;
  int emailAttemptCount = 0;
  late List<Map<String, String>> jsonResults;
  ApiService apiService = ApiService(
      'https://cmpetapi.cmpet.co.uk',
      'your_api_key_1'); // Replace with your API key

  Future<void> _initializeJsonResults() async {
    jsonResults = [];
    final Map<String, dynamic> searchResults;
    // Use your API service to fetch ingredient details
    if (emailSent && emailAttemptCount >= 3) {
      // You can set a limit to the number of email attempts
      return;
    }

    try {
      searchResults =
      await fetchIngredientDetails(widget.ingredientName);
      final dynamic titles = searchResults['titles'];

      // Extract additional data from the JSON here
      final String Name = searchResults['name'];
      final String ingredientDescription =
      titles['description'].toString(); // Cast to String

      // Create a map to store data for each pet type
      final Map<String, Map<String, String>> petDataMap = {};

      // Function to add data to the map
      void addPetData(
          String petType, String image, String petValue, String petDescription) {
        petDataMap.putIfAbsent(
            petType,
                () => {
              'header': widget.pageTitle ?? 'Unknown',
              'left': image,
              'right': _getImageBasedOnTitles(petType, petValue),
              'ingredientName': Name,
              'ingredientDescription': ingredientDescription,
              'Description': petDescription,
              'Value': petValue,
            });
      }

      addPetData('dog', ImageConstant.charles, titles['dog_value'].toString(),
          titles['dog'].toString());
      addPetData('cat', ImageConstant.cat, titles['cat_value'].toString(),
          titles['cat'].toString());
      addPetData('parrot', ImageConstant.parrot,
          titles['parrot_value'].toString(), titles['parrot'].toString());
      addPetData('rabbit', ImageConstant.rabbit,
          titles['rabbit_value'].toString(), titles['rabbit'].toString());
      addPetData(
          'bearded_dragon',
          ImageConstant.dragon,
          titles['bearded_dragon_value'].toString(),
          titles['bearded_dragon'].toString());
      addPetData('guinea_pig', ImageConstant.guinea,
          titles['guinea_pig_value'].toString(), titles['guinea_pig'].toString());
      addPetData('hamster', ImageConstant.hamster,
          titles['hamster_value'].toString(), titles['hamster'].toString());

      // Add the data from the map to jsonResults
      jsonResults.addAll(petDataMap.values);
      // Check if the response is empty
    } catch (error) {
        // Send an email
        try {
          if (!emailSent && emailAttemptCount < 1) {
            emailAttemptCount++; // Increment the email attempt count
            await sendNoDataEmail(widget.ingredientName);
            emailSent = true; // Mark that the email has been sent
          } // Send email
        } catch (error) {
          // Handle the error gracefully, e.g., log it
        }
  // Handle the error gracefully, e.g., log it
  }
  }

  Future<Map<String, dynamic>> fetchIngredientDetails(
      String ingredientName) async {
    try {
      final response = await apiService.searchByName(ingredientName);
      final List<dynamic> responseData = json.decode(response);

      // Parse the response data and extract appropriate objects and titles
      final List<Map<String, dynamic>> parsedResults = [];
      responseData.forEach((ingredientName) {
        parsedResults.add({
          'name': ingredientName['name'],
          'titles': {
            'description': ingredientName['description'],
            'dog': ingredientName['dog_description'],
            'dog_value': ingredientName['dog'],
            'cat': ingredientName['cat_description'],
            'cat_value': ingredientName['cat'],
            'parrot': ingredientName['parrot_description'],
            'parrot_value': ingredientName['parrot'],
            'rabbit': ingredientName['rabbit_description'],
            'rabbit_value': ingredientName['rabbit'],
            'bearded_dragon': ingredientName['bearded_dragon_description'],
            'bearded_dragon_value': ingredientName['bearded_dragon'],
            'guinea_pig': ingredientName['guinea_pig_description'],
            'guinea_pig_value': ingredientName['guinea_pig'],
            'hamster': ingredientName['hamster_description'],
            'hamster_value': ingredientName['hamster'],
          },
        });
      });

      // Parse the response data and create an IngredientDetails object
      final ingredientDetails = parsedResults;
      return ingredientDetails[0];
    } catch (error) {
      print("Error fetching ingredient details: $error");
      throw error; // Rethrow the error to handle it in the calling code
    }
  }

  Future<void> sendNoDataEmail(String ingredientName) async {
    final email = Message()
      ..from = Address('ingredient.admin@cmpet.co.uk', 'admin')
      ..recipients.add('ingredient.admin@cmpet.co.uk')
      ..subject = 'No Data for Ingredient: $ingredientName'
      ..text = 'No data available for ingredient: $ingredientName';

    final smtpServer = SmtpServer('smtp.ionos.co.uk', username: 'ingredient.admin@cmpet.co.uk', password: 'M1ss1ng_Ingred13nts_CMP3T?#', port: 587);

    try {
      await send(email, smtpServer);
    } catch (e) {
      print('Error sending email: $e');
    }
  }

 String _getImageBasedOnTitles(String petType, String petValue) {
  if (petValue == null || petValue.isEmpty) {
    return ImageConstant.yellowpaw; // Default to yellow paw for null or empty petValue
  }

  if (petType == 'dog' ||
      petType == 'cat' ||
      petType == 'parrot' ||
      petType == 'rabbit' ||
      petType == 'bearded_dragon' ||
      petType == 'guinea_pig' ||
      petType == 'hamster') {
    if (petValue == '1') {
      return ImageConstant.yellowpaw;
    } else if (petValue == '2') {
      return ImageConstant.greenpaw;
    }
  }
  return ImageConstant.redpaw; // Default value for other cases
}

  @override
  void initState() {
    super.initState();
    _initializeJsonResults();
  }

  @override
  Widget build(BuildContext context) {
    analytics_utils.logScreenUsageEvent('Scan_ingredient');
    return Scaffold(
        resizeToAvoidBottomInset: false, // fluter 2.x
        endDrawer: CustomDrawer(),
        appBar: top_bar.CustomTopAppBar(
          Enabled: true,
          onTapArrowLeft: (context) {
            Navigator.pop(context);
          },
        ),
        body: FutureBuilder<void>(
          future: _initializeJsonResults(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              // While waiting for data, you can show a loading indicator
              return Center(
                child: CircularProgressIndicator(color: Color(0xFF008C8C)),
              );
            } else if (snapshot.hasError) {
              // If there's an error, display an no data message
              return buildNoResultsDescription(
                  'No data on this ingredient', jsonResults.length);
              ;
            } else {
              // If data has been successfully fetched, build the UI
              int resultLength = jsonResults.length;
              if (resultLength > 7) {
                resultLength = 7;
              }
              print(jsonResults.length);
              return SingleChildScrollView(
                child: Column(
                  children: [
                    // Header with the title 'Peanuts'
                    buildHeader(widget.pageTitle ?? 'Food Header'),
                    SizedBox(height: 10.0),
                    buildNoResultsDescription(
                        'No data on this ingredient', jsonResults.length),
                    // Iterable rectangles with margin between them
                    FractionallySizedBox(
                      widthFactor: 0.8,
                      // Set the width to 70% of the screen width
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        // Disable the ListView's scrolling behavior
                        itemCount: resultLength,
                        // Replace 3 with the number of rectangles you want
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () {
                              final String description = jsonResults[index]
                                      ['Description'] ??
                                  'Default Description';
                              final String ingredientDescription =
                                  jsonResults[index]['ingredientDescription'] ??
                                      'Default Description';
                              _showPopupDialog(
                                  context,
                                  description,
                                  ingredientDescription,
                                  jsonResults[index]['header']!);
                            },
                            child: Container(
                              margin: EdgeInsets.symmetric(vertical: 10.0),
                              child: buildIterableRectangle(jsonResults[index]),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            }
          },
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
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
                  ),
                ),
                SizedBox(height: 10.0),
                Row(
                  children: [
                    Text(
                      jsonResults[0]['header'] ?? 'Peanuts',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(width: 20.0),
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
                              ? 'ingredient data is missing for this pet type'
                              : ingredientDescription,
                        )),
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

  Widget buildNoResultsDescription(String Data, int jsonResultsLen) {
    if (jsonResultsLen == 0) {
      return Container(
        padding: EdgeInsets.all(16.0),
        alignment: Alignment.center,
        child: Text(
          Data,
          style: TextStyle(
            color: Colors.grey,
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    } else {
      // Return an empty container if jsonResultsLen is not 0
      return Container();
    }
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
              child: Image.asset(
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
