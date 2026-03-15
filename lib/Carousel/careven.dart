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
      height: Responsive.ref(context) * 0.4 + 8,
      child: SizedBox(
        width: Responsive.ref(context) * 0.4,
        height: Responsive.ref(context) * 0.4,
        child: Container(
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
          child: PageView.builder(
            scrollDirection: Axis.horizontal,
            controller: _pageController,
            padEnds: true,
            itemCount: 3,
            itemBuilder: (context, index) {
              double page = _pageController.hasClients
                  ? _pageController.page ??
                        _pageController.initialPage.toDouble()
                  : 0;

              double difference = (index - page).abs();

              double scale = difference < 0.5 ? 1.0 : 0.8;
              return Transform.scale(
                scale: scale,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      popCard(
                        name: '${index + 1}\n이름',
                        image:
                            'https://picsum.photos/seed/${index + 1}/400/400',
                        tag: ['Tag1', 'Tag2'],
                        description: '${index + 1}아 몰라 텍스트나 내놔',
                      ),
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
