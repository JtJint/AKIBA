import 'package:akiba/search/search_screen.dart';
import 'package:akiba/utils/responsive.dart';
import 'package:flutter/material.dart';

class SearchWidget extends StatelessWidget {
  const SearchWidget({super.key, required this.type});
  final String type;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SearchScreen_(initialType: type),
          ),
        );
      },
      child: Row(
        children: [
          SizedBox(width: Responsive.ref(context) * 0.02),
          Icon(Icons.search, color: Colors.white),
          SizedBox(width: Responsive.ref(context) * 0.02),
        ],
      ),
    );
  }
}
