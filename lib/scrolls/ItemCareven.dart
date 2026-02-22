import 'package:akiba/Cards/ItemCard.dart';
import 'package:akiba/utils/responsive.dart';
import 'package:flutter/material.dart';

class Itemcareven extends StatefulWidget {
  const Itemcareven({super.key});

  @override
  State<Itemcareven> createState() => _ItemcarevenState();
}

class _ItemcarevenState extends State<Itemcareven> {
  final PageController _pageController = PageController(viewportFraction: 0.28);

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: Responsive.w(context) * 0.9,
      height: Responsive.carouselHeight(context),
      child: PageView.builder(
        controller: _pageController,
        padEnds: false,
        scrollDirection: Axis.horizontal,
        itemCount: 10,
        itemBuilder: (context, index) {
          return Transform.scale(
            scale: 1.0,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: Responsive.carouselGap(context),
              ),
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
