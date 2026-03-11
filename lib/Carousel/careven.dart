import 'package:akiba/Cards/popCard.dart';
import 'package:akiba/utils/responsive.dart';
import 'package:flutter/material.dart';

class Careven extends StatelessWidget {
  const Careven({
    super.key,
    required PageController pageController,
    required double currentPage,
  }) : _pageController = pageController;
  //  _currentPage = currentPage;

  final PageController _pageController;
  // final double _currentPage;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 1,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color.fromRGBO(0, 0, 0, 0),
            Color.fromRGBO(109, 33, 185, 1),
            Color.fromRGBO(109, 33, 185, 0),
          ],
        ),
      ),
      height: Responsive.ref(context) * 0.3 + 8,
      child: SizedBox(
        width: Responsive.ref(context) * 0.3,
        height: Responsive.ref(context) * 0.3,
        child: Container(
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
          child: PageView.builder(
            scrollDirection: Axis.horizontal,
            controller: _pageController,
            padEnds: true, // 양 끝 여백 제거
            itemCount: 3,
            itemBuilder: (context, index) {
              // 1. 거리 계산 (절댓값)
              // double difference = (index - _currentPage).abs();

              // 2. 크기 계산 (기존 유지)
              double scale = 1;

              // 3. '어두움' 정도 계산 (Opacity가 아님!)
              // difference가 0(가운데)이면 darkness는 0.0 (투명한 막 -> 원ㄴ본 그대로)
              // difference가 1(양옆)이면 darkness는 0.5 (검은색 50% 덧씌움 -> 어두워짐)

              return Transform.scale(
                scale: scale,
                child: Container(
                  width: Responsive.ref(context) * 0.3 + 3,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // [Layer 1] 실제 카드 (항상 선명한 원본)
                      popCard(
                        name: '${index + 1}\n이름',
                        image:
                            'https://picsum.photos/seed/${index + 1}/400/400',
                        tag: ['Tag1', 'Tag2'],
                        description: '${index + 1}아 몰라 텍스트나 내놔',
                      ),

                      // [Layer 2] 카드 위에 덮는 검은 막 (Dimming Layer)
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
