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
      width: MediaQuery.of(context).size.width * width,
      height: MediaQuery.of(context).size.height * height,
      fit: BoxFit.contain,
    );
  }
}
