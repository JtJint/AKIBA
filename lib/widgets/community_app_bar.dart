import 'package:akiba/widgets/akiba_logo_button.dart';
import 'package:flutter/material.dart';

/// 커뮤니티 하위 화면용 AppBar (로고 탭 → 홈)
class CommunityAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CommunityAppBar({
    super.key,
    this.showBack = false,
    this.title,
    this.centerTitle = false,
    this.actions = const [],
  });

  final bool showBack;
  final Widget? title;
  final bool centerTitle;
  final List<Widget> actions;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xff141414),
      elevation: 0,
      automaticallyImplyLeading: false,
      leadingWidth: showBack ? 108 : 140,
      leading: showBack
          ? Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.chevron_left, color: Colors.white),
                  padding: EdgeInsets.zero,
                ),
                const AkibaLogoButton(width: 0.14, height: 0.04),
              ],
            )
          : const Align(
              alignment: Alignment.centerLeft,
              child: AkibaLogoButton(),
            ),
      title: title,
      centerTitle: centerTitle,
      titleSpacing: showBack ? 0 : 20,
      actions: actions,
    );
  }
}
