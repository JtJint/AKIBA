import 'package:akiba/colors.dart';
import 'package:akiba/utils/responsive.dart';
import 'package:akiba/widgets/akiba_network_image.dart';
import 'package:flutter/material.dart';

/// 입찰 종료 임박 매물 카드
/// 사진 → 남은 시간 → 이름 → 가격·변동률 순으로 표시
class Auctioncardcareven extends StatelessWidget {
  final String img;
  final String name;
  final String endTime; // 남은 시간 (예: "2시간 30분", "D-2")
  final String price;
  final int bidCount;
  final VoidCallback? onTap;

  const Auctioncardcareven({
    super.key,
    required this.img,
    required this.name,
    required this.endTime,
    required this.price,
    required this.bidCount,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final ref = Responsive.ref(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              width: ref * 0.32,
              height: ref * 0.32,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: AkibaNetworkImage(
                      url: img,
                      fit: BoxFit.cover,
                      errorBuilder: (_) => Container(
                        color: const Color(0xff202020),
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.image_not_supported,
                          color: Colors.white38,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 8,
                    top: 8,
                    child: Container(
                      constraints: BoxConstraints(maxWidth: ref * 0.26),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: endTime == '마감'
                            ? const Color(0xff242424)
                            : const Color(0xffD0FF00),
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: Text(
                        endTime,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: endTime == '마감'
                              ? Colors.white70
                              : Colors.black,
                          fontSize: ref * 0.018,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: ref * 0.012),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: ref * 0.022,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: ref * 0.006),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      price,
                      style: TextStyle(
                        color: PointColor,
                        fontSize: ref * 0.018,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '입찰 $bidCount회',
                      style: TextStyle(
                        color: Colors.white60,
                        fontSize: ref * 0.02,
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
