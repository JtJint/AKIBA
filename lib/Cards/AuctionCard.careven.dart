import 'package:akiba/colors.dart';
import 'package:akiba/utils/responsive.dart';
import 'package:flutter/material.dart';

/// 입찰 종료 임박 매물 카드
/// 사진 → 남은 시간 → 이름 → 가격·변동률 순으로 표시
class Auctioncardcareven extends StatelessWidget {
  final String img;
  final String name;
  final String endTime; // 남은 시간 (예: "2시간 30분", "D-2")
  final String price;
  final double rateOfChange; // 가격 변동률 (예: 5.2, -3.1)

  const Auctioncardcareven({
    super.key,
    required this.img,
    required this.name,
    required this.endTime,
    required this.price,
    required this.rateOfChange,
  });

  @override
  Widget build(BuildContext context) {
    final ref = Responsive.ref(context);
    final isPositive = rateOfChange >= 0;

    return Container(
      width: ref * 0.32,
      // height: ref * 0.3 + 1,
      decoration: BoxDecoration(
        color: Color(0xff1E1E1E),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // 1. 사진
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
            child: Image.network(
              img,
              width: ref * 0.3,
              height: ref * 0.2,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: EdgeInsets.all(ref * 0.01),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 2. 남은 시간
                Text(
                  endTime,
                  style: TextStyle(
                    color: Color(0xffD0FF00),
                    fontSize: ref * 0.012,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: ref * 0.006),
                // 3. 이름
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
                // 4. 가격 & 변동률
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      price,
                      style: TextStyle(
                        color: PointColor,
                        fontSize: ref * 0.016,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '${isPositive ? '+' : ''}${rateOfChange.toStringAsFixed(1)}%',
                      style: TextStyle(
                        color: isPositive
                            ? Color(0xff00C853)
                            : Color(0xffFF5252),
                        fontSize: ref * 0.012,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
