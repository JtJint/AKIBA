import 'package:flutter/material.dart';

class TopBar extends StatelessWidget {
  const TopBar({
    required this.title,
    this.onBack,
    this.onBell,
    this.showBell = true,
    super.key,
  });

  final String title;
  final VoidCallback? onBack;
  final VoidCallback? onBell;
  final bool showBell;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: SizedBox(
        height: 44,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Center title
            Center(
              child: Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),

            // Left back
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                onPressed: onBack ?? () => Navigator.maybePop(context),
                icon: const Icon(Icons.chevron_left, size: 28),
                splashRadius: 22,
                tooltip: 'back',
              ),
            ),

            // Right bell
            Align(
              alignment: Alignment.centerRight,
              child: showBell
                  ? IconButton(
                      onPressed: onBell,
                      icon: const Icon(
                        Icons.notifications_none_rounded,
                        size: 26,
                      ),
                      splashRadius: 22,
                      tooltip: 'notifications',
                    )
                  : const SizedBox(width: 48), // 자리 맞추기
            ),
          ],
        ),
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  const SectionHeader({
    required this.title,
    this.onMore,
    this.padding = const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
    super.key,
  });

  final String title;
  final VoidCallback? onMore;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
          InkWell(
            onTap: onMore,
            borderRadius: BorderRadius.circular(20),
            child: Row(
              children: [
                Text(
                  "더보기",
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white70,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.chevron_right,
                  size: 18,
                  color: Colors.white70,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
