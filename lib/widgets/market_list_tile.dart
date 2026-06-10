import 'package:akiba/widgets/akiba_network_image.dart';
import 'package:flutter/material.dart';

class MarketListTile extends StatelessWidget {
  const MarketListTile({
    super.key,
    required this.title,
    required this.priceText,
    this.imageUrl,
    this.metaText,
    this.badgeText,
    this.trailing,
    this.onTap,
  });

  final String title;
  final String priceText;
  final String? imageUrl;
  final String? metaText;
  final String? badgeText;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      splashColor: Colors.white10,
      highlightColor: Colors.white10,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Color(0xff232323))),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(7),
              child: SizedBox(
                width: 112,
                height: 112,
                child: imageUrl == null || imageUrl!.isEmpty
                    ? const _ImageFallback()
                    : AkibaNetworkImage(
                        url: imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_) => const _ImageFallback(),
                ),
              ),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: SizedBox(
                height: 112,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 19,
                        height: 1.18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      priceText,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xffD0FF00),
                        fontSize: 20,
                        height: 1.1,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      _bottomText,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xff9B9B9B),
                        fontSize: 14,
                        height: 1.1,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),
            SizedBox(
              width: 64,
              height: 112,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Icon(Icons.more_vert, color: Colors.white, size: 28),
                  const Spacer(),
                  if (trailing != null) trailing!,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String get _bottomText {
    final texts = [
      if (badgeText != null && badgeText!.isNotEmpty) badgeText!,
      if (metaText != null && metaText!.isNotEmpty) metaText!,
    ];
    return texts.join(' · ');
  }
}

class _ImageFallback extends StatelessWidget {
  const _ImageFallback();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xff202020),
      alignment: Alignment.center,
      child: const Icon(Icons.image_outlined, color: Colors.white38),
    );
  }
}
