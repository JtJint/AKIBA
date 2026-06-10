import 'package:akiba/Login/URL.dart';
import 'package:akiba/Logo/nickName.dart';
import 'package:akiba/Logo/onBoarding.dart';
import 'package:akiba/auction/api/auction_api.dart';
import 'package:akiba/auction/auction_detail_screen.dart';
import 'package:akiba/auction/auction_list_screen.dart';
import 'package:akiba/auction/auction_screen.dart';
import 'package:akiba/chat/chatingPage.dart';
import 'package:akiba/chat/chatMain.dart';
import 'package:akiba/community/api/board_api.dart';
import 'package:akiba/community/community_board_posts_screen.dart';
import 'package:akiba/community/communityMain.dart';
import 'package:akiba/community/community_popular_posts_screen.dart';
import 'package:akiba/community/community_post_detail_screen.dart';
import 'package:akiba/demand/api/wanted_api.dart';
import 'package:akiba/demand/guhaeyo.dart';
import 'package:akiba/demand/guhaeyo.detail.dart';
import 'package:akiba/home.dart';
import 'package:akiba/limited/limited_detail_screen.dart';
import 'package:akiba/limited/limited_screen.dart';
import 'package:akiba/market/market_list_screen.dart';
import 'package:akiba/myPage/myPage.dart';
import 'package:akiba/search/search_result_page.dart';
import 'package:akiba/search/search_screen.dart';
import 'package:akiba/used/model/used_trade_models.dart';
import 'package:akiba/used/used_trade_detail_screen.dart';
import 'package:akiba/used/used_trade_screen.dart';
import 'package:akiba/wirte/community_wirte_page.dart';
import 'package:akiba/wirte/write_page.dart';
import 'package:flutter/material.dart';

class AppRouter {
  static const String onboarding = '/';
  static const String oauthCallback = '/oauth/callback';
  static const String nickname = '/nickname';
  static const String main = '/main';
  static const String write = '/write';
  static const String community = '/community';
  static const String communityPopular = '/community/popular';
  static const String communityWrite = '/community/write';
  static const String used = '/used';
  static const String usedDetail = '/used/detail';
  static const String limited = '/limited';
  static String limitedDetailPath(int postId) => '/limited/$postId';
  static const String auction = '/auction';
  static const String auctionEndingSoon = '/auction/ending-soon';
  static const String auctionPopular = '/auction/popular';
  static const String wanted = '/wanted';
  static const String chat = '/chat';
  static const String mypage = '/mypage';
  static const String profile = '/profile';
  static const String search = '/search';
  static const String searchResult = '/search/result';
  static const String marketList = '/market/list';

  static String wantedDetailPath(int postId) => '/wanted/$postId';
  static String auctionDetailPath(int postId) => '/auction/$postId';
  static String chatRoomPath(int roomId) => '/chat/$roomId';
  static String profilePath(int targetUserId) => '/profile/$targetUserId';
  static String communityPostDetailPath(String boardCode, int postId) =>
      '/community/$boardCode/posts/$postId';
  static String communityBoardPath(String boardCode) => '/community/$boardCode';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    final uri = Uri.parse(settings.name ?? onboarding);

    if (uri.path == oauthCallback) {
      return _buildRoute(
        settings: settings,
        builder: (_) => const NaverCallbackPage(),
      );
    }

    if (uri.path == nickname) {
      return _buildRoute(
        settings: settings,
        builder: (_) => const inputNickNamePage(),
      );
    }

    if (uri.path == main) {
      return _buildRoute(settings: settings, builder: (_) => HomeScreen());
    }

    if (uri.path == write) {
      final args = settings.arguments;
      final routeArgs = args is WritePageRouteArgs ? args : null;
      return _buildRoute(
        settings: settings,
        builder: (_) => WritePage(
          initialMode: routeArgs?.initialMode,
          wantedEditPost: routeArgs?.wantedEditPost,
          usedEditPost: routeArgs?.usedEditPost,
        ),
      );
    }

    if (uri.path == community) {
      return _buildRoute(settings: settings, builder: (_) => communityMain());
    }

