import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class Categorybox extends StatelessWidget {
  const Categorybox({super.key, required this.svg, required this.categoryName});
  final String svg;
  final String categoryName;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.15,
      color: Colors.transparent,
      height: MediaQuery.of(context).size.width * 0.18,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Color(0xff1E1E1E),
                borderRadius: BorderRadius.circular(10),
              ),
              width: MediaQuery.of(context).size.width * 0.14,
              height: MediaQuery.of(context).size.width * 0.14,
              child: Center(
                child: SvgPicture.asset(
                  'assets/$svg',
                  fit: BoxFit.contain,
                  width: MediaQuery.of(context).size.width * 0.14,
                  height: MediaQuery.of(context).size.width * 0.14,
                ),
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.width * 0.007),
            Text(
              categoryName,
              style: TextStyle(
                color: Colors.white,
                fontSize: MediaQuery.of(context).size.width * 0.015,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
