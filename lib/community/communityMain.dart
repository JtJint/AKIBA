import 'package:akiba/widgets/akiba_shell.dart';
import 'package:flutter/material.dart';

class communityMain extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const AkibaShell(
      selectedIndex: 2,
      child: Center(
        child: Text('CommunityMain', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}
