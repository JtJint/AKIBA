import 'package:akiba/scrolls/ItemCareven.dart';
import 'package:akiba/scrolls/careven.dart';
import 'package:akiba/Cards/category.dart';
import 'package:akiba/Logo/logo.dart';
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
          SizedBox(width: MediaQuery.of(context).size.width * 0.02),
        ],
        leading: Row(
          children: [
            SizedBox(width: MediaQuery.of(context).size.width * 0.01),
            IconButton(onPressed: () {}, icon: logo(width: .1, height: 0.024)),
          ],
        ),
        leadingWidth: MediaQuery.of(context).size.width * 0.3,
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
              //검색창 로직에 대해서 의논 필요
              child: Container(
                width: MediaQuery.of(context).size.width * 0.94,
                height: MediaQuery.of(context).size.height * 0.05,
                color: Color(0xff070707),
                child: Row(
                  children: [
                    SizedBox(width: MediaQuery.of(context).size.width * 0.02),
                    Icon(Icons.search, color: Color(0xffD1FF00)),
                    SizedBox(width: MediaQuery.of(context).size.width * 0.02),
                    Text('검색', style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.02),
            Careven(pageController: _pageController, currentPage: _currentPage),
            SizedBox(height: MediaQuery.of(context).size.height * 0.02),
            category(),
            SizedBox(height: MediaQuery.of(context).size.height * 0.02),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: EdgeInsets.only(
                    left: MediaQuery.of(context).size.width * 0.03,
                  ),
                  child: Text(
                    '지금 가장 핫한 매물!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: MediaQuery.of(context).size.width * 0.04,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                    right: MediaQuery.of(context).size.width * 0.03,
                  ),
                  child: Text(
                    '더보기',
                    style: TextStyle(
                      color: Color(0xff838383),
                      fontSize: MediaQuery.of(context).size.width * 0.035,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.02),
            Itemcareven(),
            SizedBox(height: MediaQuery.of(context).size.height * 0.02),
            SizedBox(height: MediaQuery.of(context).size.height * 0.02),
            SizedBox(height: MediaQuery.of(context).size.height * 0.02),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: EdgeInsets.only(
                    left: MediaQuery.of(context).size.width * 0.03,
                  ),
                  child: Text(
                    '곧 입찰이 끝나요!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: MediaQuery.of(context).size.width * 0.04,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                    right: MediaQuery.of(context).size.width * 0.03,
                  ),
                  child: Text(
                    '더보기',
                    style: TextStyle(
                      color: Color(0xff838383),
                      fontSize: MediaQuery.of(context).size.width * 0.035,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.02),
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
