import 'package:akiba/search/search_screen.dart';
import 'package:akiba/scrolls/ItemCareven.dart';
import 'package:akiba/scrolls/AutionCareven.dart';
import 'package:akiba/scrolls/careven.dart';
import 'package:akiba/Cards/category.dart';
import 'package:akiba/Logo/logo.dart';
import 'package:akiba/search/search_screen.dart';
import 'package:akiba/utils/responsive.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late PageController _pageController;
  double _currentPage = 0.0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.8);
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page ?? 0.0;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff141414),
      appBar: AppBar(
        actions: [
          Builder(
            builder: (context) => IconButton(
              onPressed: () {
                Scaffold.of(context).openEndDrawer(); // 드로어 열기
              },
              icon: Icon(Icons.notifications),
            ),
          ),
          SizedBox(width: Responsive.ref(context) * 0.02),
        ],
        leading: Row(
          children: [
            SizedBox(width: Responsive.ref(context) * 0.01),
            IconButton(onPressed: () {}, icon: logo(width: .1, height: 0.024)),
          ],
        ),
        leadingWidth: Responsive.ref(context) * 0.3,
        backgroundColor: Color(0xff141414),
      ),
      endDrawer: Drawer(
        backgroundColor: Color(0xff141414),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              child: Text('알람', style: TextStyle(color: Colors.white)),
              decoration: BoxDecoration(color: Color(0xff141414)),
            ),
            myListTile(label: "메뉴 1"),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Center(
              child: GestureDetector(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => SearchScreen_()),
                ),
                child: Container(
                  width: Responsive.w(context) * 0.94,
                  height: Responsive.ref(context) * 0.05,
                  color: Color(0xff070707),
                  child: Row(
                    children: [
                      SizedBox(width: Responsive.ref(context) * 0.02),
                      Icon(Icons.search, color: Color(0xffD1FF00)),
                      SizedBox(width: Responsive.ref(context) * 0.02),
                      Text('검색', style: TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: Responsive.ref(context) * 0.02),
            Careven(pageController: _pageController, currentPage: _currentPage),
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
