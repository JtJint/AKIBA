import 'package:akiba/Cards/ItemCard.dart';
import 'package:akiba/utils/responsive.dart';
import 'package:flutter/material.dart';

class PopularCarouselItem {
  const PopularCarouselItem({
    required this.imageUrl,
    required this.title,
    required this.priceText,
    this.onTap,
  });

  final String imageUrl;
  final String title;
  final String priceText;
  final VoidCallback? onTap;
}

class Itemcareven extends StatefulWidget {
  const Itemcareven({super.key, required this.items, this.isLoading = false});

  final List<PopularCarouselItem> items;
  final bool isLoading;

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
    if (widget.isLoading) {
      return SizedBox(
        width: Responsive.w(context) * 0.9,
        height: Responsive.ref(context) * 0.18,
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    if (widget.items.isEmpty) {
      return SizedBox(
        width: Responsive.w(context) * 0.9,
        height: Responsive.ref(context) * 0.18,
        child: const Center(
          child: Text(
            '인기 매물을 불러오지 못했습니다.',
            style: TextStyle(color: Colors.white54),
          ),
        ),
      );
    }

    return SizedBox(
      width: Responsive.w(context) * 0.9,
      height: Responsive.ref(context) * 0.36,
      child: PageView.builder(
        controller: _pageController,
        padEnds: false,
        scrollDirection: Axis.horizontal,
        itemCount: widget.items.length,
        itemBuilder: (context, index) {
          final item = widget.items[index];
          return Transform.scale(
            scale: 1.0,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: Responsive.ref(context) * 0.01,
              ),
              child: Center(
                child: GestureDetector(
                  onTap: item.onTap,
                  child: Itemcard(
                    img: item.imageUrl,
                    name: item.title,
                    price: item.priceText,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
