import 'package:flutter/material.dart';

class Itemcard extends StatelessWidget {
  const Itemcard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.09,
      height: MediaQuery.of(context).size.height * .15,
      decoration: BoxDecoration(
        color: Color(0xff1E1E1E),
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}
