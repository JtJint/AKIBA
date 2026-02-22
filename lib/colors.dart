import 'dart:ui';

import 'package:akiba/color/HEXColor.dart';
import 'package:flutter/material.dart';

// ignore: non_constant_identifier_names
Color BackGroundColor = Color(0xff141414);
// ignore: non_constant_identifier_names
Color PointColor = Color(0xffD0FF00);
// ignore: non_constant_identifier_names
List<Color> SubPointColor = [Color(0xff8522D5), Color(0xffA434FE)];

// ignore: non_constant_identifier_names
Gradient AKIBAGradient = LinearGradient(
  colors: [HexColor("#D0FF00", opacity: 0.2), HexColor("#D0FF00", opacity: 1)],
  begin: Alignment.topRight,
  end: Alignment.bottomLeft,
);
