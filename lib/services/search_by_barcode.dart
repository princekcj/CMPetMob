import 'dart:convert';
import 'package:http/http.dart' as http;

// Your Open Food Facts API endpoint
final String apiUrl = 'https://world.openfoodfacts.org/api/v0/product/YOUR_BARCODE_NUMBER.json';

Future<List<String>> searchProductIngredientsByBarcode(String barcode) async {
  // Define a user agent to identify your application
  final Map<String, String> headers = {
    'User-Agent': 'NameOfYourApp - Android - Version 1.0 - www.yourappwebsite.com', // Replace with your app name and version
  };

  final response = await http.get(
    Uri.parse(apiUrl.replaceFirst('YOUR_BARCODE_NUMBER', barcode)),
    headers: headers, // Set the user agent in the headers
  );

  if (response.statusCode == 200) {
    // Parse the response data, which will contain product information.
    // You can use a JSON decoding library like 'dart:convert' to parse the data.
    final decodedData = json.decode(response.body);

    // Extract the 'ingredients_hierarchy' list
    print(decodedData);
    final ingredientsHierarchy = decodedData['product']['ingredients_hierarchy'];

    if (ingredientsHierarchy.isNotEmpty) {
      // Create a list to store ingredients without errors
      final Set<String> ingredientsList = {};

      for (String ingredient in ingredientsHierarchy) {
        try {
          String cleanedIngredient = '';
          // Remove 'fr:' prefix only if 'en:' is not present
          if (!ingredient.contains('en:')) {
            cleanedIngredient = ingredient.replaceAll('fr:', '');
          } else if (!ingredient.contains('fr:')) {
            cleanedIngredient = ingredient.replaceAll('en:', '');
          }

          // Replace '-' with spaces if they exist in the cleanedIngredient
          cleanedIngredient = cleanedIngredient.replaceAll('-', ' ');

          // Add the cleaned ingredient to the list
          ingredientsList.add(cleanedIngredient);
        } catch (e) {
          // Handle the error (e.g., log it) and continue to the next ingredient
          print('Error processing ingredient: $ingredient, Error: $e');
        }
      }


      // Return the list of ingredients without errors
      return ingredientsList.toList();
    }
  }

  // Handle errors or no ingredients found by returning an empty list
  return [];
}
