import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
        ],
        leading: Row(
          children: [
            SizedBox(width: MediaQuery.of(context).size.width * 0.02),
            IconButton(
              onPressed: () {},
              icon: Image.asset(
                'assets/AKIBA_LOGO.png',
                width: MediaQuery.of(context).size.width * 0.1,
                height: MediaQuery.of(context).size.height * 0.05,
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),
        leadingWidth: MediaQuery.of(context).size.width * 0.14,
        title: const Text('Akiba Home'),
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
      body: const Center(child: Text('Welcome to the Home Screen!')),
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
