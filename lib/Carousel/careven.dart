import 'package:akiba/Cards/popCard.dart';
import 'package:flutter/material.dart';

class Careven extends StatefulWidget {
  const Careven({super.key});

  @override
  State<Careven> createState() => _CarevenState();
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
    const int realItemCount = 3;
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
        child: PageView.builder(
          controller: _pageController,
          physics: const BouncingScrollPhysics(),
          padEnds: true,
          itemCount: realItemCount,
          itemBuilder: (context, index) {
            final currentIndex = _currentPage.round();
            final bool isCurrent = index == currentIndex;
            final double scale = isCurrent ? 1.0 : 0.9;

            return Center(
              child: Transform.scale(
                scale: scale,
                child: AspectRatio(
                  aspectRatio: 1,
                  child: popCard(
                    darkness: isCurrent ? 0.0 : 0.6,
                    name: '${index + 1}\n이름',
                    image: 'https://picsum.photos/seed/${index + 1}/400/400',
                    tag: const ['Tag1', 'Tag2'],
                    description: '${index + 1}아 몰라 텍스트나 내놔',
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
