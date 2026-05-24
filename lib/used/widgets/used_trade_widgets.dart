import 'package:akiba/models/recommendItem.dart';
import 'package:akiba/used/model/used_trade_models.dart';
import 'package:akiba/utils/headerFiles.dart';
import 'package:akiba/widgets/akiba_network_image.dart';
import 'package:flutter/material.dart';

class UsedTradeSearchBar extends StatelessWidget {
  const UsedTradeSearchBar({super.key, required this.hintText});

  final String hintText;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      height: 44,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          const Icon(Icons.search, color: Colors.white54),
          const SizedBox(width: 10),
          Text(
            hintText,
            style: const TextStyle(color: Colors.white38, fontSize: 14),
          ),
        ],
      ),
    );
  }
}

class UsedTradeThumbCard extends StatelessWidget {
  const UsedTradeThumbCard({
    super.key,
    required this.item,
    this.width = 124,
    this.onTap,
  });

  final UsedTradeItem item;
  final double width;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: AspectRatio(
                aspectRatio: 1,
                child: AkibaNetworkImage(
                  url: item.imageUrls.first,
                  fit: BoxFit.cover,
                  errorBuilder: (_) => Container(
                    color: Colors.white10,
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.image_not_supported,
                      color: Colors.white38,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              item.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _formatPrice(item.price),
              style: const TextStyle(
                color: Color(0xffD1FF00),
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class UsedTradeHorizontalSection extends StatelessWidget {
  const UsedTradeHorizontalSection({
    super.key,
    required this.title,
    required this.items,
    required this.onTapItem,
  });

  final String title;
  final List<UsedTradeItem> items;
  final ValueChanged<UsedTradeItem> onTapItem;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SectionHeader(title: title, onMore: () {}),
        SizedBox(
          height: 192,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            scrollDirection: Axis.horizontal,
            itemBuilder: (_, index) => UsedTradeThumbCard(
              item: items[index],
              onTap: () => onTapItem(items[index]),
            ),
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemCount: items.length,
          ),
        ),
      ],
    );
  }
}

class UsedTradeSellerCard extends StatelessWidget {
  const UsedTradeSellerCard({super.key, required this.seller});

  final UsedTradeSeller seller;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xffD1FF00)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 34,
            backgroundImage: NetworkImage(seller.profileImageUrl),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      seller.nickname,
                      style: const TextStyle(
                        color: Color(0xffD1FF00),
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.check, size: 16, color: Color(0xffD1FF00)),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  seller.intro,
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _SellerStatChip(label: '거래 ${seller.dealCount}회'),
                    _SellerStatChip(label: '후기 ${seller.reviewCount}개'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class UsedTradeDetailHeader extends StatelessWidget {
  const UsedTradeDetailHeader({super.key, required this.item});

  final UsedTradeItem item;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                item.createdAtText,
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ),
            const Icon(
              Icons.remove_red_eye_outlined,
              color: Colors.white70,
              size: 16,
            ),
            const SizedBox(width: 4),
            Text(
              '${item.viewCount}',
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
            const SizedBox(width: 14),
            const Icon(Icons.favorite_border, color: Colors.white70, size: 16),
            const SizedBox(width: 4),
            Text(
              '${item.favoriteCount}',
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
          ],
        ),
        const SizedBox(height: 18),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _DetailChip(text: item.status),
            _DetailChip(text: item.condition),
          ],
        ),
        const SizedBox(height: 18),
        Text(
          item.title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w800,
            height: 1.25,
          ),
        ),
        const SizedBox(height: 14),
        Text(
          _formatPrice(item.price),
          style: const TextStyle(
            color: Color(0xffD1FF00),
            fontSize: 24,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 14),
        Text(
          item.description,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 15,
            height: 1.55,
          ),
        ),
      ],
    );
  }
}

class UsedTradeBottomCta extends StatelessWidget {
  const UsedTradeBottomCta({super.key, required this.onChatTap});

  final VoidCallback onChatTap;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        color: const Color(0xff070707),
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
        child: Row(
          children: [
            const Icon(Icons.favorite_border, color: Colors.white70),
            const SizedBox(width: 18),
            Expanded(
              child: SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: onChatTap,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xffD1FF00),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    '채팅하기',
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class UsedTradeImageCarousel extends StatefulWidget {
  const UsedTradeImageCarousel({super.key, required this.imageUrls});

  final List<String> imageUrls;

  @override
  State<UsedTradeImageCarousel> createState() => _UsedTradeImageCarouselState();
}

class _UsedTradeImageCarouselState extends State<UsedTradeImageCarousel> {
  final PageController _controller = PageController();
  int _currentIndex = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: AspectRatio(
            aspectRatio: 1,
            child: PageView.builder(
              controller: _controller,
              itemCount: widget.imageUrls.length,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              itemBuilder: (_, index) => AkibaNetworkImage(
                url: widget.imageUrls[index],
                fit: BoxFit.cover,
                errorBuilder: (_) => Container(
                  color: Colors.white10,
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.image_not_supported,
                    color: Colors.white38,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            widget.imageUrls.length,
            (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: _currentIndex == index ? 14 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: _currentIndex == index
                    ? const Color(0xFFB026FF)
                    : Colors.white24,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SellerStatChip extends StatelessWidget {
  const _SellerStatChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _DetailChip extends StatelessWidget {
  const _DetailChip({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: const Color(0xff7D22D4)),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

String formatUsedTradePrice(int price) {
  final formatted = price.toString().replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (match) => ',',
  );
  return '$formatted원';
}

List<RecommendItem> buildRecommendItemsFromUsed(List<UsedTradeItem> items) {
  return items
      .take(5)
      .map(
        (item) => RecommendItem(
          img: item.imageUrls.first,
          title: item.title,
          subtitle: item.createdAtText,
          price: item.description,
        ),
      )
      .toList();
}

String _formatPrice(int price) => formatUsedTradePrice(price);
