import 'dart:convert';

import 'package:carousel_slider_plus/carousel_slider_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../api/api_services.dart'; // Import your ApiService
import '../../core/utils/image_constant.dart';
import '../env.dart';
import '../services/pets_utils.dart'; // Import your image constants

class AnimalBannerPage extends StatefulWidget {
  final List<String> ingredients; // Change to a list of ingredients
  AnimalBannerPage(
      {required this.ingredients}); // Constructor to receive the ingredients

  @override
  _AnimalBannerPageState createState() => _AnimalBannerPageState();
}

class _AnimalBannerPageState extends State<AnimalBannerPage> {
  late List<Map<String, dynamic>> animalsData = []; // Initialize the list
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _currentUser;

  ApiService apiService = ApiService(
      Env.key1, Env.key2);

  Future<void> _initializeAnimalsWithZero() async {
    try {
      List<Map<String, dynamic>> animalsList = [];

      // Lists to store values of 'dog_value', 'cat_value', etc. for each ingredient
      List<dynamic> dogValues = [];
      List<dynamic> catValues = [];
      List<dynamic> parrotValues = [];
      List<dynamic> rabbitValues = [];
      List<dynamic> beardedDragonValues = [];
      List<dynamic> guineaPigValues = [];
      List<dynamic> hamsterValues = [];

      try {
        // Call fetchAnimalData with the list of ingredients
        final List<Map<String, dynamic>> allIngredientsData = await fetchAnimalData(widget.ingredients);

        for (var animalData in allIngredientsData) {
          if (animalData.isNotEmpty) {
            final Map<String, dynamic> titles = Map<String, dynamic>.from(animalData['titles']);

            // Extract values of 'dog_value', 'cat_value', etc. and add them to the respective lists
            beardedDragonValues.add(titles['bearded_dragon_value']);
            parrotValues.add(titles['parrot_value']);
            hamsterValues.add(titles['hamster_value']);
            dogValues.add(titles['dog_value']);
            catValues.add(titles['cat_value']);
            rabbitValues.add(titles['rabbit_value']);
            guineaPigValues.add(titles['guinea_pig_value']);
          }
        }
      } catch (error) {
        // Handle the error if it occurs while fetching data for ingredients
        print("Error fetching data for ingredients - $error");
        // You can choose to handle the error differently here.
      }


      // Now, you have lists of values for each ingredient
      // dogValues, catValues, parrotValues, rabbitValues, beardedDragonValues, guineaPigValues, hamsterValues

     // Check which lists have a 0 in them and create a Map for each one
void checkAnimals() {
  List<Map<String, dynamic>> animalsList = [];
  
  if (dogValues.isEmpty || dogValues.contains("0")) {
    animalsList.add({
      'color': ImageConstant.redpaw,
      'petType': 'dog',
    });
  } else if (!dogValues.contains("0") && dogValues.length == widget.ingredients.length) {
    animalsList.add({
      'color': ImageConstant.greenpaw,
      'petType': 'dog',
    });
  } else if (!dogValues.contains("0") && dogValues.contains("1") && dogValues.contains("2")) {
    animalsList.add({
      'color': ImageConstant.yellowpaw,
      'petType': 'dog',
    });
  } else {
    animalsList.add({
      'color': ImageConstant.redpaw,
      'petType': 'dog',
    });
  }
  
  if (catValues.isEmpty || catValues.contains("0")) {
    animalsList.add({
      'color': ImageConstant.redpaw,
      'petType': 'cat',
    });
  } else if (!catValues.contains("0") && catValues.length == widget.ingredients.length) {
    animalsList.add({
      'color': ImageConstant.greenpaw,
      'petType': 'cat',
    });
  } else if (!catValues.contains("0") && catValues.contains("1") && catValues.contains("2")) {
    animalsList.add({
      'color': ImageConstant.yellowpaw,
      'petType': 'cat',
    });
  } else {
    animalsList.add({
      'color': ImageConstant.redpaw,
      'petType': 'cat',
    });
  }
  
  if (parrotValues.isEmpty || parrotValues.contains("0")) {
    animalsList.add({
      'color': ImageConstant.redpaw,
      'petType': 'parrot',
    });
  } else if (!parrotValues.contains("0") && parrotValues.length == widget.ingredients.length) {
    animalsList.add({
      'color': ImageConstant.greenpaw,
      'petType': 'parrot',
    });
  } else if (!parrotValues.contains("0") && parrotValues.contains("1") && parrotValues.contains("2")) {
    animalsList.add({
      'color': ImageConstant.yellowpaw,
      'petType': 'parrot',
    });
  }


      // Replace 'userId' and 'petType' with actual values
      final userId = _currentUser?.uid;


      List<Map<String, dynamic>> updatedAnimalList = List.from(animalsList);

      for (final item in animalsList) {
        await PetUtils.getPetsByTypeAndUpdateList(userId!, item['petType'], updatedAnimalList, widget.ingredients);
            }

// After the loop is complete, update the original list and reverse it
      animalsList.clear();
      animalsList.addAll(updatedAnimalList.reversed.toList());
      print("new list $animalsList");

      setState(() {
        animalsData = animalsList;
      });
    } catch (error) {
      print("Error fetching animals with zero: $error");
    }
  }


  Future<List<Map<String, dynamic>>> fetchAnimalData(List<String> ingredients) async {
    try {
      // Use the searchByNames method with the list of ingredients
      final response = await apiService.searchByNames(ingredients);
      final List<dynamic> responseData = json.decode(response);

      // Check if responseData is not empty
      if (responseData.isNotEmpty) {
        // Create a list to store details for all ingredients
        List<Map<String, dynamic>> allIngredientsDetails = [];

        for (var ingredientName in responseData) {
          final Map<String, dynamic> titles = {
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
          };

          // Create an IngredientDetails object
          final Map<String, dynamic> ingredientDetails = {
            'name': ingredientName['name'],
            'titles': titles,
          };

          // Add the details for the current ingredient to the list
          allIngredientsDetails.add(ingredientDetails);
        }

        return allIngredientsDetails;
      } else {
        throw Exception('No data found for ingredients: $ingredients');
      }
    } catch (error) {
      print("Error fetching ingredient details: $error");
      throw error; // Rethrow the error to handle it in the calling code
    }
  }

  @override
  void initState() {
    super.initState();
    _initializeAnimalsWithZero();
    _currentUser = _auth.currentUser;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100, // Specify the desired height for the banner
      child: _buildAnimalBanner(),
    );
  }

