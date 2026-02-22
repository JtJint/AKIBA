import 'package:akiba/utils/responsive.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class Categorybox extends StatelessWidget {
  const Categorybox({super.key, required this.svg, required this.categoryName});
  final String svg;
  final String categoryName;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: Responsive.ref(context) * 0.17,
      color: Colors.transparent,
      height: Responsive.ref(context) * 0.22,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Color(0xff1E1E1E),
                borderRadius: BorderRadius.circular(10),
              ),
              width: Responsive.ref(context) * 0.18,
              height: Responsive.ref(context) * 0.18,
              child: Center(
                child: SvgPicture.asset(
                  'assets/$svg',
                  fit: BoxFit.contain,
                  width: Responsive.ref(context) * 0.18,
                  height: Responsive.ref(context) * 0.18,
                ),
              ),
            ),
            SizedBox(height: Responsive.ref(context) * 0.007),
            Text(
              categoryName,
              style: TextStyle(
                color: Colors.white,
                fontSize: Responsive.ref(context) * 0.015,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
