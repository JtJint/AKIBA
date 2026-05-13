import 'dart:html' as html;
import 'package:akiba/app_router.dart';
import 'package:akiba/Carousel/ItemCareven.dart';
import 'package:akiba/Carousel/AutionCareven.dart';
import 'package:akiba/Carousel/careven.dart';
import 'package:akiba/Cards/category.dart';
import 'package:akiba/utils/responsive.dart';
import 'package:akiba/widgets/akiba_shell.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late PageController _pageController;
  double _currentPage = 0.0;
  int selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    html.window.history.replaceState(null, '', '/main');
    _pageController = PageController(viewportFraction: 0.5, initialPage: 1);
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page ?? 1.0;
        selectedIndex = 0;
      });
    });
  }

  int getSelectedIndexFromRoute(BuildContext context) {
    final routeName = ModalRoute.of(context)?.settings.name;

    switch (routeName) {
      case AppRouter.main:
        return 0;
      case AppRouter.write:
        return 1;
      case AppRouter.community:
        return 2;
      case AppRouter.chat:
        return 3;
      case AppRouter.mypage:
        return 4;
      default:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: AkibaShell(
        selectedIndex: getSelectedIndexFromRoute(context),
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: Responsive.ref(context) * 0.02),
              Careven(),
              SizedBox(height: Responsive.ref(context) * 0.02),
              category(),
              SizedBox(height: Responsive.ref(context) * 0.02),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                      left: Responsive.ref(context) * 0.03,
                    ),
                    child: Text(
                      '지금 가장 핫한 매물!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: Responsive.ref(context) * 0.04,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      right: Responsive.ref(context) * 0.03,
                    ),
                    child: Text(
                      '더보기',
                      style: TextStyle(
                        color: Color(0xff838383),
                        fontSize: Responsive.ref(context) * 0.035,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: Responsive.ref(context) * 0.02),
              Itemcareven(),
              SizedBox(height: Responsive.ref(context) * 0.02),
              SizedBox(height: Responsive.ref(context) * 0.02),
              SizedBox(height: Responsive.ref(context) * 0.02),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                      left: Responsive.ref(context) * 0.03,
                    ),
                    child: Text(
                      '곧 입찰이 끝나요!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: Responsive.ref(context) * 0.04,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      right: Responsive.ref(context) * 0.03,
                    ),
                    child: Text(
                      '더보기',
                      style: TextStyle(
                        color: Color(0xff838383),
                        fontSize: Responsive.ref(context) * 0.035,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: Responsive.ref(context) * 0.02),
              Autioncareven(),
              SizedBox(height: Responsive.ref(context) * 0.02),
            ],
          ),
        ),
      ),
    );
  }
}

class myListTile extends StatelessWidget {
  final String label;
  const myListTile({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return ListTile(title: Text(label));
  }
}
