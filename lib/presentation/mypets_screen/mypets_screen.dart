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
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? _currentUser;
  Map<String, bool> showDeleteButtons = {};

  void toggleMenu() {
    setState(() {
      isMenuOpen = !isMenuOpen;
    });
  }

  @override
  void initState() {
    super.initState();
    _currentUser = _auth.currentUser;
  }

  Future<void> deletePet(String petId) async {
    if (_currentUser == null) return;
    try {
      await _firestore
          .collection('users')
          .doc(_currentUser!.uid)
          .collection('pets')
          .doc(petId)
          .delete();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Pet deleted successfully'),
      ));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to delete pet: $e'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    analytics_utils.logScreenUsageEvent('MyPetsScreen');
    return Scaffold(
      resizeToAvoidBottomInset: false,
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

                final petTabs = snapshot.data!.docs.map((doc) {
                  String petName = doc['name'];
                  String petId = doc.id;
                  String petWeight = doc['weight'];
                  String petType = doc['type'];
                  String image = doc['image'];
                  List<String> allergies = List<String>.from(doc['allergies'] ?? []);
                  String feedingInstructions = doc['feedingInstructions'] ?? '';
                  List<String> medications = List<String>.from(doc['medications'] ?? []);
                  Timestamp? dateOfBirthTimestamp = doc['dateOfBirth'] as Timestamp?;
                  DateTime? dateOfBirth = dateOfBirthTimestamp != null ? dateOfBirthTimestamp.toDate() : null;
                  String moreInfo = doc['moreInfo'];
                  bool isNeutered = doc['isNeutered'];
                  String vetName = doc['vetName'];
                  String insuranceProvider = doc['insuranceProvider'];

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
                    onLongPress: () {
                      setState(() {
                        showDeleteButtons[petId] = true;
                      });
                    },
                    child: buildPetTab(petName, petType, image, petId),
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
          GestureDetector(
            onTap: () {
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
                  color: Colors.black,
                  width: 2.0,
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
        backgroundColor: Color(0xFF008C8C),
        child: Image.asset(ImageConstant.searchbutton, width: 40, height: 40),
        shape: RoundedRectangleBorder(
          side: BorderSide(color: ColorConstant.fromHex('#a3ccff'), width: 2.0),
          borderRadius: BorderRadius.circular(28.0),
        ),
        onPressed: () {
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

  Widget buildPetTab(String label, String petType, String image, String petId) {
    String petImage = '';

    if (image.startsWith("https")) {
      petImage = image;
    } else if (petType == 'cat') {
      petImage = ImageConstant.cat;
    } else if (petType == 'snake') {
      petImage = ImageConstant.snake;
    } else if (petType == 'parrot') {
      petImage = ImageConstant.parrot;
    } else if (petType == 'dog') {
      petImage = ImageConstant.charles;
    } else if (petType == 'guinea_pig') {
      petImage = ImageConstant.guinea;
    } else if (petType == 'bearded_dragon') {
      petImage = ImageConstant.dragon;
    } else if (petType == 'hamster') {
      petImage = ImageConstant.hamster;
    }

    return Tab(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white,
                width: 2,
              ),
            ),
            child: Stack(
              children: [
                ClipOval(
                  clipBehavior: Clip.hardEdge,
                  child: petImage.startsWith("https")
                      ? CachedNetworkImage(
                    imageUrl: petImage,
                    cacheManager: CustomCacheManager.instance,
                    fit: BoxFit.fill,
                    width: 100,
                    height: 100,
                  )
                      : Image.asset(
                    petImage,
                    fit: BoxFit.cover,
                    width: 100,
                    height: 100,
                  ),
                ),
                if (showDeleteButtons[petId] == true)
                  Positioned(
                    right: 0,
                    child: IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        deletePet(petId);
                        setState(() {
                          showDeleteButtons.remove(petId);
                        });
                      },
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(height: 8),
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
