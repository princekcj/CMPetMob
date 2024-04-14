import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:open_file/open_file.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/material.dart';
import 'package:cmpets/core/app_export.dart';
import 'package:cmpets/widgets/app_bar/topappbar.dart' as top_bar;
import '../../services/add_pet_service.dart';
import '../../services/pet_journal/appointments.dart';
import '../../core/utils/analytics_utils.dart' as analytics_utils;
import '../../widgets/app_bar/custom_app_bar.dart';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // Import the image_picker package
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class MyPetInfoScreen extends StatefulWidget {
  final String? petId;
  final String? petName;
  final String? petWeight;
  final String? petType;
  final String? image;
  final List<String>? allergies; // Add allergies field
  final List<String>? medications; // Add medications field
  final DateTime? selectedDate; // Add selectedDate field
  final String? feedingInstructions; // Add feedingInstructions field
  final String? moreInfo; // Add moreInfo field
  final List<Appointment>? appointments; // Add the field for appointments
  final bool? isNeutered;
  final String? vetName;
  final String? insuranceProvider;

  const MyPetInfoScreen(
      {Key? key,
      this.petId,
      this.petName,
      this.petWeight,
      this.petType,
      this.image,
      this.allergies, // Pass allergies here
      this.medications, // Pass medications here
      this.selectedDate, // Pass selectedDate here
      this.feedingInstructions, // Pass feedingInstructions here
      this.moreInfo, // Pass moreInfo here
      this.appointments, // Pass appointments here
      this.isNeutered,
      this.vetName,
      this.insuranceProvider})
      : super(key: key);

  @override
  MyPetInfoScreenState createState() => MyPetInfoScreenState();
}

class MyPetInfoScreenState extends State<MyPetInfoScreen> {
  DateTime? selectedDate; // Add this variable to store the selected date
  List<String> allergies = [];
  List<String> medications = [];
  List<Appointment> appointments =
      []; // Initialize appointments as an empty list
  String _selectedWeightUnit = 'kg'; // Default to metric unit
  List<String> weightUnits = ['kg', 'lbs']; // List of weight units
  bool isEditing = false;

  void addAllergy(String newAllergy) {
    setState(() {
      allergies.add(newAllergy);
    });
  }

  void removeAllergy(int index) {
    setState(() {
      allergies.removeAt(index);
    });
  }

  void addMedication(String newMedication) {
    setState(() {
      medications.add(newMedication);
    });
  }

  void removeMedication(int index) {
    setState(() {
      medications.removeAt(index);
    });
  }

  bool isMenuOpen = false;

  TextEditingController _nameController = TextEditingController();
  TextEditingController _ageController = TextEditingController();
  TextEditingController _weightController = TextEditingController();
  TextEditingController _feedingInstructionsController =
      TextEditingController();
  TextEditingController _moreInfoController = TextEditingController();
  TextEditingController _insuranceProviderController = TextEditingController();
  TextEditingController _vetNameController = TextEditingController();
  bool _neutered = false;
  String _imagePath = '';
  PetService _petService = PetService();
  String _selectedAnimalType = 'cat';
  ImageProvider _petImage = AssetImage(ImageConstant.charles); // Initial image
  final List<String> allergyOptions = [
    'Dairy',
    'Chicken',
    'Eggs',
    'Fish',
    'Soy',
    'Corn',
    'Wheat',
    'Feather',
    'Other'
    // Add more allergy options as needed
  ];

  String? selectedAllergy;

  void toggleMenu() {
    setState(() {
      isMenuOpen = !isMenuOpen;
    });
  }

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.petName ?? '';
    _weightController.text = widget.petWeight ?? '';
    _feedingInstructionsController.text = widget.feedingInstructions ?? '';
    _moreInfoController.text = widget.moreInfo ?? '';
    _insuranceProviderController.text = widget.insuranceProvider ?? '';
    _vetNameController.text = widget.vetName ?? '';
    _neutered = widget.isNeutered ?? false;

    // Initialize the allergies, medications, selectedDate, and other fields as needed.
    allergies = widget.allergies ?? [];
    String im = widget.image ?? '';

    setState(() {
      appointments = widget.appointments ?? [];
    });

    if (widget.image != null) {
      if (widget.image!.startsWith('https')) {
        setState(() {
          _petImage = CachedNetworkImageProvider(widget.image ?? '');
        });
      }
    }
    medications = widget.medications ?? [];
    selectedDate = widget.selectedDate ?? null;

