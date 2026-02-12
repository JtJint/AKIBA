import 'package:flutter/material.dart';

class Itemcard extends StatelessWidget {
  final dynamic img;

  final dynamic name;

  final dynamic price;

  const Itemcard({
    super.key,
    required this.img,
    required this.name,
    required this.price,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.2,
      height: MediaQuery.of(context).size.height * .3,
      decoration: BoxDecoration(
        color: Color(0xff1E1E1E),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Image.network(
            img,
            width: MediaQuery.of(context).size.width * 0.19,
            height: MediaQuery.of(context).size.height * 0.2,
            fit: BoxFit.cover,
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.015),
          Text(
            name,
            style: TextStyle(
              color: Colors.white,
              fontSize: MediaQuery.of(context).size.height * 0.015,
            ),
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.01),
          Text(
            price,
            style: TextStyle(
              color: Color(0xffD0FF00),
              fontSize: MediaQuery.of(context).size.height * 0.015,
            ),
          ),
        ],
      ),
    );
  }
}
