import 'package:akiba/Cards/recommendBannerCard.dart';
import 'package:akiba/models/recommendItem.dart';
import 'package:flutter/material.dart';

class RecommendCarousel extends StatefulWidget {
  const RecommendCarousel({super.key, required this.items, this.onTapItem});

  final List<RecommendItem> items;
  final void Function(RecommendItem item)? onTapItem;

  @override
  State<RecommendCarousel> createState() => _RecommendCarouselState();
}

class _RecommendCarouselState extends State<RecommendCarousel> {
  late final PageController _controller;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _controller = PageController(viewportFraction: 1.0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        SizedBox(
          height: 140,
          child: PageView.builder(
            controller: _controller,
            itemCount: widget.items.length,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemBuilder: (context, index) {
              final item = widget.items[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: RecommendBannerCard(
                  item: item,
                  onTap: widget.onTapItem == null
                      ? null
                      : () => widget.onTapItem!(item),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            widget.items.length,
            (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: _currentIndex == index ? 14 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: _currentIndex == index
                    ? const Color(0xFFB026FF)
                    : Colors.white24,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
