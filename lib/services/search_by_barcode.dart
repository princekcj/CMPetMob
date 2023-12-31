import 'dart:convert';
import 'package:http/http.dart' as http;

// Your Open Food Facts API endpoint

Future<List<String>> searchProductIngredientsByBarcode(String barcode) async {
  // Define a user agent to identify your application
  final Map<String, String> headers = {
    'User-Agent': 'NameOfYourApp - Android - Version 1.0 - www.yourappwebsite.com', // Replace with your app name and version
  };

  final String apiUrl = 'https://world.openfoodfacts.org/api/v0/product/YOUR_BARCODE_NUMBER.json';


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

Future<List<Map<String, dynamic>>> searchProductsWithIngredients(String productName) async {
  final Map<String, String> headers = {
    'User-Agent': 'NameOfYourApp - Android - Version 1.0 - www.yourappwebsite.com',
  };

  final String apiUrl =
      "https://world.openfoodfacts.org/cgi/search.pl?json=true&action=process&tagtype_0=brands&tag_contains_0=contains&tag_0=$productName&page_size=20";

  final response = await http.get(
    Uri.parse(apiUrl),
    headers: headers,
  );

  if (response.statusCode == 200) {
    final decodedData = json.decode(response.body);
    final List<dynamic> products = decodedData['products'];

    if (products.isNotEmpty) {
      final List<Map<String, dynamic>> productList = [];
      final Set<String> uniqueProductNames = Set<String>();

      for (dynamic product in products) {
        try {
          String productName = product['product_name'];

          // Check for duplicate product names
          if (uniqueProductNames.contains(productName)) {
            continue; // Skip this product if the name is already in the set
          }

          List<String> ingredientsList = [];
          final ingredientsHierarchy = product['ingredients_hierarchy'];

          if (ingredientsHierarchy != null) {
            for (String ingredient in ingredientsHierarchy) {
              try {
                String cleanedIngredient = '';

                if (!ingredient.contains('en:')) {
                  cleanedIngredient = ingredient.replaceAll('fr:', '');
                } else if (!ingredient.contains('fr:')) {
                  cleanedIngredient = ingredient.replaceAll('en:', '');
                }

                cleanedIngredient = cleanedIngredient.replaceAll('-', ' ');
                ingredientsList.add(cleanedIngredient);
              } catch (e) {
                print('Error processing ingredient: $ingredient, Error: $e');
              }
            }
          }

          // Add product details to the list and set
          productList.add({
            'productName': productName,
            'ingredients': ingredientsList.isEmpty ? [productName] : ingredientsList,
          });

          uniqueProductNames.add(productName); // Add the product name to the set
        } catch (e) {
          print('Error processing product: $product, Error: $e');
        }
      }

      return productList;
    }
  }

  return [];
}
