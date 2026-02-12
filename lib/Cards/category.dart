import 'package:akiba/Box/categoryBox.dart';
import 'package:flutter/material.dart';

// ignore: camel_case_types
class category extends StatelessWidget {
  const category({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.8,
      color: Colors.transparent,
      height: MediaQuery.of(context).size.width * 0.2,
      child: Padding(
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).size.height * 0.009,
          bottom: MediaQuery.of(context).size.height * 0.003,
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Categorybox(svg: 'Cart.svg', categoryName: '중고거래'),
              Categorybox(svg: 'SuitCase.svg', categoryName: '경매'),
              Categorybox(svg: 'Pencil.svg', categoryName: '구해요'),
              Categorybox(svg: 'Chat.svg', categoryName: '특전/한정판'),
            ],
          ),
        ),
      ),
    );
  }
}
