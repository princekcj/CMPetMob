import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cmpets/core/app_export.dart';
import 'package:cmpets/widgets/app_bar/topappbar.dart' as top_bar;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/utils/analytics_utils.dart' as analytics_utils;
import '../../core/utils/cache_manager.dart';
import '../../services/pet_journal/appointments.dart';
import '../../widgets/app_bar/custom_app_bar.dart';
import '../../widgets/app_bar/custom_app_drawer.dart';
import '../pet_info_screen/mypet_info_screen.dart';

class MyPetsScreen extends StatefulWidget {
  const MyPetsScreen({Key? key}) : super(key: key);

  @override
  _MyPetsScreenState createState() => _MyPetsScreenState();
}

class _MyPetsScreenState extends State<MyPetsScreen> {
  bool isMenuOpen = false;
  // Image cache for precaching
  final ImageCache _imageCache = ImageCache();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? _currentUser;

  void toggleMenu() {
    setState(() {
      isMenuOpen = !isMenuOpen;
    });
  }

  ImageProvider _getImageProvider(String imagePath) {
    if (imagePath.startsWith("https")) {
      return NetworkImage(imagePath);
    } else {
      return AssetImage(imagePath);
    }
  }



  // Fetch the current user when the screen initializes
  @override
  void initState() {
    super.initState();
    _currentUser = _auth.currentUser;

  }


  @override
  Widget build(BuildContext context) {
    analytics_utils.logScreenUsageEvent('MyPetsScreen');
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
        body: Column(
          children: [
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore
                    .collection('users')
                    .doc(_currentUser?.uid)
                    .collection('pets')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator(color: Color(0xFF008C8C)));
                  }

                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }

                  if (!snapshot.hasData ||
                      (snapshot.data?.docs.isEmpty ?? true)) {
                    return Center(child: Text('No pets available.'));
                  }

                  // Map the documents to PetTabs and display
                  final petTabs = snapshot.data!.docs.map((doc) {
                    String petName = doc['name'];
                    String petId = doc.id;
                    String petWeight = doc['weight'];
                    String petType = doc['type'];
                    String image = doc['image'];
                    List<String> allergies = List<String>.from(doc['allergies'] ?? []); // Adjusting for 'allergies'
                    String feedingInstructions = doc['feedingInstructions'] ?? ''; // Adjusting for 'feedingInstructions'
                    List<String> medications = List<String>.from(doc['medications'] ?? []); // Adjusting for 'medications'
                    Timestamp? dateOfBirthTimestamp = doc['dateOfBirth'] as Timestamp?;
                    DateTime? dateOfBirth = dateOfBirthTimestamp != null ? dateOfBirthTimestamp.toDate() : null; // Adjusting for 'dateOfBirth'
                    String moreInfo = doc['moreInfo'];
                    bool isNeutered = doc['isNeutered'];
                    String vetName = doc['vetName'];
                    String insuranceProvider = doc['insuranceProvider'];

                    // Convert 'appointments' from Firestore to a list of Appointment objects
                    List<Appointment> appointments = (doc['appointments'] as List<dynamic>)
                        .map((appointmentData) => Appointment.fromJson(appointmentData))
                        .toList();


                    return GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) =>
                              MyPetInfoScreen(petId: petId, petName: petName, image: image, petWeight: petWeight, petType: petType, allergies: allergies, feedingInstructions: feedingInstructions, medications: medications, selectedDate: dateOfBirth, moreInfo: moreInfo, appointments: appointments, isNeutered: isNeutered, vetName: vetName, insuranceProvider: insuranceProvider),
                        ));
                      },
                      child: buildPetTab(petName, petType, image),
                    );
                  }).toList();

                  return GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                    ),
                    itemCount: petTabs.length,
                    itemBuilder: (context, index) {
                      return petTabs[index];
                    },
                  );
                },
              ),
            ),
            SizedBox(height: 5),
            // Reduce the height to bring the plus button closer to the GridView
            GestureDetector(
              onTap: () {
                // Navigate to MyPetInfoScreen without passing a pet name
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => MyPetInfoScreen(),
                ));
              },
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.black, // Border color
                    width: 2.0, // Border width
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.add,
                    color: Colors.grey,
                    size: 40,
                  ),
                ),
              ),
            ),
            SizedBox(height: 65),
          ],
        ),
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

  Widget buildPetTab(String label, String _petType, String image) {
    String _petImage = '';

    if (image.startsWith("https")) {
      _petImage = image; // Replace with actual image path
    } else if (_petType == 'cat') {
        _petImage = ImageConstant.cat; // Replace with actual cat image path
    } else if (_petType == 'snake') {
        _petImage = ImageConstant.snake; // Replace with actual snake image path
    } else if (_petType == 'parrot') {
        _petImage = ImageConstant.parrot; // Replace with actual parrot image path
    } else if (_petType == 'dog') {
        _petImage = ImageConstant.charles; // Replace with actual parrot image path
    } else if (_petType == 'guinea_pig') {
      _petImage = ImageConstant.guinea; // Replace with actual parrot image path
    } else if (_petType == 'bearded_dragon') {
      _petImage = ImageConstant.dragon; // Replace with actual parrot image path
    } else if (_petType == 'hamster') {
      _petImage = ImageConstant.hamster; // Replace with actual parrot image path
    }


    return Tab(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 90, // Adjust the size as needed
            height: 90,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white,
                width: 2, // Adjust the border thickness as needed
              ),
            ),
              child: ClipOval(
                clipBehavior: Clip.hardEdge,
              child: _petImage.startsWith("https")
                  ? CachedNetworkImage(
                  imageUrl: _petImage,
                cacheManager: CustomCacheManager.instance,
                fit: BoxFit.fill,
                width: 100,
                height: 100,
              )
                  : Image.asset(
                _petImage, // Replace with your image asset path
                fit: BoxFit.cover,
                width: 100,
                height: 100,
              ),
            ),
          ),
          SizedBox(height: 8), // Add some space between the image and the label
          Text(
            label,
            style: TextStyle(
              color: Colors.black,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
