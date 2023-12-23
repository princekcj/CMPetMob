import 'dart:io';
import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_html/flutter_html.dart';

import 'package:cmpets/widgets/app_bar/custom_app_drawer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/utils/analytics_utils.dart' as analytics_utils;
import 'package:flutter/material.dart';
import 'package:cmpets/core/app_export.dart';
import 'package:cmpets/widgets/app_bar/topappbar.dart' as top_bar;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:pdf/pdf.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import '../../auth/Auth_provider.dart';
import '../../core/utils/retrieve_wordpress_post.dart';
import '../../services/leaderboard.dart';
import '../../widgets/app_bar/custom_app_bar.dart';
import '../../widgets/app_bar/topappbar.dart';

class HomeAdobeExpressOneScreen extends StatefulWidget {
  const HomeAdobeExpressOneScreen({Key? key}) : super(key: key);

  @override
  _HomeAdobeExpressOneScreenState createState() =>
      _HomeAdobeExpressOneScreenState();
}

class _HomeAdobeExpressOneScreenState extends State<HomeAdobeExpressOneScreen> {
  bool isMenuOpen = false;
  List<Map<String, dynamic>> leaderboardData = [];
  NativeAd? _nativeAd;
  bool _nativeAdIsLoaded = false;
  late YoutubeExplode _ytExplode;
  bool isLeaderboardExpanded = false;
  FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  final Duration maxCacheDuration = Duration(hours: 4);
  /// Keep track of load time so we don't show an expired ad.
  DateTime? _appOpenLoadTime;


  // Create a list to store AdWidgets
  List<AdWidget> adWidgets = [];
  late String adUnitId; // Replace with your actual AdMob ad unit ID
  int loadedAdCount = 0;
  int totalAdCount = 0;
  List<WordPressPost> possibleBlogUrls = [];

  void toggleMenu() {
    setState(() {
      isMenuOpen = !isMenuOpen;
    });
    print(" iss wrking or $isMenuOpen");
  }

  List<PetFact> possiblePetFacts = [

    // Add more blog URLs as needed
  ];


  @override
  void initState() {
    super.initState();
    // Fetch leaderboard data
    fetchLeaderboard().then((data) {
      print("leader data is $data");
      setState(() {
        leaderboardData = data;
      });
    });
    // Start fetching the latest posts
    getPetFacts().then((List<PetFact> facts) {
      // This block will be executed when the Future completes
      print("pet facts is $facts");
      setState(() {
        possiblePetFacts = facts;
      });
    });

    // Start fetching the latest posts
    getLatestPosts().then((List<WordPressPost> posts) {
      // This block will be executed when the Future completes
      setState(() {
        possibleBlogUrls = posts;
      });
    });
    _ytExplode = YoutubeExplode();
    _initGoogleMobileAds();

    if (Platform.isAndroid) {
      setState(() {
        adUnitId = "ca-app-pub-3940256099942544/2247696110";
      });
    } else if (Platform.isIOS) {
      setState(() {
        adUnitId = "ca-app-pub-3940256099942544/3986624511";
      });
    } else {
      throw UnsupportedError("Unsupported platform");
    }
  }


  List<Map<String, dynamic>> carouselsData = [
    {
      'label': 'Carousel 1',
      'items': [
        'Feedback Link',
        'Leaderboard',
        'Ad',
        'Feedback Link',
      ],
    },
    {
      'label': 'Carousel 2',
      'items': [
        'Blog',
        'Ad',
        'Blog',
        'Blog',
      ],
    },
    {
      'label': 'Carousel 3',
      'items': [
        'YouTube Recent Video',
        'Pet Fact',
        'Pet Fact',
        'Ad',
      ],
    },
  ];

