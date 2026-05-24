import 'package:akiba/Box/categoryBox.dart';
import 'package:akiba/app_router.dart';
import 'package:akiba/utils/responsive.dart';
import 'package:flutter/material.dart';

// ignore: camel_case_types
class category extends StatelessWidget {
  const category({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        final spacing = availableWidth < 440 ? 10.0 : 14.0;
        final itemWidth = (availableWidth - (spacing * 3)) / 4;

        return Container(
          height: itemWidth + 20,
          color: Colors.transparent,
          child: Padding(
            padding: EdgeInsets.only(
              top: Responsive.ref(context) * 0.009,
              bottom: Responsive.ref(context) * 0.003,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).pushNamed(AppRouter.used);
                  },
                  child: Categorybox(
                    png: 'Cart.png',
                    categoryName: '중고거래',
                    width: itemWidth,
                  ),
                ),
                SizedBox(width: spacing),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).pushNamed(AppRouter.auction);
                  },
                  child: Categorybox(
                    png: 'Suitcase.png',
                    categoryName: '경매',
                    width: itemWidth,
                  ),
                ),
                SizedBox(width: spacing),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).pushNamed(AppRouter.wanted);
                  },
                  child: Categorybox(
                    png: 'Pencil.png',
                    categoryName: '구해요',
                    width: itemWidth,
                  ),
                ),
                SizedBox(width: spacing),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).pushNamed(AppRouter.limited);
                  },
                  child: Categorybox(
                    png: 'Chat.png',
                    categoryName: '특전/한정판',
                    width: itemWidth,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
