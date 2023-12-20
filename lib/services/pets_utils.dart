import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cmpets/core/app_export.dart';
import 'package:firestore_cache/firestore_cache.dart';

class PetUtils {

  static Future<void> getPetsByTypeAndUpdateList(
      String userId,
      String petType,
      List<Map<String, dynamic>> animalList,
      List<String> ingredients,
      ) async {
    // Attempt to fetch data from cache
    final cacheDocRef = FirebaseFirestore.instance.doc('users/$userId');
    final query = FirebaseFirestore.instance.collection('pets');
    const cacheField = 'updatedAt';


    var petsSnapshot = await FirestoreCache.getDocuments(
      query: query,
      cacheDocRef: cacheDocRef, firestoreCacheField: cacheField,
    );

    // If cache is not available or stale, fetch from the server
    if (!petsSnapshot.docs.isNotEmpty) {
      final _firestore = FirebaseFirestore.instance;
      petsSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('pets')
          .get();

    }

    // Create a new list to store the updated pets
    List<Map<String, dynamic>> updatedAnimalList = List.from(animalList);

    // Get the color for the corresponding pet type in animalList
    final matchingPetColor = updatedAnimalList
        .firstWhere((animal) => animal['petType'] == petType,
        orElse: () => {'color': null})
    ['color'];

    // Capitalize the first letter of each ingredient
    List<String> capitalizedIngredients = ingredients.map((ingredient) {
      return ingredient.isNotEmpty
          ? ingredient[0].toUpperCase() + ingredient.substring(1)
          : ingredient;
    }).toList();

    // Iterate over the user's pets
    for (final doc in petsSnapshot.docs) {
      final petData = doc.data();

      // Check if pet allergies match any ingredients
      final petAllergies = List<String>.from(petData['allergies'] ?? []);
      final hasMatchingAllergy = petAllergies.any((allergy) =>
          capitalizedIngredients.contains(allergy));

      final petToAdd = {
        'petType': petData['type'],
        'name': petData['name'],
        'image': petData['image'],
        'color': hasMatchingAllergy
            ? ImageConstant.redpaw
            : matchingPetColor ?? petData['color'],
        // Inherit the color from animalList or set to redpaw if there is a matching allergy
        // Add other fields as needed
      };

      // Add the new pet to the updated list
      updatedAnimalList.add(petToAdd);
    }

    // Update the original list with the modified copy
    animalList.clear();
    animalList.addAll(updatedAnimalList);
    print("new list $animalList");
  }


  static Future<List<String>?> getPetTypesForUser(String userId) async {
    try {
      // Attempt to fetch data from cache
      final cacheDocRef = FirebaseFirestore.instance.doc('users/$userId');
      final query = FirebaseFirestore.instance.collection('pets');
      const cacheField = 'updatedAt';


      var petsSnapshot = await FirestoreCache.getDocuments(
        query: query,
        cacheDocRef: cacheDocRef, firestoreCacheField: cacheField,
      );

      // If cache is not available or stale, fetch from the server
      if (!petsSnapshot.docs.isNotEmpty) {
        final _firestore = FirebaseFirestore.instance;
         petsSnapshot = await _firestore
            .collection('users')
            .doc(userId)
            .collection('pets')
            .get();

      }

      final petTypes = petsSnapshot.docs
          .map((doc) => doc.data()['type'].toString())
          .toSet()
          .toList();

      return petTypes;
    } catch (e) {
      print('Error fetching pet types: $e');
      return null;
    }
  }


  static Future<List<Map<String, String>>> updateJsonResultsWithFirestoreImages(
      List<Map<String, String>> jsonResults,
      String userId,
      String? Ingredient,
      ) async {
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;

    try {
      final petsSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('pets')
          .get();

      for (final petDocument in petsSnapshot.docs) {
        final petData = petDocument.data();
        final String petType = petData['type'];
        String petImage = petData['image'];
        List<String> petAllergies = List<String>.from(petData['allergies']);


        // Check if the pet type exists in jsonResults
        final existingPet = jsonResults.firstWhere(
              (existingPet) => existingPet['petType'] == petType,
        );

        if (petData['image'] == '') {
          // Set a default image based on pet type if no image is available
          if (petType == 'dog') {
            petImage = ImageConstant.charles;
          } else if (petType == 'cat') {
            petImage = ImageConstant.cat;
          } else if (petType == 'rabbit') {
            petImage = ImageConstant.rabbit;
          } else if (petType == 'guinea_pig') {
            petImage = ImageConstant.guinea;
          } else if (petType == 'hamster') {
            petImage = ImageConstant.hamster;
          } else if (petType == 'bearded_dragon') {
            petImage = ImageConstant.dragon;
          }
        }

        String ingDes;
        String existing_r = existingPet['right'] ?? ImageConstant.yellowpaw;
        String fsName = petData['name'];

        // Check if the ingredient is in the pet's allergies list
        if (petAllergies.contains(Ingredient)) {
          existing_r = ImageConstant.redpaw;
          ingDes = "$fsName Can't Eat This!";
        } else if (existingPet['right'] == ImageConstant.yellowpaw) {
          ingDes = "Unsure If This Is Safe For $fsName!";
        } else if (existingPet['right'] == ImageConstant.redpaw) {
          ingDes = "$fsName Can't Eat This!";
        } else {
          ingDes = "$fsName Can Eat This!";
        }



        // Add a new pet to jsonResults
        jsonResults.add({
          'header': existingPet['header'] ?? 'Unknown',
          'left': petImage,
          'right': existing_r,
          'petName': existingPet['name'] ?? 'Unknown',
          'petType': petType,
          'Description': existingPet['Description'] ?? '',
          'ingredientDescription': ingDes,
          'Value': existingPet['Value'] ?? '',
          'personal' : 'true',
        });

      }
    } catch (e) {
      print('Error fetching pets: $e');
      // Handle the error as needed, for example, return an empty list
      return [];
    }

    return jsonResults;
  }


}