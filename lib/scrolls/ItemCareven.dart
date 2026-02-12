import 'package:akiba/Cards/ItemCard.dart';
import 'package:flutter/material.dart';

class Itemcareven extends StatefulWidget {
  const Itemcareven({super.key});

  @override
  State<Itemcareven> createState() => _ItemcarevenState();
}

class _ItemcarevenState extends State<Itemcareven> {
  // 1. PageController 생성 및 viewportFraction 설정
  // 0.8은 화면 너비의 80%만 차지한다는 뜻입니다. (숫자가 작을수록 더 많이 겹쳐 보임)
  final PageController _pageController = PageController(viewportFraction: 0.3);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      height: MediaQuery.of(context).size.height * 0.28,
      child: PageView.builder(
        controller: _pageController, // 2. 컨트롤러 연결
        padEnds: false,
        scrollDirection: Axis.horizontal,
        itemCount: 10,
        itemBuilder: (context, index) {
          return Transform.scale(
            scale: 1.0,
            // 만약 카드 사이 간격을 더 좁히고 싶다면 padding을 조절하세요
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0.0), // 좌우 간격 조절
              child: Center(
                child: Itemcard(
                  img: 'https://picsum.photos/seed/${index + 1}/400/400',
                  name: 'name$index',
                  price: '${(index + 1) * 1000}원',
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
