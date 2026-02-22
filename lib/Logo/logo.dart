import 'package:akiba/utils/responsive.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class logo extends StatelessWidget {
  const logo({super.key, required this.width, required this.height});
  final width;
  final height;
  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      color: Color(0xffD1FF00),
      'assets/logo.svg',
      width: Responsive.ref(context) * width,
      height: Responsive.ref(context) * height,
      fit: BoxFit.contain,
    );
  }
}
