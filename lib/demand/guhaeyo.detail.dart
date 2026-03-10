import 'package:flutter/material.dart';

class gDetailScreen extends StatelessWidget {
  const gDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff070707),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, c) {
            final w = c.maxWidth;

            // 웹에서 폭이 너무 넓으면 중앙 정렬 + maxWidth 제한 (앱 같은 느낌)
            // 하지만 "아이패드 이상에서 2컬럼"을 쓰려면 maxWidth를 너무 작게 잡으면 안 됨.
            final maxContentWidth = w >= 900 ? 1100.0 : 520.0;

            return Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxContentWidth),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: w >= 900
                      ? const _TwoColumnHeader()
                      : const _OneColumnHeader(),
                ),
              ),
            );
          },
        ),
      ),

      // 하단 CTA를 고정하고 싶으면 bottomNavigationBar로 빼는 게 베스트
      bottomNavigationBar: _BottomCTA(),
    );
  }
}

/// -------------------- 1컬럼 (폰/작은 화면) --------------------
class _OneColumnHeader extends StatelessWidget {
  const _OneColumnHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        // ✅ 사진: 커지되, 어느 크기부터는 더 커지지 않게 제한
        _HeroImageOneColumn(
          imageUrl: "https://picsum.photos/seed/naruto/900/900",
        ),
        const SizedBox(height: 14),

        const _InfoBlock(),
        const SizedBox(height: 18),

        // 판매자 정보(나중에 카드로 분리 예정)
        const _SellerBlock(),
        const SizedBox(height: 22),

        const _SimilarProductsBlock(),
        const SizedBox(height: 80), // CTA 공간
      ],
    );
  }
}

class _HeroImageOneColumn extends StatelessWidget {
  const _HeroImageOneColumn({required this.imageUrl});
  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.of(context).size.width;

    // 화면이 커져도 사진이 무한히 커지지 않게 clamp
    final maxImgWidth = 520.0; // "이 이상은 안 커져도 됨" 기준
    final imgWidth = screenW.clamp(0.0, maxImgWidth);

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: imgWidth),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: AspectRatio(
            aspectRatio: 1, // 정사각(원본이 세로 긴 경우면 4/5로 바꿔도 됨)
            child: Image.network(imageUrl, fit: BoxFit.cover),
          ),
        ),
      ),
    );
  }
}

/// -------------------- 2컬럼 (아이패드 이상) --------------------
class _TwoColumnHeader extends StatelessWidget {
  const _TwoColumnHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 왼쪽: 이미지
          Expanded(
            flex: 6,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: AspectRatio(
                aspectRatio: 1, // 필요하면 4/5 등으로 조절
                child: Image.network(
                  "https://picsum.photos/seed/naruto/900/900",
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          const SizedBox(width: 18),

          // 오른쪽: 설명/태그/가격/내용
          Expanded(
            flex: 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _InfoBlock(),
                const SizedBox(height: 18),
                const _SellerBlock(),
                const SizedBox(height: 22),
                const _SimilarProductsBlock(),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// -------------------- 내용 블록(제목/가격/설명) --------------------
class _InfoBlock extends StatelessWidget {
  const _InfoBlock();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 상태/태그 칩 자리 (판매중/미개봉 등)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: const [
              _PillChip(text: "판매중"),
              _PillChip(text: "미개봉"),
            ],
          ),
          const SizedBox(height: 14),

          Text(
            "우즈마키 나루토 룩업 피규어 새제품 팔아요!!!",
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 10),

          Text(
            "5000원",
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: const Color(0xffD1FF00),
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),

          Text(
            "*거래 후 환불 불가* 책상 위에 올려두면 귀여워요!! 미개봉이고 택배거래 선호합니다. 편하게 쪽지 주세요!",
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white70,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

/// -------------------- 판매자 블록(나중에 카드로 분리) --------------------
class _SellerBlock extends StatelessWidget {
  const _SellerBlock();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white10,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xffD1FF00).withOpacity(0.5)),
        ),
        child: Row(
          children: [
            const CircleAvatar(radius: 28, backgroundColor: Colors.white24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "나루토짱 ✓",
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: const Color(0xffD1FF00),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "언제든 쪽지 환영입니다!",
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: Colors.white70),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 10,
                    children: [
                      _MiniStat(text: "거래 4회"),
                      _MiniStat(text: "후기 3개"),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.white54),
          ],
        ),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: const Color(0xffD1FF00),
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

/// -------------------- 유사상품 자리 --------------------
class _SimilarProductsBlock extends StatelessWidget {
  const _SimilarProductsBlock();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  "보고 있는 상품과 비슷한 상품",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              TextButton(onPressed: () {}, child: const Text("더보기")),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 150,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: 10,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (_, i) => Container(
                width: 120,
                decoration: BoxDecoration(
                  color: Colors.white10,
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// -------------------- UI 부품 --------------------
class _PillChip extends StatelessWidget {
  const _PillChip({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xff8522D5)),
        color: Colors.black26,
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

/// -------------------- 하단 CTA --------------------
class _BottomCTA extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
        color: const Color(0xff070707),
        child: Row(
          children: [
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.favorite_border, color: Colors.white70),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: SizedBox(
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xffD1FF00),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () {},
                  child: const Text(
                    "채팅하기",
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