    if (uri.path == communityPopular) {
      return _buildRoute(
        settings: settings,
        builder: (_) => const CommunityPopularPostsScreen(),
      );
    }

    if (uri.path == communityWrite) {
      final args = settings.arguments;
      final routeArgs = args is CommunityWriteRouteArgs ? args : null;
      return _buildRoute(
        settings: settings,
        builder: (_) =>
            CommunityWritePage(boardCode: routeArgs?.boardCode ?? 'FREE'),
      );
    }

    if (uri.pathSegments.length == 2 && uri.pathSegments.first == 'community') {
      final boardCode = uri.pathSegments[1];
      return _buildRoute(
        settings: settings,
        builder: (_) => CommunityBoardPostsScreen(boardCode: boardCode),
      );
    }

    if (uri.pathSegments.length == 4 &&
        uri.pathSegments.first == 'community' &&
        uri.pathSegments[2] == 'posts') {
      final boardCode = uri.pathSegments[1];
      final postId = int.tryParse(uri.pathSegments[3]);
      final args = settings.arguments;
      final routeArgs = args is CommunityPostDetailRouteArgs ? args : null;
      if (postId != null) {
        return _buildRoute(
          settings: settings,
          builder: (_) => CommunityPostDetailScreen(
            boardCode: boardCode,
            postId: postId,
            initialPost: routeArgs?.initialPost,
          ),
        );
      }
    }

    if (uri.path == used) {
      return _buildRoute(
        settings: settings,
        builder: (_) => const UsedTradeScreen(),
      );
    }

    if (uri.path == usedDetail) {
      final args = settings.arguments;
      final routeArgs = args is UsedTradeDetailRouteArgs ? args : null;
      if (routeArgs != null) {
        return _buildRoute(
          settings: settings,
          builder: (_) => UsedTradeDetailScreen(
            postId: routeArgs.postId,
            initialItem: routeArgs.item,
          ),
        );
      }
    }

    if (uri.path == limited) {
      return _buildRoute(
        settings: settings,
        builder: (_) => const LimitedScreen(),
      );
    }

    if (uri.pathSegments.length == 2 && uri.pathSegments.first == 'limited') {
      final postId = int.tryParse(uri.pathSegments[1]);
      if (postId != null) {
        return _buildRoute(
          settings: settings,
          builder: (_) => LimitedDetailScreen(postId: postId),
        );
      }
    }

    if (uri.path == auction) {
      return _buildRoute(
        settings: settings,
        builder: (_) => const AuctionScreen(),
      );
    }

    if (uri.path == auctionEndingSoon) {
      return _buildRoute(
        settings: settings,
        builder: (_) => const AuctionListScreen(type: AuctionListType.endingSoon),
      );
    }

    if (uri.path == auctionPopular) {
      return _buildRoute(
        settings: settings,
        builder: (_) => const AuctionListScreen(type: AuctionListType.popular),
      );
    }

    if (uri.pathSegments.length == 2 && uri.pathSegments.first == 'auction') {
      final postId = int.tryParse(uri.pathSegments[1]);
      final args = settings.arguments;
      final routeArgs = args is AuctionDetailRouteArgs ? args : null;
      if (postId != null) {
        return _buildRoute(
          settings: settings,
          builder: (_) => AuctionDetailScreen(
            postId: postId,
            initialItem: routeArgs?.initialItem,
          ),
        );
      }
    }

    if (uri.path == wanted) {
      return _buildRoute(
        settings: settings,
        builder: (_) => const GuhaeyoScreen(),
      );
    }

    if (uri.pathSegments.length == 2 && uri.pathSegments.first == 'wanted') {
      final postId = int.tryParse(uri.pathSegments[1]);
      if (postId != null) {
        return _buildRoute(
          settings: settings,
          builder: (_) => GDetailScreen(postId: postId),
        );
      }
    }

    if (uri.path == chat) {
      return _buildRoute(settings: settings, builder: (_) => const ChatPage());
    }

