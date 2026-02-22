import 'package:akiba/Cards/AuctionCard.careven.dart';
import 'package:akiba/utils/responsive.dart';
import 'package:flutter/material.dart';

/// 곧 입찰이 끝나는 순서대로 정렬된 경매 매물 캐러셀
class Autioncareven extends StatefulWidget {
  const Autioncareven({super.key});

  @override
  State<Autioncareven> createState() => _AutioncarevenState();
}

class _AutioncarevenState extends State<Autioncareven> {
  final PageController _pageController = PageController(viewportFraction: 0.28);

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  /// 입찰 종료 임박 순 정렬된 목록 (실제로는 API에서 endTime 기준 정렬)
  static final List<Map<String, dynamic>> _auctionItems = [
    {
      'img': 'https://picsum.photos/seed/101/400/400',
      'name': '아이폰 15 Pro',
      'endTime': '30분 남음',
      'price': '1,250,000원',
      'rateOfChange': 5.2,
    },
    {
      'img': 'https://picsum.photos/seed/102/400/400',
      'name': '맥북 에어 M3',
      'endTime': '1시간 15분',
      'price': '980,000원',
      'rateOfChange': -2.1,
    },
    {
      'img': 'https://picsum.photos/seed/103/400/400',
      'name': '에어팟 프로 2',
      'endTime': '2시간 30분',
      'price': '185,000원',
      'rateOfChange': 12.3,
    },
    {
      'img': 'https://picsum.photos/seed/104/400/400',
      'name': '닌텐도 스위치',
      'endTime': '3시간 00분',
      'price': '320,000원',
      'rateOfChange': 0.0,
    },
    {
      'img': 'https://picsum.photos/seed/105/400/400',
      'name': '소니 WH-1000XM5',
      'endTime': '4시간 45분',
      'price': '410,000원',
      'rateOfChange': -1.5,
    },
    {
      'img': 'https://picsum.photos/seed/106/400/400',
      'name': '갤럭시 버즈2',
      'endTime': '5시간 20분',
      'price': '95,000원',
      'rateOfChange': 8.7,
    },
    {
      'img': 'https://picsum.photos/seed/107/400/400',
      'name': '아이패드 미니',
      'endTime': '6시간 10분',
      'price': '520,000원',
      'rateOfChange': -0.8,
    },
    {
      'img': 'https://picsum.photos/seed/108/400/400',
      'name': '애플워치 울트라',
      'endTime': '7시간 00분',
      'price': '890,000원',
      'rateOfChange': 3.2,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: Responsive.w(context) * 0.9,
      height: Responsive.carouselHeight(context),
      child: PageView.builder(
        controller: _pageController,
        padEnds: false,
        scrollDirection: Axis.horizontal,
        itemCount: _auctionItems.length,
        itemBuilder: (context, index) {
          final item = _auctionItems[index];
          return Padding(
            padding: EdgeInsets.symmetric(
              horizontal: Responsive.carouselGap(context),
            ),
            child: Center(
              child: Auctioncardcareven(
                img: item['img'] as String,
                name: item['name'] as String,
                endTime: item['endTime'] as String,
                price: item['price'] as String,
                rateOfChange: (item['rateOfChange'] as num).toDouble(),
              ),
            ),
          );
        },
      ),
    );
  }
}
