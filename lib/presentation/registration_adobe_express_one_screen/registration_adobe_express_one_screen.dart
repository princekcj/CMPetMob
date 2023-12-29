import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:cmpets/core/app_export.dart';
import 'package:cmpets/widgets/app_bar/topappbar.dart' as top_bar;
import 'package:flutter_svg_provider/flutter_svg_provider.dart' as fs;
import 'package:cmpets/routes/app_routes.dart' as routes;
import '../../core/utils/analytics_utils.dart' as analytics_utils;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/Auth_provider.dart';
import '../../auth/google.dart';
import '../../services/url_launchers.dart';

class RegistrationAdobeExpressOneScreen extends StatefulWidget {
  const RegistrationAdobeExpressOneScreen({Key? key}) : super(key: key);

  @override
  _RegistrationAdobeExpressOneScreenState createState() =>
      _RegistrationAdobeExpressOneScreenState();
}

class _RegistrationAdobeExpressOneScreenState
    extends State<RegistrationAdobeExpressOneScreen> {
  String? selectedOption;
  String? selectedExpOption;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmpasswordController = TextEditingController();
  final TextEditingController forenameController = TextEditingController();
  final TextEditingController surnameController = TextEditingController();
  final authService = ProviderContainer().read(authProvider);
  bool _agreeToTerms = false;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    analytics_utils.logScreenUsageEvent('Registration');
    UrlLauncherUtils urlLauncherUtils = UrlLauncherUtils();

    return SafeArea(
      child: Scaffold(
        appBar: top_bar.CustomTopAppBar(
          Enabled: true,
          onTapArrowLeft: (context) {
            Navigator.pop(context);
          },
        ),
        body: ProviderScope(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 60),
            child: Column(
              children: [
                SizedBox(height: 30),
                TextField(
                  controller: forenameController,
                  decoration: InputDecoration(
                    hintText: 'Forename',
                    hintStyle: TextStyle(color: Colors.grey),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                  ),
                ),
                SizedBox(height: 5),
                TextField(
                  controller: surnameController,
                  decoration: InputDecoration(
                    hintText: 'Surname',
                    hintStyle: TextStyle(color: Colors.grey),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                  ),
                ),
                SizedBox(height: 5),
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    hintText: 'Email Address',
                    hintStyle: TextStyle(color: Colors.grey),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                  ),
                ),
                SizedBox(height: 5),
                TextField(
                  controller: passwordController,
                  obscureText: !_isPasswordVisible,
                  decoration: InputDecoration(
                    hintText: 'Password',
                    hintStyle: TextStyle(color: Colors.grey),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                  ),
                ),
                SizedBox(height: 5),
                TextField(
                  controller: confirmpasswordController,
                  obscureText: !_isConfirmPasswordVisible,
                  decoration: InputDecoration(
                    hintText: 'Confirm Password',
                    hintStyle: TextStyle(color: Colors.grey),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isConfirmPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                        });
                      },
                    ),
                  ),
                ),
                SizedBox(height: 5),
                DropdownButtonFormField<String>(
                  value: selectedOption,
                  onChanged: (value) {
                    setState(() {
                      selectedOption = value;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'How did you hear about us?',
                    hintStyle: TextStyle(color: Colors.grey),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                  ),
                  items: [
                    DropdownMenuItem<String>(
                      value: 'Word of Mouth',
                      child: Text('Word of Mouth'),
                    ),
                    DropdownMenuItem<String>(
                      value: 'Social Media',
                      child: Text('Social Media'),
                    ),
                    DropdownMenuItem<String>(
                      value: 'Physical Poster',
                      child: Text('Physical Poster'),
                    ),
                  ],
                ),
                SizedBox(height: 5),
                DropdownButtonFormField<String>(
                  value: selectedExpOption,
                  onChanged: (value) {
                    setState(() {
                      selectedExpOption = value;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Experience Level',
                    hintStyle: TextStyle(color: Colors.grey),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                  ),
                  items: [
                    DropdownMenuItem<String>(
                      value: 'This is my first pet',
                      child: Text('This is my first pet'),
                    ),
                    DropdownMenuItem<String>(
                      value: 'I have had pets in the past',
                      child: Text('I have had pets in the past'),
                    ),
                    DropdownMenuItem<String>(
                      value: 'Pet Pro',
                      child: Text("I am a ‘pet pro’"),
                    ),
                  ],
                ),
                // Checkbox for agreeing to terms
                CheckboxListTile(
                  title: RichText(
                    text: TextSpan(
                      text: 'I agree to the ',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.black
                      ),
                      children: <TextSpan>[
                        TextSpan(
                          text: 'Terms and Conditions',
                          style: TextStyle(
                            color: Colors.blue,
                            fontSize: 12,
                            decoration: TextDecoration.underline,
                          ),
                          // Add a gesture recognizer for the hyperlink
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              // Navigate to the Terms of Use screen or open the link
                              // You can implement the navigation or link opening logic here
                              final Uri tcURL = Uri.parse('https://cmpet.co.uk/index.php/terms-of-use/');
                              urlLauncherUtils.launchInBrowser(tcURL);
                            },
                        ),
                      ],
                    ),
                  ),
                  value: _agreeToTerms,
                  onChanged: (value) {
                    setState(() {
                      _agreeToTerms = value ?? false;
                    });
                  },
                ),
                SizedBox(height: 15),
              ElevatedButton(
                onPressed: () async {
                  if (_agreeToTerms) {
                    if (passwordController.text == confirmpasswordController.text && passwordController.text.length >= 8) {
                      try {
                        await authService.register(
                          emailController.text,
                          passwordController.text,
                          forenameController.text,
                          surnameController.text,
                          selectedOption ?? '',
                          selectedExpOption ?? '',
                        );
                        Navigator.pushReplacementNamed(context, AppRoutes.barcodeScreen);
                      } catch (e) {
                        print('Registration error: $e');
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: Text('Password Error'),
                              content: Text("$e"),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: Text('OK'),
                                ),
                              ],
                            );
                          },
                        );
                      }
                    } else {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text('Password Mismatch'),
                            content: Text('The entered passwords do not match and/or less than 8 characters.'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Text('OK'),
                              ),
                            ],
                          );
                        },
                      );
                    }
                  } else {
                    // Show a popup if the checkbox is not checked
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: Text('Terms and Conditions'),
                          content: Text('Please agree to the Terms and Conditions before registering.'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text('OK'),
                            ),
                          ],
                        );
                      },
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.blue,
                  side: BorderSide(color: Colors.grey),
                ),
                child: Text('Register'),
              ),
                SizedBox(height: 15),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
