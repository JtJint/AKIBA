import 'package:akiba/Box/categoryBox.dart';
import 'package:akiba/utils/responsive.dart';
import 'package:flutter/material.dart';

// ignore: camel_case_types
class category extends StatelessWidget {
  const category({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: Responsive.ref(context) * 0.75,
      color: Colors.transparent,
      height: Responsive.ref(context) * 0.24,
      child: Padding(
        padding: EdgeInsets.only(
          top: Responsive.ref(context) * 0.009,
          bottom: Responsive.ref(context) * 0.003,
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Categorybox(svg: 'Cart.svg', categoryName: '중고거래'),
              Categorybox(svg: 'Suitcase.svg', categoryName: '경매'),
              Categorybox(svg: 'Pencil.svg', categoryName: '구해요'),
              Categorybox(svg: 'Chat.svg', categoryName: '특전/한정판'),
            ],
          ),
        ),
      ),
    );
  }
}
