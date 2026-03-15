import 'package:akiba/Carousel/ItemCareven.dart';
import 'package:akiba/Carousel/careven.dart';
import 'package:akiba/Carousel/rankingListTile.dart';
import 'package:akiba/Carousel/recommendCaroulsel.dart';
import 'package:akiba/search/SearchWidget.dart';
import 'package:akiba/utils/headerFiles.dart';
import 'package:akiba/models/recommendItem.dart';
import 'package:akiba/utils/responsive.dart';
import 'package:flutter/material.dart';

class GuhaeyoScreen extends StatefulWidget {
  const GuhaeyoScreen({super.key});

  @override
  State<GuhaeyoScreen> createState() => _GuhaeyoScreenState();
}

class _GuhaeyoScreenState extends State<GuhaeyoScreen> {
  // Temporary dummy data for UI previews. Replace with real data fetching logic later.
  List<dynamic> get dummyHotItems => [];
  List<dynamic> get dummyRanking => [];
  List<RecommendItem> get dummyRecommend => [];

  @override
  Widget build(BuildContext context) {
    final hotItems = dummyHotItems;
    final ranking = dummyRanking;

    return Scaffold(
      backgroundColor: const Color(0xff141414),
      appBar: AppBar(
        backgroundColor: Color(0xff141414),
        title: Text('구해요', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back_ios, color: Colors.white),
        ),
        actions: [
          const SearchWidget(type: '구해요'), // 이미 분리해둔 거
        ],
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // 헤더/검색

            // 지금 가장 핫한 매물 + 가로캐러셀
            SliverToBoxAdapter(
              child: SectionHeader(title: "지금 가장 핫한 매물!", onMore: () {}),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: Responsive.ref(context) * 0.36,
                child: Itemcareven(), // 이미 분리해둔 거
              ),
            ),

            SliverToBoxAdapter(child: const SizedBox(height: 28)),

            // ✅ 귀찮은 “중간 리스트”를 SliverList로 끝내기
            SliverToBoxAdapter(
              child: SectionHeader(title: "지금 가장 많이 찾는 굿즈!", onMore: () {}),
            ),
            SliverList.separated(
              itemCount: ranking.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, i) {
                final item = ranking[i];
                // return Careven();
                return RankingListTile(
                  rank: i + 1,
                  title: item.title,
                  subtitle: item.subtitle,
                  thumbnailUrl: item.thumb,
                  onTap: () {},
                );
              },
            ),

            SliverToBoxAdapter(child: const SizedBox(height: 28)),

            // 다음 섹션
            SliverToBoxAdapter(
              child: SectionHeader(title: "이런 굿즈는 어때요?", onMore: () {}),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 280,
                child: RecommendCarousel(items: dummyRecommend),
              ),
            ),

            SliverToBoxAdapter(child: const SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }
}
