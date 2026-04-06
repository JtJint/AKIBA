import 'dart:html' as html;
import 'package:akiba/models/sideBar.dart';
import 'package:akiba/search/SearchWidget.dart';
import 'package:akiba/search/search_screen.dart';
import 'package:akiba/Carousel/ItemCareven.dart';
import 'package:akiba/Carousel/AutionCareven.dart';
import 'package:akiba/Carousel/careven.dart';
import 'package:akiba/Cards/category.dart';
import 'package:akiba/Logo/logo.dart';
import 'package:akiba/utils/responsive.dart';
import 'package:akiba/wirte/write_page.dart';
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
      case '/main':
        return 0;
      case '/write':
        return 1;
      case '/community':
        return 2;
      case '/chat':
        return 3;
      case '/mypage':
        return 4;
      default:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Center(
        child: Container(
          decoration: const BoxDecoration(color: Color(0xff000000)),
          width: MediaQuery.of(context).size.width * 0.9,
          child: Scaffold(
            bottomNavigationBar: MediaQuery.of(context).size.width <= 442
                ? BottomFloatingButton(
                    selectedIndex: getSelectedIndexFromRoute(context),
                  )
                : null,
            backgroundColor: Color(0xff141414),
            appBar: AppBar(
              backgroundColor: const Color(0xff141414),
              elevation: 0,
              leadingWidth: 140,
              leading: Padding(
                padding: const EdgeInsets.only(left: 12),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: logo(width: .18, height: 0.05),
                ),
              ),
              actions: [
                SearchWidget(type: 'home'),
                Builder(
                  builder: (context) => IconButton(
                    onPressed: () {
                      Scaffold.of(context).openEndDrawer();
                    },
                    icon: const Icon(
                      Icons.notifications_none,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],
            ),
            body: Center(
              child: Row(
                // crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  MediaQuery.of(context).size.width > 442
                      ? LeftSidebar(
                          selectedIndex: getSelectedIndexFromRoute(context),
                          onTap: (index) {
                            switch (index) {
                              case 0:
                                Navigator.of(
                                  context,
                                ).pushReplacementNamed('/main');
                                break;
                              case 1:
                                Navigator.of(
                                  context,
                                ).pushReplacementNamed('/write');
                                break;
                              case 2:
                                Navigator.of(
                                  context,
                                ).pushReplacementNamed('/community');
                                break;
                              case 3:
                                Navigator.of(
                                  context,
                                ).pushReplacementNamed('/chat');
                                break;
                              case 4:
                                Navigator.of(
                                  context,
                                ).pushReplacementNamed('/mypage');
                                break;
                            }
                          },
                        )
                      : SizedBox(width: 12),
                  SizedBox(width: 24),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.7,
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          SizedBox(height: Responsive.ref(context) * 0.02),
                          Careven(pageController: _pageController),
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
                ],
              ),
            ),
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
