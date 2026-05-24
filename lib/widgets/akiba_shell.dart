import 'package:akiba/models/sideBar.dart';
import 'package:akiba/widgets/akiba_logo_button.dart';
import 'package:akiba/search/SearchWidget.dart';
import 'package:flutter/material.dart';

class AkibaShell extends StatelessWidget {
  const AkibaShell({
    super.key,
    required this.selectedIndex,
    required this.child,
    this.showAppBar = true,
    this.backgroundColor = const Color(0xff141414),
    this.contentPadding = EdgeInsets.zero,
  });

  final int selectedIndex;
  final Widget child;
  final bool showAppBar;
  final Color backgroundColor;
  final EdgeInsetsGeometry contentPadding;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth <= 440;
    final contentWidth = screenWidth.clamp(360.0, 800.0);

    return Center(
      child: SizedBox(
        width: contentWidth,
        child: Scaffold(
          backgroundColor: backgroundColor,
          bottomNavigationBar: isMobile
              ? BottomFloatingButton(selectedIndex: selectedIndex)
              : null,
          appBar: showAppBar
              ? AppBar(
                  backgroundColor: backgroundColor,
                  elevation: 0,
                  leadingWidth: 140,
                  leading: const Align(
                    alignment: Alignment.centerLeft,
                    child: AkibaLogoButton(),
                  ),
                  actions: [
                    const SearchWidget(type: 'home'),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.notifications_none,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                )
              : null,
          body: SafeArea(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!isMobile) ...[
                  LeftSidebar(
                    selectedIndex: selectedIndex,
                    onTap: (index) => _move(context, index),
                  ),
                  const SizedBox(width: 24),
                ],
                Expanded(
                  child: Padding(padding: contentPadding, child: child),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _move(BuildContext context, int index) {
    final route = switch (index) {
      0 => '/main',
      1 => '/write',
      2 => '/community',
      3 => '/chat',
      4 => '/mypage',
      _ => '/main',
    };

    Navigator.of(context).pushReplacementNamed(route);
  }
}