    if (uri.pathSegments.length == 2 && uri.pathSegments.first == 'chat') {
      final roomId = int.tryParse(uri.pathSegments[1]);
      final args = settings.arguments;
      final routeArgs = args is ChatRoomRouteArgs ? args : null;
      if (roomId != null) {
        return _buildRoute(
          settings: settings,
          builder: (_) => ChatingPage(
            roomId: roomId,
            userName: routeArgs?.userName ?? '아이디',
            itemTitle: routeArgs?.itemTitle ?? '상품 정보',
            itemImageUrl: routeArgs?.itemImageUrl,
            priceText: routeArgs?.priceText,
          ),
        );
      }
    }

    if (uri.path == mypage) {
      return _buildRoute(
        settings: settings,
        builder: (_) => const MyPageScreen(),
      );
    }

    if (uri.pathSegments.length == 2 && uri.pathSegments.first == 'profile') {
      final targetUserId = int.tryParse(uri.pathSegments[1]);
      if (targetUserId != null) {
        return _buildRoute(
          settings: settings,
          builder: (_) => MyPageScreen(targetUserId: targetUserId),
        );
      }
    }

    if (uri.path == search) {
      final args = settings.arguments;
      final routeArgs = args is SearchRouteArgs ? args : null;
      return _buildRoute(
        settings: settings,
        builder: (_) => SearchScreen_(initialType: routeArgs?.initialType),
      );
    }

    if (uri.path == searchResult) {
      final args = settings.arguments;
      final routeArgs = args is SearchResultRouteArgs ? args : null;
      if (routeArgs != null) {
        return _buildRoute(
          settings: settings,
          builder: (_) => SearchResultPage(
            query: routeArgs.query,
            type: routeArgs.type,
            onlyActive: routeArgs.onlyActive,
            unOpenedOnly: routeArgs.unOpenedOnly,
            sort: routeArgs.sort,
          ),
        );
      }
    }

    if (uri.path == marketList) {
      final args = settings.arguments;
      final routeArgs = args is MarketListRouteArgs ? args : null;
      if (routeArgs != null) {
        return _buildRoute(
          settings: settings,
          builder: (_) => MarketListScreen(type: routeArgs.type),
        );
      }
    }

    return _buildRoute(
      settings: settings,
      builder: (_) => const OnboardingPage(),
    );
  }

  static MaterialPageRoute<dynamic> _buildRoute({
    required RouteSettings settings,
    required WidgetBuilder builder,
  }) {
    return MaterialPageRoute(builder: builder, settings: settings);
  }
}

class SearchRouteArgs {
  const SearchRouteArgs({this.initialType});

  final String? initialType;
}

class WritePageRouteArgs {
  const WritePageRouteArgs({
    this.initialMode,
    this.wantedEditPost,
    this.usedEditPost,
  });

  final WriteMode? initialMode;
  final WantedPostDetail? wantedEditPost;
  final UsedTradeItem? usedEditPost;
}

class SearchResultRouteArgs {
  const SearchResultRouteArgs({
    required this.query,
    this.type,
    this.onlyActive,
    this.unOpenedOnly,
    this.sort,
  });

  final String query;
  final String? type;
  final bool? onlyActive;
  final bool? unOpenedOnly;
  final String? sort;
}

class MarketListRouteArgs {
  const MarketListRouteArgs({required this.type});

  final MarketListType type;
}

class CommunityPostDetailRouteArgs {
  const CommunityPostDetailRouteArgs({this.initialPost});

  final BoardPostSummary? initialPost;
}

class CommunityWriteRouteArgs {
  const CommunityWriteRouteArgs({required this.boardCode});

  final String boardCode;
}

class AuctionDetailRouteArgs {
  const AuctionDetailRouteArgs({this.initialItem});

  final AuctionSummary? initialItem;
}

class UsedTradeDetailRouteArgs {
  const UsedTradeDetailRouteArgs({this.postId, this.item});

  final int? postId;
  final UsedTradeItem? item;
}

class ChatRoomRouteArgs {
  const ChatRoomRouteArgs({
    this.userName,
    this.itemTitle,
    this.itemImageUrl,
    this.priceText,
  });

  final String? userName;
  final String? itemTitle;
  final String? itemImageUrl;
  final String? priceText;
}
