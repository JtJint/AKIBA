import 'package:akiba/app_router.dart';
import 'package:akiba/utils/responsive.dart';
import 'package:flutter/material.dart';

class SearchWidget extends StatelessWidget {
  const SearchWidget({super.key, required this.type});
  final String type;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushNamed(
          AppRouter.search,
          arguments: SearchRouteArgs(initialType: type),
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
