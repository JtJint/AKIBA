import 'package:akiba/limited/model/limited_models.dart';
import 'package:akiba/widgets/akiba_network_image.dart';
import 'package:flutter/material.dart';

String formatLimitedPrice(int price) {
  if (price <= 0) return '가격문의';
  final text = price.toString().replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (match) => ',',
  );
  return '$text원';
}

class LimitedSearchBar extends StatelessWidget {
  const LimitedSearchBar({
    super.key,
    required this.hintText,
    this.controller,
    this.onSubmitted,
    this.onClear,
    this.readOnly = false,
  });

  final String hintText;
  final TextEditingController? controller;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onClear;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(2),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          const Icon(Icons.search, color: Colors.white54, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: controller,
              readOnly: readOnly,
              onSubmitted: onSubmitted,
              style: const TextStyle(color: Colors.white, fontSize: 15),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: hintText,
                hintStyle: const TextStyle(color: Colors.white38),
              ),
            ),
          ),
          if (onClear != null)
            IconButton(
              onPressed: onClear,
              icon: const Icon(Icons.close, color: Colors.white54, size: 20),
            ),
        ],
      ),
    );
  }
}

class LimitedLargeCard extends StatelessWidget {
  const LimitedLargeCard({super.key, required this.item, this.onTap});

  final LimitedItem item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 200,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: AspectRatio(
                aspectRatio: 1,
                child: AkibaNetworkImage(
                  url: item.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_) => _ImageFallback(),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              item.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              formatLimitedPrice(item.price),
              style: const TextStyle(
                color: Color(0xffD1FF00),
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LimitedThumbCard extends StatelessWidget {
  const LimitedThumbCard({super.key, required this.item, this.onTap});

  final LimitedItem item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 106,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: AspectRatio(
                aspectRatio: 1,
                child: AkibaNetworkImage(
                  url: item.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_) => _ImageFallback(),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              item.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white, fontSize: 13),
            ),
            const SizedBox(height: 4),
            Text(
              formatLimitedPrice(item.price).replaceAll(',', ''),
              style: const TextStyle(
                color: Color(0xffD1FF00),
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LimitedResultTile extends StatelessWidget {
  const LimitedResultTile({
    super.key,
    required this.item,
    required this.onMenuTap,
  });

  final LimitedItem item;
  final VoidCallback onMenuTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xff242424))),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: SizedBox(
              width: 96,
              height: 96,
              child: AkibaNetworkImage(
                url: item.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_) => _ImageFallback(),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: SizedBox(
              height: 96,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    formatLimitedPrice(item.price),
                    style: const TextStyle(
                      color: Color(0xffD1FF00),
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      Text(
                        item.category,
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 12,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        item.createdAtText,
                        style: const TextStyle(
                          color: Colors.white38,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            onPressed: onMenuTap,
            icon: const Icon(Icons.more_vert, color: Colors.white, size: 24),
          ),
        ],
      ),
    );
  }
}

class _ImageFallback extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white10,
      alignment: Alignment.center,
      child: const Icon(Icons.image_not_supported, color: Colors.white38),
    );
  }
}
