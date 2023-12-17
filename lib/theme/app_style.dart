import 'package:flutter/material.dart';
import 'package:cmpets/core/app_export.dart';

class AppStyle {
  static TextStyle txtRobotoRegular16 = TextStyle(
    color: ColorConstant.blueGray400,
    fontSize: getFontSize(
      16,
    ),
    fontFamily: 'Roboto',
    fontWeight: FontWeight.w400,
  );

  static TextStyle txtRobotoRegular20 = TextStyle(
    color: ColorConstant.black90002,
    fontSize: getFontSize(
      20,
    ),
    fontFamily: 'Roboto',
    fontWeight: FontWeight.w400,
  );
}
