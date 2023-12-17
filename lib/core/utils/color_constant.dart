import 'dart:ui';
import 'package:flutter/material.dart';

class ColorConstant {
  static Color gray90002 = fromHex('#001a1a');

  static Color gray400 = fromHex('#bbb4b1');

  static Color blueGray100 = fromHex('#dad6d2');

  static Color gray500 = fromHex('#b0a7a0');

  static Color blueGray400 = fromHex('#888888');

  static Color cyan90001 = fromHex('#016767');

  static Color blueGray10001 = fromHex('#d4d4d7');

  static Color gray900 = fromHex('#302d25');

  static Color gray90001 = fromHex('#002223');

  static Color blueGray10002 = fromHex('#cccccc');

  static Color blueGray10003 = fromHex('#cecece');

  static Color gray300 = fromHex('#e5e4e5');

  static Color gray30001 = fromHex('#e5e4e6');

  static Color black90001 = fromHex('#001111');

  static Color black900 = fromHex('#001718');

  static Color blueGray800 = fromHex('#313f69');

  static Color cyan900 = fromHex('#006767');

  static Color whiteA700 = fromHex('#ffffff');

  static Color black90002 = fromHex('#000000');

  static Color fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }
}
