import 'package:flutter/material.dart';

import 'image_constant.dart';

class ImageCachingUtils {
  static final ImageCache _imageCache = ImageCache();

  static final List<String> petImagePaths = [
    ImageConstant.cat,
    ImageConstant.snake,
    ImageConstant.parrot,
    ImageConstant.charles,
    ImageConstant.guinea,
    ImageConstant.dragon,
    ImageConstant.hamster,
    ImageConstant.feedback,
    ImageConstant.searchbutton
  ];

  static void precachePetImages(BuildContext context) {
    for (final imagePath in petImagePaths) {
      _imageCache.evict(_getImageProvider(imagePath));
      precacheImage(_getImageProvider(imagePath), context);
    }
  }

  static ImageProvider _getImageProvider(String imagePath) {
    if (imagePath.startsWith("https")) {
      return NetworkImage(imagePath);
    } else {
      return AssetImage(imagePath);
    }
  }
}
