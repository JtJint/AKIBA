import 'package:akiba/utils/responsive.dart';
import 'package:flutter/material.dart';

class Categorybox extends StatelessWidget {
  const Categorybox({super.key, required this.png, required this.categoryName});
  final String png;
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
                child: Image.asset(
                  // SvgPicture 대신 Image.asset 사용
                  'assets/$png', // 확장자를 png로 변경
                  fit: BoxFit.contain,
                  width:
                      Responsive.ref(context) * 0.10, // 여백을 위해 크기를 약간 줄여도 좋습니다
                  height: Responsive.ref(context) * 0.10,
                ),
              ),
            ),
            SizedBox(height: Responsive.ref(context) * 0.007),
            Text(
              categoryName,
              style: TextStyle(
                color: Colors.white,
                fontSize: Responsive.ref(context) * 0.02,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
