import 'package:flutter/material.dart';
import '../../core/utils/color_constant.dart';
import '../../core/utils/image_constant.dart';
import '../../routes/app_routes.dart';
import '../../widgets/app_bar/custom_app_bar.dart';
import '../../widgets/app_bar/custom_app_drawer.dart';
import '../../widgets/banner.dart';
import '../../core/utils/analytics_utils.dart' as analytics_utils;
import '../ingredient_screen/ingredient_screen.dart';
import 'package:cmpets/widgets/app_bar/topappbar.dart' as top_bar;


class ProductListPage extends StatelessWidget {
  final List<String> productIngredients; // Change the type to Map<String, dynamic>

  ProductListPage({required this.productIngredients});

  @override
  Widget build(BuildContext context) {
    analytics_utils.logScreenUsageEvent('Scan_ingredients_list');
    return Scaffold(
      endDrawer: CustomDrawer(),
      appBar: top_bar.CustomTopAppBar(
        Enabled: true,
      ),
      body:
      Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Add the AnimalBannerPage widget here
          AnimalBannerPage(ingredients: productIngredients),
          Expanded(
            child: ListView.builder(
              itemCount: productIngredients.length,
              itemBuilder: (context, index) {
                final ingredient = productIngredients[index];
                final capitalizedIngredient =
                    ingredient.capitalize() ?? 'Unknown'; // Capitalize the first letter
                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0), // Adjust the radius as needed
                  ),
                  elevation: 2, // Adjust the elevation as needed
                  margin: EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 8.0), // Adjust margins as needed
                  child: ListTile(
                    title: Center(
                      child: Text(capitalizedIngredient),
                    ),
                    onTap: () {
                      // Navigate to the ingredient page when tapped
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => IngredientPage(
                            pageTitle: capitalizedIngredient,
                            ingredientName: ingredient, // Pass the original ingredient name as a String
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      extendBody: true,
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xFF008C8C), // Set the background color to blue
        child: Image.asset(ImageConstant.searchbutton, width: 40, height: 40),
        shape: RoundedRectangleBorder(
          side: BorderSide(color: ColorConstant.fromHex('#a3ccff'), width: 2.0),
          borderRadius: BorderRadius.circular(28.0), // Adjust the border radius as needed
        ),
        onPressed: () {
          // Check if the current route is not already the search route

          if (ModalRoute.of(context)!.settings.name != AppRoutes.barcodeScreen) {
            Navigator.pushReplacementNamed(context, AppRoutes.barcodeScreen);
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
      ), // Add your custom bottom navigation bar here
    );
  }
}
extension StringExtensions on String {
  String capitalize() {
    return this.isNotEmpty
        ? this[0].toUpperCase() + this.substring(1)
        : this;
  }
}