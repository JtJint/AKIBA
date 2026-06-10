import 'package:akiba/Cards/popCard.dart';
import 'package:flutter/material.dart';

class Careven extends StatefulWidget {
  const Careven({super.key, this.items = const [], this.isLoading = false});

  final List<CarevenItem> items;
  final bool isLoading;

  @override
  State<Careven> createState() => _CarevenState();
}

class CarevenItem {
  const CarevenItem({
    required this.imageUrl,
    required this.title,
    required this.description,
    required this.tags,
    this.onTap,
  });

  final String imageUrl;
  final String title;
  final String description;
  final List<String> tags;
  final VoidCallback? onTap;
}

class _CarevenState extends State<Careven> {
  late final PageController _pageController;
  double _currentPage = 1.0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.5, initialPage: 1)
      ..addListener(() {
        setState(() {
          _currentPage = _pageController.page ?? _currentPage;
        });
      });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final items = widget.items.take(3).toList();
    final realItemCount = items.length;
    final displayItems = realItemCount >= 2
        ? [items[1], items[0], if (realItemCount >= 3) items[2]]
        : items;
    final contentWidth = screenWidth.clamp(360.0, 800.0);
    final carouselHeight = contentWidth * 0.5;

    return Center(
      child: Container(
        width: contentWidth,
        height: carouselHeight,
        decoration: const BoxDecoration(
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
        child: widget.isLoading
            ? const Center(child: CircularProgressIndicator())
            : realItemCount == 0
            ? const Center(
                child: Text(
                  '인기 상품이 없습니다.',
                  style: TextStyle(color: Colors.white54),
                ),
              )
            : realItemCount == 1
            ? Center(
                child: AspectRatio(
                  aspectRatio: 1,
                  child: popCard(
                    darkness: 0.0,
                    name: displayItems.first.title,
                    image: displayItems.first.imageUrl,
                    tag: displayItems.first.tags.isEmpty
                        ? const ['인기']
                        : displayItems.first.tags,
                    description: displayItems.first.description,
                  ),
                ),
              )
            : PageView.builder(
                controller: _pageController,
                physics: const BouncingScrollPhysics(),
                padEnds: true,
                itemCount: realItemCount,
                itemBuilder: (context, index) {
                  final item = displayItems[index];
                  final currentIndex = _currentPage.round().clamp(
                    0,
                    realItemCount - 1,
                  );
                  final bool isCurrent = index == currentIndex;
                  final double scale = isCurrent ? 1.0 : 0.9;

                  return Center(
                    child: GestureDetector(
                      onTap: item.onTap,
                      child: Transform.scale(
                        scale: scale,
                        child: AspectRatio(
                          aspectRatio: 1,
                          child: popCard(
                            darkness: isCurrent ? 0.0 : 0.6,
                            name: item.title,
                            image: item.imageUrl,
                            tag: item.tags.isEmpty ? const ['인기'] : item.tags,
                            description: item.description,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