  Widget _buildAnimalBanner() {
    // Check if animalsData is empty, and display a circular progress indicator
    if (animalsData.isEmpty) {
      return Center(
        child:
            CircularProgressIndicator(), // Display a circular progress indicator
      );
    }

    return CarouselSlider.builder(
      itemCount: animalsData.length,
      itemBuilder: (context, animalIndex, realIndex) {
        final animal = animalsData[animalIndex];
        final String petType = animal['petType'];
        bool hasRedStatus = animal['color'] == ImageConstant.redpaw;
        String? imageAsset;
        String petName;


        if (animal['name'] != null){

          petName = animal['name'];
        } else {
          petName = animal['petType'];
        }

        petName = formatPetName(petName);
        // Map petType to the corresponding image constant


// Define a map for image assets
        Map<String, String> petTypeToImage = {
          'dog': ImageConstant.charles,
          'cat': ImageConstant.cat,
          'parrot': ImageConstant.parrot,
          'guinea_pig': ImageConstant.guinea,
          'hamster': ImageConstant.hamster,
          'rabbit': ImageConstant.rabbit,
          'bearded_dragon': ImageConstant.dragon,
        };

        if (animal['image'] == '') {
          if (petTypeToImage.containsKey(petType)) {
            imageAsset = petTypeToImage[petType];
          }
        } else if (animal['image'] != null) {
          imageAsset = animal['image'];
        } else if (petTypeToImage.containsKey(petType)) {
          imageAsset = petTypeToImage[petType];
        } else {
          imageAsset = ImageConstant.snake; // Set a default image constant
        }
        return Card(
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Container(
            width: 520,
            padding: EdgeInsets.all(8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CircleAvatar(
                  backgroundImage: imageAsset!.startsWith("https")
                      ? NetworkImage(imageAsset)
                      : AssetImage(imageAsset) as ImageProvider,
                  radius: 44,
                ),
                SizedBox(width: 8),
                Text(petName),
                SizedBox(width: 8),
                if (hasRedStatus)
                  Image.asset(
                    ImageConstant.redpaw,
                    width: 48,
                    height: 48,
                  ),
                if (!hasRedStatus)
                  Image.asset(
                    animal['color'],
                    width: 48,
                    height: 48,
                  ),
              ],
            ),
          ),
        );
      },
      options: CarouselOptions(
        height: 100, // Specify the desired height for the banner
        enableInfiniteScroll: false, // Disable infinite scrolling
        viewportFraction: 0.85, // Adjust the visible items fraction
        initialPage: 0, // Initial page index
      ),
    );
  }
}

String formatPetName(String petName) {
  // Replace underscores with spaces
  String formattedName = petName.replaceAll('_', ' ');
  // Check if there are spaces in the formatted name
  if (formattedName.contains(' ')) {
    // Capitalize the first letter of each word
    formattedName = formattedName.split(' ').map((word) {
      return word.toUpperCase();
    }).join(' ');
  } else {
    // If there are no spaces, just capitalize the first letter of the whole string
    formattedName = formattedName.toUpperCase();
  }

  return formattedName;
}


