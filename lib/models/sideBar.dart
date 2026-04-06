import 'package:akiba/wirte/write_page.dart';
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
      width: MediaQuery.of(context).size.width * 0.12,
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

class BottomFloatingButton extends StatelessWidget {
  final int selectedIndex;

  const BottomFloatingButton({super.key, required this.selectedIndex});

  void _move(BuildContext context, int index) {
    switch (index) {
      case 0:
        Navigator.of(context).pushReplacementNamed('/main');
        break;
      case 1:
        Navigator.of(context).pushReplacementNamed('/community');
        break;
      case 2:
        Navigator.of(context).pushReplacementNamed('/chat');
        break;
      case 3:
        Navigator.of(context).pushReplacementNamed('/mypage');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    const activeColor = Color(0xffD7FF00);
    const inactiveColor = Colors.white70;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 18),
      child: Container(
        height: 72,
        decoration: BoxDecoration(
          color: const Color(0xff1b1b1d),
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [
            BoxShadow(
              color: Colors.black45,
              blurRadius: 16,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _item(
              context,
              icon: Icons.home,
              label: '홈',
              active: selectedIndex == 0,
              onTap: () => _move(context, 0),
            ),
            _item(
              context,
              icon: Icons.edit,
              label: '글쓰기',
              onTap: () => _move(context, 1),
              active: selectedIndex == 1,
            ),
            _item(
              context,
              icon: Icons.groups,
              label: '커뮤니티',
              active: selectedIndex == 2,
              onTap: () => _move(context, 2),
            ),

            _item(
              context,
              icon: Icons.chat_bubble_outline,
              label: '채팅',
              active: selectedIndex == 3,
              onTap: () => _move(context, 3),
            ),
            _item(
              context,
              icon: Icons.settings,
              label: '마이페이지',
              active: selectedIndex == 4,
              onTap: () => _move(context, 4),
            ),
          ],
        ),
      ),
    );
  }

  Widget _item(
    BuildContext context, {
    required IconData icon,
    required String label,
    required bool active,
    required VoidCallback onTap,
  }) {
    const activeColor = Color(0xffD7FF00);
    const inactiveColor = Colors.white70;

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: SizedBox(
        width: 60,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 22, color: active ? activeColor : inactiveColor),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: active ? activeColor : inactiveColor,
                fontWeight: active ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
