import 'package:flutter/material.dart';

class LeftSidebar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;

  const LeftSidebar({
    super.key,
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 110,
      height: MediaQuery.of(context).size.height,
      padding: const EdgeInsets.symmetric(vertical: 28),
      decoration: BoxDecoration(
        color: const Color(0xff1b1b1d),
        borderRadius: BorderRadius.circular(0),
      ),
      child: Column(
        children: [
          _sidebarItem(
            icon: Icons.home,
            label: '홈',
            index: 0,
            selected: selectedIndex == 0,
          ),
          const SizedBox(height: 26),
          _sidebarItem(
            icon: Icons.edit,
            label: '글쓰기',
            index: 1,
            selected: selectedIndex == 1,
          ),
          const SizedBox(height: 26),
          _sidebarItem(
            icon: Icons.groups,
            label: '커뮤니티',
            index: 2,
            selected: selectedIndex == 2,
          ),
          const SizedBox(height: 26),
          _sidebarItem(
            icon: Icons.chat_bubble_outline,
            label: '채팅',
            index: 3,
            selected: selectedIndex == 3,
          ),
          const SizedBox(height: 26),
          _sidebarItem(
            icon: Icons.settings,
            label: '마이페이지',
            index: 4,
            selected: selectedIndex == 4,
          ),
        ],
      ),
    );
  }

  Widget _sidebarItem({
    required IconData icon,
    required String label,
    required int index,
    required bool selected,
  }) {
    final Color activeColor = const Color(0xffD7FF00);
    final Color inactiveColor = Colors.white;

    return InkWell(
      onTap: () => onTap(index),
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: 80,
        child: Column(
          children: [
            Icon(icon, color: selected ? activeColor : inactiveColor, size: 24),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: selected ? activeColor : inactiveColor,
                fontSize: 13,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
