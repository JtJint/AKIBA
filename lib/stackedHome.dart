import 'package:akiba/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class Stackedhome extends StatefulWidget {
  const Stackedhome({super.key});

  @override
  State<Stackedhome> createState() => _StackedhomeState();
}

class _StackedhomeState extends State<Stackedhome> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: 0,
        children: [
          HomeScreen(),
          Container(color: Colors.green),
          Container(color: Colors.blue),
          Container(color: Colors.green),
          Container(color: Colors.blue),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        onTap: (index) {
          setState(() {
            // index에 따라 IndexedStack의 index를 변경하여 화면 전환
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),

          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
