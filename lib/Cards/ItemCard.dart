import 'package:akiba/colors.dart';
import 'package:akiba/utils/responsive.dart';
import 'package:flutter/material.dart';

/// 핫한 매물 카드
/// 사진 → 이름 → 가격 순으로 표시
class Itemcard extends StatelessWidget {
  final String img;
  final String name;
  final String price;

  const Itemcard({
    super.key,
    required this.img,
    required this.name,
    required this.price,
  });

  @override
  Widget build(BuildContext context) {
    final ref = Responsive.ref(context);
    return Container(
      width: ref * 0.3,
      height: ref * 0.3,
      decoration: BoxDecoration(
        color: Color(0xff1E1E1E),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        // mainAxisSize: MainAxisSize.min,
        children: [
          // 1. 사진
          SizedBox(
            height: ref * 0.2,
            child: ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
              child: Image.network(
                img,
                width: ref * 0.3,
                height: ref * 0.3,
                fit: BoxFit.fitHeight,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(ref * 0.01),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 2. 이름
                Text(
                  name,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: ref * 0.018,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: ref * 0.006),
                // 3. 가격
                Text(
                  price,
                  style: TextStyle(
                    color: PointColor,
                    fontSize: ref * 0.016,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
