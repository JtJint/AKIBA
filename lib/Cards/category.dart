import 'package:akiba/Box/categoryBox.dart';
import 'package:akiba/demand/guhaeyo.dart';
import 'package:akiba/utils/responsive.dart';
import 'package:flutter/material.dart';

// ignore: camel_case_types
class category extends StatelessWidget {
  const category({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      // width: 400,
      color: Colors.transparent,
      // height: 200,
      child: Padding(
        padding: EdgeInsets.only(
          top: Responsive.ref(context) * 0.009,
          bottom: Responsive.ref(context) * 0.003,
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MediaQuery.of(context).size.width < 440
                ? MainAxisAlignment.spaceEvenly
                : MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Categorybox(png: 'Cart.png', categoryName: '중고거래'),
              SizedBox(width: MediaQuery.of(context).size.width < 450 ? 0 : 4),
              Categorybox(png: 'Suitcase.png', categoryName: '경매'),
              SizedBox(width: MediaQuery.of(context).size.width < 450 ? 0 : 4),

              GestureDetector(
                child: Categorybox(png: 'Pencil.png', categoryName: '구해요'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => GuhaeyoScreen()),
                  );
                },
              ),
              SizedBox(width: MediaQuery.of(context).size.width < 450 ? 0 : 4),

              Categorybox(png: 'Chat.png', categoryName: '특전/한정판'),
            ],
          ),
        ),
      ),
    );
  }
}