  @override
  Widget build(BuildContext context) {
    analytics_utils.logScreenUsageEvent('Home');

    // Wait for ads to load before rendering the ListView.builder

    return Scaffold(
      resizeToAvoidBottomInset: false, // fluter 2.x
      endDrawer: CustomDrawer(),
      appBar: CustomTopAppBar(
        Enabled: false,
        onTapArrowLeft: (context) {
          Navigator.pop(context);
        },
        onMenuPressed: toggleMenu
      ),
      body: ListView.builder(
        itemCount: carouselsData.length,
        itemBuilder: (context, index) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 36),
              CarouselSlider(
                options: CarouselOptions(
                  height: 200,
                  enableInfiniteScroll: false,
                  enlargeCenterPage: true,
                  viewportFraction: 0.8,
                ),
                items: carouselsData[index]['items'].map<Widget>((item) {
                  if (item == 'Ad' ) {
                    return FutureBuilder<void>(
                      future: initAds(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Container(
                            height: 200,
                            color: Colors.white, // Placeholder color
                            child: Center(
                              child: CircularProgressIndicator(color: Color(0xFF008C8C)), // Loading indicator
                            ),
                          );
                        } else if (snapshot.connectionState == ConnectionState.done) {
                          // Find the AdWidget corresponding to this 'Ad' item
                          AdWidget? adWidget = adWidgets.isNotEmpty ? adWidgets.removeAt(0) : null;

                          // Display the AdMob banner ad if available, otherwise show a placeholder
                          return adWidget ??
                              Container(
                                height: 200,
                                color: Colors.white, // Placeholder color
                              );
                        } else {
                          return Container(
                            height: 200,
                            color: Colors.white, // Placeholder color
                          );
                        }
                      },
                    );
                  }
                  else if (item == 'YouTube Recent Video') {
                    String displayUrl = 'https://www.youtube.com/shorts/0hOWcur29Hc';
                    // Display YouTube video thumbnail
                    return FutureBuilder<String>(
                      future: _getYouTubeThumbnailUrl(displayUrl),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator(color: Color(0xFF008C8C)));
                        } else if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        } else if (snapshot.hasData) {
                          return InkWell(
                            onTap: () {
                              final Uri ytURL = Uri.parse(displayUrl);
                              _launch(ytURL);
                            },
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8.0), // Set the border radius
                              child: CachedNetworkImage(imageUrl: snapshot.data!),
                            ),
                          );
                        } else {
                          return Container(
                            height: 200,
                            decoration: BoxDecoration(
                              color: Colors.grey, // Placeholder color
                              borderRadius: BorderRadius.circular(8.0), // Set the border radius
                            ),
                            child: Center(
                              child: CircularProgressIndicator(color: Color(0xFF008C8C)),
                            ),
                          );
                        }
                      },
                    );
                  } else if (item == 'Leaderboard'){
                    // Inside your build method
                    // Display the leaderboard
                    return InkWell(
                      onTap: () {
                        // Toggle the leaderboard expansion state
                        // Show the leaderboard in a popup
                          _showLeaderboardPopup();
                      },
                      child: Container(
                        height: 200,
                        decoration: BoxDecoration(
                          color: Color(0xFF008C8C), // Customize the background color
                          borderRadius: BorderRadius.circular(8.0), // Set the border radius
                        ),
                        child: Center(
                          child: Text(
                            'Leaderboard',
                            style: TextStyle(color: Colors.white, fontSize: 24),
                          ),
                        ),
                      ),
                    );
                  } else if (item == 'Blog') {
                    if (possibleBlogUrls.isNotEmpty) {
                      WordPressPost? post = getRandomPost(possibleBlogUrls);
                      return InkWell(
                        onTap: () {
                          final Uri postURL = Uri.parse(post!.link);
                          _launch(postURL);
                        },
                        child: Container(
                          height: 200,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: CachedNetworkImageProvider(post!.contentSrc),
                              fit: BoxFit.cover,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Stack(
                            children: [
                              Positioned(
                                top: 0,
                                left: 0,
                                right: 0,
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.white.withOpacity(1.0),
                                        Colors.white.withOpacity(0.9),
                                        Colors.white.withOpacity(0.1),
                                      ],
                                    ),
                                  ),
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 16.0, vertical: 8.0),
                                  child: Html(
                                    data: post.title,
                                    style: {
                                      'body': Style(
                                        color: Colors.black,
                                        // Change the text color as needed
                                        fontSize: FontSize(24),
                                      ),
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    } else {
                      return Container(
                        child: Center(
                          child: CircularProgressIndicator(color: Color(0xFF008C8C)),
                        ),
                      );
                    }
                  } else if (item == 'Feedback Link') {
                    // 'Feedback Link' logic to open Google Form
                    return InkWell(
                      onTap: () {
                        launchGoogleForm(); // Function to open Google Form
                      },
                      child: Container(
                        height: 200,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage(ImageConstant.feedback),
                            fit: BoxFit.cover,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Stack(
                          children: [
                            Positioned(
                              top: 0,
                              left: 0,
                              right: 0,
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.white.withOpacity(1.0),
                                      Colors.white.withOpacity(0.9),
                                      Colors.white.withOpacity(0.1),
                                    ],
                                  ),
                                ),
                                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                                child: Html(
                                  data: '',
                                  style: {
                                    'body': Style(
                                      color: Colors.black, // Change the text color as needed
                                      fontSize: FontSize(24),
                                    ),
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  } else if (item == 'Pet Fact') {
                    // 'Feedback Link' logic to open Google Form
                    PetFact Fact = getRandomPetFacts();
                    return InkWell(
                      onTap: () {
                      },
                      child: Container(
                        height: 200,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: CachedNetworkImageProvider(Fact.img),
                            fit: BoxFit.cover,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Stack(
                          children: [
                            Positioned(
                              top: 0,
                              left: 0,
                              right: 0,
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.white.withOpacity(1.0),
                                      Colors.white.withOpacity(0.9),
                                      Colors.white.withOpacity(0.1),
                                    ],
                                  ),
                                ),
                                padding: EdgeInsets.symmetric(
                                    horizontal: 16.0, vertical: 8.0),
                                child: Html(
                                  data: Fact.fact,
                                  style: {
                                    'body': Style(
                                      color: Colors.black,
                                      // Change the text color as needed
                                      fontSize: FontSize(14),
                                    ),
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }  else {
                    // Display other items
                    return Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blueGrey,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          item,
                          style: TextStyle(color: Colors.white, fontSize: 24),
                        ),
                      ),
                    );
                  }
                }).toList(),
              ),
              SizedBox(height: 36),
            ],
          );
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

  Future<void> initAds() async {
    // Load cached ad if within maxCacheDuration and count matches
    if (_nativeAd != null &&
        _appOpenLoadTime != null &&
        DateTime.now().subtract(maxCacheDuration).isBefore(_appOpenLoadTime!)) {
      print('Using cached ad.');
      AdWidget adWidget = AdWidget(ad: _nativeAd!);
      adWidgets.add(adWidget);
      // Check if all ad widgets (including cached ones) are loaded
      if (adWidgets.length == totalAdCount) {
        _nativeAdIsLoaded = true;
      }
    } else {
      // Create the ad objects and load ads.
      for (int i = 0; i < carouselsData.length; i++) {
        List<dynamic> items = carouselsData[i]['items'];

        for (int j = 0; j < items.length; j++) {
          if (items[j] == 'Ad') {
            totalAdCount++;

            NativeAd nativeAd = NativeAd(
              adUnitId: adUnitId,
              request: AdRequest(),
              listener: NativeAdListener(
                onAdLoaded: (Ad ad) {
                  print('$NativeAd loaded.');
                  loadedAdCount++;

                  if (loadedAdCount == totalAdCount) {
                    _nativeAdIsLoaded = true;
                    _appOpenLoadTime = DateTime.now();
                  }
                },
                onAdFailedToLoad: (Ad ad, LoadAdError error) {
                  print('$NativeAd failedToLoad: $error');
                  ad.dispose();

                  if (loadedAdCount == totalAdCount) {
                    _nativeAdIsLoaded = true;
                  }
                },
                onAdOpened: (Ad ad) => print('$NativeAd onAdOpened.'),
                onAdClosed: (Ad ad) => print('$NativeAd onAdClosed.'),
              ),
              nativeTemplateStyle: NativeTemplateStyle(
                templateType: TemplateType.medium,
                mainBackgroundColor: Colors.white12,
                callToActionTextStyle: NativeTemplateTextStyle(
                  size: 16.0,
                ),
                primaryTextStyle: NativeTemplateTextStyle(
                  textColor: Colors.black38,
                  backgroundColor: Colors.white70,
                ),
              ),
            )..load();

            AdWidget adWidget = AdWidget(ad: nativeAd);
            adWidgets.add(adWidget);
          }
        }
      }
    }
  }


  Future<InitializationStatus> _initGoogleMobileAds() {
    // TODO: Initialize Google Mobile Ads SDK
    return MobileAds.instance.initialize();
  }

  Future<String> _getYouTubeThumbnailUrl(String videoId) async {
    var video = await _ytExplode.videos.get(videoId);
    return video.thumbnails.maxResUrl;
  }

  void _launch(Uri videoUrl) async {
    if (!await launchUrl(
      videoUrl,
      mode: LaunchMode.inAppBrowserView,
    )) {
      throw Exception('Could not launch $videoUrl');
    }
  }

  // Function to open Google Form
  void launchGoogleForm() async {
    final Uri googleFormUrl = Uri.parse('https://docs.google.com/forms/d/e/your-form-id/viewform'); // Replace with your Google Form URL
    if (!await launchUrl(
      googleFormUrl,
      mode: LaunchMode.inAppBrowserView,
    )) {
      throw Exception('Could not launch $googleFormUrl');
    }
  }

  // Function to show the leaderboard in a popup
  void _showLeaderboardPopup() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Leaderboard'),
          content: Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8), // Adjust padding as needed
            // Customize the height and width of the popup
            height: 300,
            width: double.infinity,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DataTable(
                    dataRowHeight: 50,
                    columns: [
                      DataColumn(label: Text('Rank')),
                      DataColumn(label: Text('User')),
                      DataColumn(label: Text('Scan Count')),
                    ],
                    columnSpacing: 8,
                    headingRowHeight: 40,
                    horizontalMargin: 0,
                    rows: List<DataRow>.generate(leaderboardData.length, (index) {
                      int rank = index + 1;
                      var leader = leaderboardData[index];

                      return DataRow(
                        cells: [
                          DataCell(Text(rank.toString())),
                          DataCell(Text(
                            leader['displayName'],
                            style: TextStyle(fontSize: 8),
                          )),
                          DataCell(Text(leader['scanCount'].toString())),
                        ],
                      );
                    }),
                  ),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                // Close the popup
                Navigator.of(context).pop();
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  // Function to pick a random post
  WordPressPost? getRandomPost(List<WordPressPost> posts) {
    if (posts.isNotEmpty) {
      final Random random = Random();
      return posts[random.nextInt(posts.length)];
    }
    return null;
  }

  // Function to randomly select a blog URL
  PetFact getRandomPetFacts() {
    final Random random = Random();
    print("pets one is $possiblePetFacts");

    if (possiblePetFacts.isNotEmpty) {
      return possiblePetFacts[random.nextInt(possiblePetFacts.length)];
    } else {
      // Handle the case where possiblePetFacts is empty.
      // Return a default PetFact instance or handle the case as needed
      return PetFact(fact: "No pet facts available", img: "");
    }
  }

  @override
  void dispose() {
    super.dispose();
    _ytExplode.close();
    _nativeAd?.dispose();
  }
}