    if (widget.petName == null) {
      Future.delayed(Duration.zero, () {
        _showAnimalSelectionDialog();
      });
    }
    if (widget.image == '') {
      if (widget.petType != null) {
        if (widget.petType == 'cat') {
          setState(() {
            _petImage = AssetImage(
                ImageConstant.cat); // Replace with actual cat image path
          });
        } else if (widget.petType == 'snake') {
          setState(() {
            _petImage = AssetImage(
                ImageConstant.snake); // Replace with actual snake image path
          });
        } else if (widget.petType == 'parrot') {
          setState(() {
            _petImage = AssetImage(
                ImageConstant.parrot); // Replace with actual parrot image path
          });
        } else if (widget.petType == 'dog') {
          setState(() {
            _petImage = AssetImage(
                ImageConstant.charles); // Replace with actual parrot image path
          });
        } else if (widget.petType == 'hamster') {
          setState(() {
            _petImage = AssetImage(
                ImageConstant.hamster); // Replace with actual parrot image path
          });
        } else if (widget.petType == 'guinea_pig') {
          setState(() {
            _petImage = AssetImage(
                ImageConstant.guinea); // Replace with actual parrot image path
          });
        } else if (widget.petType == 'bearded_dragon') {
          setState(() {
            _petImage = AssetImage(
                ImageConstant.dragon); // Replace with actual parrot image path
          });
        }
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _showAnimalSelectionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Pet'),
              content: DropdownButtonFormField<String>(
                value: _selectedAnimalType, // Set the selected value
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedAnimalType =
                        newValue!; // Update the selected value
                    _updatePetImage();
                  });
                },
                items: [
                  DropdownMenuItem(
                    value: 'dog',
                    child: Text('Dog'),
                  ),
                  DropdownMenuItem(
                    value: 'cat',
                    child: Text('Cat'),
                  ),
                  DropdownMenuItem(
                    value: 'hamster',
                    child: Text('Hamster'),
                  ),
                  DropdownMenuItem(
                    value: 'guinea_pig',
                    child: Text('Guinea Pig'),
                  ),
                  DropdownMenuItem(
                    value: 'bearded_dragon',
                    child: Text('Bearded Dragon'),
                  ),
                  DropdownMenuItem(
                    value: 'parrot',
                    child: Text('Parrot'),
                  ),
                ],
              ),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('Save', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF008C8C),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> sharePdf(String petPdfName, ImageProvider<Object> imgPet) async {
    try {
    final pdfData = await generatePdf(imgPet);

    // On mobile platforms, you can use the share_plus package to share the PDF
    Directory documentDirectory = await getApplicationDocumentsDirectory();
    final tempDir = await documentDirectory;
    final pdfFile = File('${tempDir.path}/${petPdfName}_pet_profile.pdf');
    pdfFile.create();
    pdfFile.writeAsBytesSync(pdfData);

    await Share.shareFiles(['${tempDir.path}/${petPdfName}_pet_profile.pdf'],
        text: 'Check out my pet info');
    } catch (error) {
      print("Error generating pdf to share: $error");
      throw error; // Rethrow the error to handle it in the calling code
    }
  }

  Future<void> requestDownload(String petPdfName, ImageProvider<Object> imgPet) async {
    try {
      final pdfData = await generatePdf(imgPet);

      // Use FilePicker to allow users to choose a directory for saving the PDF
      final result = await FilePicker.platform.saveFile(
        fileName: '${petPdfName}_pet_profile.pdf',
        allowedExtensions: ['pdf'],
      );

      if (result != null) {
        final pdfFile = File(result);
        await pdfFile.writeAsBytes(pdfData);
        print('PDF saved at: ${pdfFile.path}');
      } else {
        print('User canceled the download.');
      }
    } catch (error) {
      print("Error requesting download: $error");
      throw error; // Rethrow the error to handle it in the calling code
    }
  }

  String formatAppointments(List<Appointment> appointments) {
    if (appointments.isEmpty) {
      return 'No appointments scheduled';
    }

    // Show only the first two appointments
    List<String> formattedAppointments = appointments.take(2).map((appointment) {
      return 'Title: ${appointment.type}, Date: ${DateFormat('dd-MM-yyyy').format(appointment.date)}';
    }).toList();

    // Check if there are more appointments
    int additionalAppointments = appointments.length - 2;
    if (additionalAppointments > 0) {
      formattedAppointments.add('+$additionalAppointments more');
    }

    return formattedAppointments.join('\n');
  }


  Future<Uint8List> generatePdf(_petImage) async {
    // Create a PDF document
    final pdf = pw.Document();
    final ByteData fontData =
        (await rootBundle.load('assets/font/Pacifico-Regular.ttf'))
            .buffer
            .asByteData();
    final pw.Font pacificoFont = pw.Font.ttf(fontData);

    final ByteData logo = await rootBundle.load(ImageConstant.homepagelogo);
    Uint8List _logo = logo.buffer.asUint8List();

    // Convert _petImage to Uint8List
    Uint8List imageData;
    if (_petImage is CachedNetworkImageProvider) {
      final networkImage = _petImage as CachedNetworkImageProvider;
      final HttpClientRequest request =
          await HttpClient().getUrl(Uri.parse(networkImage.url));
      final HttpClientResponse response = await request.close();
      final List<int> bytes =
          await consolidateHttpClientResponseBytes(response);
      imageData = Uint8List.fromList(bytes);
    } else if (_petImage is AssetImage) {
      final assetImage = _petImage as AssetImage;
      final ByteData data = await rootBundle.load(assetImage.assetName);
      imageData = data.buffer.asUint8List();
    } else {
      throw Exception('Unsupported image type');
    }

// Use pacificoFont in your text styles
    final pw.TextStyle titleStyle = pw.TextStyle(
      font: pacificoFont,
      fontSize: 40,
      fontWeight: pw.FontWeight.bold,
      color: PdfColor.fromHex('#000000'),
    );
    final pw.TextStyle smallStyle = pw.TextStyle(
      font: pacificoFont,
      fontSize: 10,
      fontWeight: pw.FontWeight.bold,
    );

    final pw.TextStyle regularStyle = pw.TextStyle(fontSize: 16);
    final pw.TextStyle regularBoldStyle = pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold);

    // Calculate age based on Date of Birth
    final int age = calculateAge(selectedDate);

    // Add content to the PDF
    pdf.addPage(
      pw.Page(
        pageTheme: pw.PageTheme(
          pageFormat: PdfPageFormat.standard.landscape,
          orientation: pw.PageOrientation.landscape,
        ),
        build: (pw.Context context) {
          return pw.FullPage(
              ignoreMargins: true,
              child: pw.Container(
                color: PdfColor.fromInt(0xFFD5E8D7), // Set background color
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    // Row for pet name title
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.start,
                      children: [
                        pw.Image(pw.MemoryImage(Uint8List.fromList(_logo)),
                            height: 100),
                        pw.Expanded(
                          child: pw.Center(
                            child: pw.Text(
                              '${_nameController.text}',
                              style: titleStyle,
                            ),
                          ),
                        ),
                      ],
                    ),
                    pw.SizedBox(height: 16),
                    // Row with pet image and pet information
                    pw.Row(
                      children: [
                        pw.SizedBox(width: 5),
                        // Left container with pet image
                        pw.Container(
                          width: 450,
                          child: pw.Container(
                            decoration: pw.BoxDecoration(
                              borderRadius: pw.BorderRadius.circular(10.0),
                              color: PdfColor.fromInt(0xFFD5E8D7), // Set background color
                            ),
                            child: pw.Center(
                              child: pw.Container(
                                width: 450,
                                height: 450,
                                decoration: pw.BoxDecoration(
                                  shape: pw.BoxShape.circle,
                                  border: pw.Border.all(
                                    color: PdfColor.fromInt(0xFF000000), // Black border color
                                    width: 2,
                                  ),
                                ),
                                child: pw.ClipOval(
                                  child: pw.Container(
                                    width: 400,
                                    height: 400,
                                    child: pw.Image(
                                      pw.MemoryImage(imageData),
                                      fit: pw.BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        // Spacer between image and information
                        pw.SizedBox(width: 25),
                        // Right container with pet information
                        pw.Container(
                          width: 325,
                          decoration: pw.BoxDecoration(
                            borderRadius: pw.BorderRadius.circular(60.0),
                            color: PdfColor.fromHex('#F0F0F0'),
                            // White background
                            border: pw.Border.all(
                              color: PdfColor.fromInt(0xFF808080),
                              width: 0.5,
                            ),
                          ),
                          padding: pw.EdgeInsets.all(20),
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              // Age, Date of Birth, Weight, Allergies, Vet Name, Insurance Provider, Neutered, Appointments, More Information
                              pw.Row( children: [
                                pw.Text('Age :', style: regularBoldStyle),
                                pw.Text('$age', style: regularStyle),
                              ]),
                              pw.SizedBox(height: 10),
                              pw.Row( children: [
                              pw.Text('Date of Birth :', style: regularBoldStyle),
                              pw.Text(
                                '${selectedDate != null ? DateFormat('dd-MM-yyyy').format(selectedDate!) : "Not specified"}',
                                style: regularStyle,
                              ),
                               ]),
                              pw.SizedBox(height: 10),
                              pw.Row( children: [
                              pw.Text('Weight: ', style: regularBoldStyle),
                              pw.Text(
                                '${_weightController.text} $_selectedWeightUnit',
                                style: regularStyle,
                              ),
                              ]),
                              pw.SizedBox(height: 10),
                              pw.Row( children: [
                              pw.Text('Allergies: ', style: regularBoldStyle),
                              pw.Text(
                                '${allergies.join(", ")}',
                                style: regularStyle,
                              ),
                              ]),
                              pw.SizedBox(height: 10),
                              pw.Row( children: [
                              pw.Text('Vet Name: ', style: regularBoldStyle),
                              pw.Text(
                                '${_vetNameController.text}',
                                style: regularStyle,
                              ),
                              ]),
                              pw.SizedBox(height: 10),
                              pw.Row( children: [
                              pw.Text('Insurance Provider: ', style: regularBoldStyle),
                              pw.Text(
                                ' ${_insuranceProviderController.text}',
                                style: regularStyle,
                              ),
                              ]),
                              pw.SizedBox(height: 10),
                              pw.Row( children: [
                              pw.Text('Is Pet Neutered?: ', style: regularBoldStyle),
                              pw.Text(
                                ' ${_neutered}',
                                style: regularStyle,
                              ),
                              ]),
                              pw.SizedBox(height: 10),
                              pw.Text(
                                'Appointments:',
                                style: regularBoldStyle,
                              ),
                              pw.SizedBox(height: 10),
                              pw.Text(
                                formatAppointments(
                                    widget.appointments?.toList() ?? []),
                                style: regularStyle,
                              ),
                              pw.SizedBox(height: 10),
                              pw.Text(
                                'More Information: ',
                                style: regularBoldStyle,
                              ),
                              pw.Text(
                                '${_moreInfoController.text.substring(0, _moreInfoController.text.length > 40 ? 40 : _moreInfoController.text.length)}',
                                style: regularStyle,
                              ),
                            ],
                          ),
                        ),
                        pw.SizedBox(width: 5),
                      ],
                    ),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.start,
                      children: [
                        pw.Text(
                              'www.cmpet.co.uk',
                              style: smallStyle,
                            ),
                      ],
                    ),
                  ],
                ),
              ));
        },
      ),
    );

    // Save the PDF as a Uint8List
    final Uint8List pdfData = await pdf.save();

    return pdfData;
  }

  // Function to open the image picker
  Future<void> _openImagePicker() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imagePath =
            pickedFile.path; // Update _imagePath with the selected image path
      });

      // You can also open an upload dialog here and upload the selected image to storage
      // Example: Call _uploadImageToStorage() with _imagePath
      await _uploadImageToStorage(_imagePath);
    }
  }

  // Function to upload the selected image to storage
  Future<void> _uploadImageToStorage(String imagePath) async {
    String imageUrl = await _petService.uploadImageToStorage(imagePath);
    if (imageUrl.isNotEmpty) {
      setState(() {
        _imagePath = imageUrl; // Update _imagePath with the uploaded image URL
        _petImage = CachedNetworkImageProvider(
          imageUrl,
        );
      });
    }
  }

  void _updatePetImage() {
    if (_selectedAnimalType == 'cat') {
      setState(() {
        _petImage =
            AssetImage(ImageConstant.cat); // Replace with actual cat image path
      });
    } else if (_selectedAnimalType == 'snake') {
      setState(() {
        _petImage = AssetImage(
            ImageConstant.snake); // Replace with actual snake image path
      });
    } else if (_selectedAnimalType == 'parrot') {
      setState(() {
        _petImage = AssetImage(
            ImageConstant.parrot); // Replace with actual parrot image path
      });
    } else if (_selectedAnimalType == 'dog') {
      setState(() {
        _petImage = AssetImage(
            ImageConstant.charles); // Replace with actual parrot image path
      });
    } else if (_selectedAnimalType == 'hamster') {
      setState(() {
        _petImage = AssetImage(
            ImageConstant.hamster); // Replace with actual parrot image path
      });
    } else if (_selectedAnimalType == 'bearded_dragon') {
      setState(() {
        _petImage = AssetImage(
            ImageConstant.dragon); // Replace with actual parrot image path
      });
    } else if (_selectedAnimalType == 'guinea_pig') {
      setState(() {
        _petImage = AssetImage(
            ImageConstant.guinea); // Replace with actual parrot image path
      });
    }
  }

  Future<void> _EditNUpdatePetInfo(String? PetDocId) async {
    if (_nameController.text.isNotEmpty) {
      // Format appointments as a list of strings
      List<Appointment> appointmentsData = widget.appointments?.toList() ?? [];

      if (widget.appointments != null || widget.appointments != []) {
        appointmentsData.addAll(widget.appointments!);
      } else {
        // Handle the case where widget.appointments is null
      }
      String? imaging = widget.image;
      if (imaging != _imagePath && _imagePath.startsWith('https')) {
        imaging = _imagePath;
      }

      // Call the _petService's updatePet method with the updated information
      await _petService.updatePet(
          PetDocId!,
          // Replace 'widget.petId' with the actual pet ID
          _nameController.text,
          imaging!,
          _weightController.text,
          allergies,
          _feedingInstructionsController.text,
          medications,
          appointmentsData,
          selectedDate,
          _moreInfoController.text,
          _neutered,
          _vetNameController.text,
          _insuranceProviderController.text);

      Navigator.pop(context);
    }
  }

  Future<void> _updatePetInfo(String selectedAnimalType) async {
    if (_nameController.text.isNotEmpty) {
      // Format appointments as a list of strings
      List<Appointment> appointmentsData = widget.appointments?.toList() ?? [];

      if (widget.appointments != null ||
          widget.appointments != [] ||
          widget.appointments!.isNotEmpty) {
        appointmentsData = appointments.toList();
      } else {
        // Handle the case where widget.appointments is null
      }

      await _petService.addPet(
          _nameController.text,
          _imagePath,
          _weightController.text,
          selectedAnimalType,
          allergies,
          _feedingInstructionsController.text,
          medications,
          appointmentsData ?? [],
          // Pass the list of appointments
          selectedDate,
          _moreInfoController.text,
          _neutered,
          _vetNameController.text,
          _insuranceProviderController.text);
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    analytics_utils.logScreenUsageEvent('MyPetsScreen');

    return Scaffold(
      resizeToAvoidBottomInset: false,
      // fluter 2.x
      appBar: top_bar.CustomTopAppBar(
        Enabled: true,
        onTapArrowLeft: (context) {
          Navigator.pop(context);
        },
        onMenuPressed: toggleMenu,
      ),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200.0,
            floating: true,
            pinned: false,
            automaticallyImplyLeading: false,
            // Set this to false to remove the back button
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                children: [
                  Container(
                    color: Colors.white,
                    // Change this to the desired background color
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Stack(
                            children: [
                              CircleAvatar(
                                radius: 70,
                                child: ClipOval(
                                  child: Image(
                                    image: _petImage,
                                    fit: BoxFit.cover,
                                    width: 100,
                                    // Set the width and height to control the size of the image
                                    height: 100,
                                  ),
                                ),
                              ),
                              CircleAvatar(
                                radius: 70,
                                backgroundImage: _petImage,
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Visibility(
                                  visible: isEditing || widget.petName == null,
                                  // Only show the IconButton if widget.petName is null
                                  child: IconButton(
                                    icon: Icon(
                                      Icons.photo_camera,
                                      size: 30.0,
                                      color: Colors.grey,
                                    ),
                                    onPressed: () {
                                      _openImagePicker(); // Call a function to open the image picker
                                      // Handle image upload here
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Text(
                            widget.petName ?? "",
                            // Use the received petName if provided, else use empty string
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontStyle: FontStyle.italic,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      icon: Icon(Icons.open_in_new, size: 30.0),
                      onPressed: () async {
                        try {
                          _showPopup(context);
                        } catch (e) {
                          print('Error sharing PDF: $e');
                          // Handle the error as needed (e.g., show an error message).
                        }
                      },
                      iconSize: 72,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate(
              [
                SizedBox(
                  height: 100, // Adjust the height as needed
                  child: buildInfoContainer("Name", _nameController, context,
                      isCentered: true),
                ),
                SizedBox(
                  height: 120, // Adjust the height as needed
                  child: buildInfoContainer(
                      "Date Of Birth", buildAgeSection(), context,
                      isCentered: true),
                ),
                SizedBox(
                  height: 150, // Adjust the height as needed
                  child: buildInfoContainer(
                      "Weight", buildWeightContainer(), context,
                      isCentered: true),
                ),
                SizedBox(
                  height: 150, // Adjust the height as needed
                  child: buildInfoContainer(
                      "Allergies", buildAllergiesSection(), context),
                ),
                SizedBox(
                  height: 150, // Adjust the height as needed
                  child: buildInfoContainer(
                    "Appointments",
                    buildAppointmentsSection(
                      context,
                      List.of(appointments), // Create a copy of the list
                      isEditing || widget.petName == null,
                      widget.petId,
                      (List<Appointment> updatedAppointments) {
                        // Update your existing appointments in the parent widget
                        setState(() {
                          appointments.addAll(updatedAppointments);
                        });
                      },
                    ),
                    context,
                  ),
                ),
                SizedBox(
                  height: 150, // Adjust the height as needed
                  child: buildInfoContainer(
                      "Vet Name", buildVetNameContainer(), context,
                      isCentered: true),
                ),
                SizedBox(
                  height: 150, // Adjust the height as needed
                  child: buildInfoContainer("Insurance Provider",
                      buildInsuranceProviderContainer(), context,
                      isCentered: true),
                ),
                SizedBox(
                  height: 150, // Adjust the height as needed
                  child: buildInfoContainer("Pet Neutered?",
                      buildIsNeuteredDropdown(), context,
                      isCentered: true),
                ),
                buildInfoContainer(
                    "More Information", _moreInfoController, context,
                    isCentered: true),
                Visibility(
                  visible: widget.petName == null,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 25.0),
                    // Adjust the top padding as needed
                    child: Center(
                      child: ElevatedButton(
                        onPressed: () {
                          if (widget.petName == null) {
                            // Handle the save button press when the name is empty
                            _updatePetInfo(_selectedAnimalType);
                            // Show a success message using a SnackBar
                            final snackBar = SnackBar(
                              content: Text('Pet details are saved.',
                                  style: TextStyle(color: Colors.white)),
                              backgroundColor: Colors.green,
                            );
                            ScaffoldMessenger.of(context)
                                .showSnackBar(snackBar);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF008C8C),
                        ),
                        child:
                            Text("Save", style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  ),
                ),
                Visibility(
                  visible: widget.petName != null,
                  child: IconButton(
                    icon: Icon(isEditing ? Icons.save : Icons.edit),
                    onPressed: () {
                      if (isEditing) {
                        _EditNUpdatePetInfo(widget.petId);
                        // Show a success message using a SnackBar
                        final snackBar = SnackBar(
                          content: Text('Pet details are updated.',
                              style: TextStyle(color: Colors.white)),
                          backgroundColor: Colors.green,
                        );
                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      }
                      setState(() {
                        isEditing = !isEditing;
                      });
                    },
                    iconSize: 30.0,
                  ),
                ),
                SizedBox(height: 70.0)
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: Container(
        height: 80.0,
        width: 80.0,
        child: FittedBox(
          child: FloatingActionButton(
            backgroundColor:
                Color(0xFF008C8C), // Set the background color to blue
            child:
                Image.asset(ImageConstant.searchbutton, width: 40, height: 40),
            shape: RoundedRectangleBorder(
              side: BorderSide(
                  color: ColorConstant.fromHex('#a3ccff'), width: 2.0),
              borderRadius: BorderRadius.circular(
                  28.0), // Adjust the border radius as needed
            ),
            onPressed: () {
              // Check if the current route is not already the search route

              if (ModalRoute.of(context)!.settings.name !=
                  AppRoutes.barcodeScreen) {
                Navigator.pushReplacement(
                  context,
                  AppRoutes.generateRoute(
                    RouteSettings(name: AppRoutes.barcodeScreen),
                  ),
                );
              }
            },
          ),
        ),
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

  Widget buildInfoContainer(String header, dynamic info, BuildContext context,
      {bool isCentered = false, List<Appointment>? appointments}) {
    int maxLines = 1; // Default to one line

    if (header == 'Feeding instructions' || header == 'More Information') {
      maxLines =
          3; // Set maxLines to 3 for multi-line input for specific fields
    }
    print('Appt ms are $appointments');
    if (header == 'Appointments' &&
        appointments != null &&
        appointments.isNotEmpty) {
      // Calculate and set the next appointment date
      final nextAppointmentDate = calculateNextAppointmentDate(appointments);
      info = nextAppointmentDate != null
          ? "Next Appointment is ${nextAppointmentDate.day}/${nextAppointmentDate.month}/${nextAppointmentDate.year}"
          : "No upcoming appointments";
    }

    return Container(
      constraints: BoxConstraints(minHeight: 200),
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                header,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              if (isCentered && header == 'Name')
                Expanded(
                  child: Center(
                    child: Container(
                      width: 120,
                      child: info is TextEditingController
                          ? TextField(
                              controller: info,
                              decoration: InputDecoration(
                                hintText: 'Enter pet name',
                                contentPadding:
                                    EdgeInsets.symmetric(vertical: 4),
                              ),
                              maxLines: maxLines, // Set maxLines conditionally
                              enabled: isEditing ||
                                  widget.petName ==
                                      null, // Only enable the field if in edit mode // Disable the field
                            )
                          : info is Widget
                              ? info
                              : Text(info.toString()),
                    ),
                  ),
                )
              else if (isCentered && header == 'More Information')
                Expanded(
                  child: Center(
                    child: Container(
                      width: 150,
                      child: info is TextEditingController
                          ? TextField(
                              controller: info,
                              decoration: InputDecoration(
                                hintText: '40 Characters Limit',
                                contentPadding:
                                    EdgeInsets.symmetric(vertical: 4),
                              ),
                              maxLines: maxLines, // Set maxLines conditionally
                              enabled: isEditing ||
                                  widget.petName == null, // Disable the field
                            )
                          : info is Widget
                              ? info
                              : Text(info.toString()),
                    ),
                  ),
                )
              else if (isCentered)
                Expanded(
                  child: Center(
                    child: Container(
                      width: 150,
                      child: info is TextEditingController
                          ? TextField(
                              controller: info,
                              decoration: InputDecoration(
                                hintText: 'Extra Information',
                                contentPadding:
                                    EdgeInsets.symmetric(vertical: 4),
                              ),
                              maxLines: maxLines, // Set maxLines conditionally
                              enabled: isEditing ||
                                  widget.petName == null, // Disable the field
                            )
                          : info is Widget
                              ? info
                              : Text(info.toString()),
                    ),
                  ),
                )
              else if (header == 'Name' && widget.petName == null)
                Expanded(
                  child: Center(
                    child: Container(
                      width: 80,
                      child: info is TextEditingController
                          ? TextField(
                              controller: info,
                              decoration: InputDecoration(
                                hintText: 'Enter pet name',
                                contentPadding:
                                    EdgeInsets.symmetric(vertical: 1),
                              ),
                              maxLength: 10,
                              // Set the maximum length to 10 characters
                              enabled: isEditing ||
                                  widget.petName == null, // Disable the field
                            )
                          : info is Widget
                              ? info
                              : Text(info.toString()),
                    ),
                  ),
                )
              else
                Expanded(
                  child: Center(
                    child: info is String
                        ? Text(info)
                        : info is Widget
                            ? info
                            : IgnorePointer(
                                ignoring: isEditing || widget.petName == null,
                                // Ignore user input based on the condition
                                child: TextField(
                                  controller: TextEditingController(),
                                  decoration: InputDecoration(
                                    hintText: '',
                                    contentPadding:
                                        EdgeInsets.symmetric(vertical: 4),
                                  ),
                                  maxLines:
                                      maxLines, // Set maxLines conditionally
                                ),
                              ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  DateTime? calculateNextAppointmentDate(List<Appointment> appointments) {
    if (appointments.isEmpty) {
      return null;
    }

    DateTime? nextAppointmentDate;

    for (var appointment in appointments) {
      if (nextAppointmentDate == null ||
          appointment.date.isBefore(nextAppointmentDate)) {
        nextAppointmentDate = appointment.date;
      }
    }

    return nextAppointmentDate;
  }

  Widget buildAgeSection() {
    bool isDateSelectionDisabled = !isEditing &&
        widget.petName !=
            null; // Determine if date selection should be disabled

    return Container(
      height: 80,
      child: Column(
        children: [
          ListTile(
            title: Text("Date"),
            subtitle: selectedDate != null
                ? Text(
                    "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}")
                : Text("Select a date"),
            onTap: isDateSelectionDisabled
                ? null // Set onTap to null to disable date selection
                : () {
                    _selectDate(context); // Show the date picker when tapped
                  },
          ),
        ],
      ),
    );
  }

  // Function to show the date picker
  Future<void> _selectDate(BuildContext context) async {
    final DateTime picked = (await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      // Use the selected date or today's date
      firstDate: DateTime(2000),
      // Adjust the range as needed
      lastDate: DateTime(2101), // Adjust the range as needed
    ))!;
    if (picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Widget buildAllergiesSection() {
    bool isButtonDisabled = !isEditing && widget.petName != null;

    return Column(
      children: [
        Wrap(
          spacing: 8, // Adjust the spacing between pills as needed
          children: List<Widget>.generate(allergies.length, (int index) {
            final allergy = allergies[index];
            return GestureDetector(
              onTap: isButtonDisabled
                  ? null
                  : () {
                      // Remove the selected allergy when tapped
                      removeAllergy(index);
                    },
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                decoration: BoxDecoration(
                  color: Colors.blue, // You can adjust the color
                  borderRadius: BorderRadius.circular(
                      16), // Adjust the border radius as needed
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(allergy, style: TextStyle(color: Colors.white)),
                    if (!isButtonDisabled)
                      Padding(
                        padding: const EdgeInsets.only(left: 4),
                        child: GestureDetector(
                          onTap: () {
                            // Remove the selected allergy when "x" is tapped
                            removeAllergy(index);
                          },
                          child: Icon(
                            Icons.clear,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          }),
        ),
        SizedBox(height: 16), // Add spacing if the button is disabled
        ElevatedButton(
          onPressed: !isButtonDisabled
              ? () {
                  showAddAllergyDialog(); // Show the AlertDialog to add allergies
                }
              : null,
          child: Text('Add Allergy', style: TextStyle(color: Colors.white)),
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF008C8C),
          ),
        ),
      ],
    );
  }

  void showAddAllergyDialog() {
    String selectedNewAllergy =
        allergyOptions[0]; // Default to the first option

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text('Add Allergy'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButton<String>(
                    value: selectedNewAllergy,
                    items: allergyOptions.map((String allergy) {
                      return DropdownMenuItem<String>(
                        value: allergy,
                        child: Text(allergy),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedNewAllergy = newValue ?? '';
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                  },
                  child: Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    addAllergy(selectedNewAllergy);
                    Navigator.of(context).pop(); // Close the dialog
                  },
                  child: Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget buildWeightContainer() {
    return Container(
      height: 100,
      constraints: BoxConstraints(minHeight: 50),
      padding: EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        // Center the child widgets horizontally
        children: [
          Container(
            width: 100, // Set a specific width for the text field
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _weightController,
                    decoration: InputDecoration(
                      hintText: 'Enter weight',
                      contentPadding: EdgeInsets.symmetric(vertical: 8),
                    ),
                    keyboardType:
                        TextInputType.numberWithOptions(decimal: true),
                    enabled: isEditing ||
                        widget.petName ==
                            null, // Disable the field if isFieldDisabled is true
                  ),
                ),
                SizedBox(width: 10),
                Text('kg',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  int calculateAge(DateTime? birthDate) {
    if (birthDate == null) {
      return 0; // Handle the case where birthDate is null
    }

    final currentDate = DateTime.now();
    int age = currentDate.year - birthDate.year;

    // Check if the birthday has occurred this year
    if (currentDate.month < birthDate.month ||
        (currentDate.month == birthDate.month &&
            currentDate.day < birthDate.day)) {
      age--;
    }

    return age;
  }

  Widget buildVetNameContainer() {
    return Container(
      height: 100,
      constraints: BoxConstraints(minHeight: 100),
      padding: EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _vetNameController,
                    decoration: InputDecoration(
                      hintText: 'Enter vet name',
                      contentPadding: EdgeInsets.symmetric(vertical: 8),
                    ),
                    enabled: isEditing || widget.petName == null,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildInsuranceProviderContainer() {
    return Container(
      height: 100,
      constraints: BoxConstraints(minHeight: 50),
      padding: EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _insuranceProviderController,
                    decoration: InputDecoration(
                      hintText: 'Enter insurance provider',
                      contentPadding: EdgeInsets.symmetric(vertical: 8),
                    ),
                    enabled: isEditing || widget.petName == null,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildIsNeuteredDropdown() {
    return DropdownButton<bool>(
      value: _neutered,
      enableFeedback: isEditing || widget.petName == null,
      // Enable/disable based on conditions
      elevation: 16,
      style: TextStyle(color: Colors.black),
      underline: Container(
        height: 2,
        color: Colors.grey,
      ),
      onChanged: (bool? newValue) {
        if (isEditing || widget.petName == null) {
          // Only update the value if enabled
          setState(() {
            _neutered = newValue ?? false;
          });
        }
      },
      items: <bool>[true, false].map<DropdownMenuItem<bool>>((bool value) {
        return DropdownMenuItem<bool>(
          value: value,
          child: Text(
            value ? 'Yes' : 'No',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      }).toList(),
    );
  }

  void _showPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Container(
            padding: EdgeInsets.all(16),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ElevatedButton(
                  onPressed: () async {
                    try {
                      Navigator.pop(context); // Close the popup
                      await sharePdf(widget.petName ?? 'Pet', _petImage);
                    } catch (e) {
                      print('Error sharing PDF: $e');
                      // Handle the error as needed (e.g., show an error message).
                    }
                  },
                  child: Text('Share'),
                ),
                SizedBox(width: 15),
                ElevatedButton(
                  onPressed: () {
                    requestDownload(widget.petName ?? 'Pet', _petImage);
                    Navigator.pop(context); // Close the popup
                  },
                  child: Text('Download'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget buildMedicationSection() {
    return Column(
      children: [
        for (int i = 0; i < medications.length; i++)
          ListTile(
            title: Center(
              child: Text(medications[i]),
            ),
            trailing: IconButton(
              icon: Icon(Icons.delete),
              onPressed: () {
                removeMedication(i);
              },
            ),
          ),
        ElevatedButton(
          onPressed: () {
            // Show a dialog or form to input the new medication
            TextEditingController medicationController =
                TextEditingController();
            showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: Text('Add Medication'),
                  content: TextField(
                    controller: medicationController,
                    // Use the controller to capture text input
                    decoration: InputDecoration(
                      hintText: 'Enter new medication',
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(); // Close the dialog
                      },
                      child: Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        String newMedication = medicationController
                            .text; // Get text from the controller
                        addMedication(newMedication);
                        Navigator.of(context).pop(); // Close the dialog
                      },
                      child: Text('Add'),
                    ),
                  ],
                );
              },
            );
          },
          child: Text('Add Medication'),
        ),
      ],
    );
  }
}
