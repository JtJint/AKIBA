import 'package:akiba/utils/responsive.dart';
import 'package:flutter/material.dart';

class Categorybox extends StatelessWidget {
  const Categorybox({
    super.key,
    required this.png,
    required this.categoryName,
    this.width,
  });
  final String png;
  final String categoryName;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final boxWidth = width ?? Responsive.ref(context) * 0.15;
    final iconContainerSize = boxWidth * 0.9;
    final iconSize = boxWidth * 0.4;
    final labelFontSize = (boxWidth * 0.3).clamp(10.0, 14.0);
    final labelSpacing = (boxWidth * 0.035).clamp(4.0, 8.0);

    return Container(
      width: boxWidth,
      color: Colors.transparent,
      height: boxWidth + 20,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Color(0xff1E1E1E),
                borderRadius: BorderRadius.circular(10),
              ),
              width: iconContainerSize,
              height: iconContainerSize,
              child: Center(
                child: Image.asset(
                  // SvgPicture 대신 Image.asset 사용
                  'assets/$png', // 확장자를 png로 변경
                  fit: BoxFit.contain,
                  width: iconSize,
                  height: iconSize,
                ),
              ),
            ),
            SizedBox(height: labelSpacing),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 1),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  categoryName,
                  maxLines: 1,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: labelFontSize,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
