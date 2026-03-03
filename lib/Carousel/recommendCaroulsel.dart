import 'package:akiba/Cards/recommendCard.dart';
import 'package:akiba/models/recommendItem.dart';
import 'package:flutter/material.dart';

class RecommendCarousel extends StatelessWidget {
  const RecommendCarousel({
    super.key,
    required this.items,
    this.onTapItem,
    this.padding = const EdgeInsets.symmetric(horizontal: 20),
  });

  final List<RecommendItem> items;
  final void Function(RecommendItem item)? onTapItem;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: padding,
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(width: 12),
      itemBuilder: (context, i) {
        final item = items[i];
        return RecommendCard(
          item: item,
          onTap: onTapItem == null ? null : () => onTapItem!(item),
        );
      },
    );
  }
}
