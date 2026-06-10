import 'dart:convert';

import 'package:akiba/app_router.dart';
import 'package:akiba/chat/api/chatApi.dart';
import 'package:akiba/chat/model/chatmodel.dart';
import 'package:akiba/config/api_config.dart';
import 'package:akiba/widgets/akiba_network_image.dart';
import 'package:akiba/widgets/akiba_shell.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  String _selectedCategory = '전체';

  @override
  initState() {
    super.initState();
    _fetchChatData();
  }

  Response chatRooms = Response('', 200);
  List<ChatItemModel> _chatItems = const [];
  bool _isLoading = true;
  String? _errorText;

  Future<void> _fetchChatData() async {
    try {
      final rt = await Chatapi.getRooms();
      debugPrint("chatRooms: ${rt.body}");
      final rooms = _extractRoomList(jsonDecode(rt.body));
      final items = await Future.wait(rooms.map(_buildChatItemFromRoom));
      if (!mounted) return;
      setState(() {
        chatRooms = rt;
        _chatItems = items;
        _isLoading = false;
        _errorText = null;
      });
    } catch (error) {
      debugPrint('chat rooms fetch error: $error');
      if (!mounted) return;
      setState(() {
        _chatItems = const [];
        _isLoading = false;
        _errorText = '채팅방 목록을 불러오지 못했습니다.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const bgColor = Color(0xff0b0b0d);
    const lime = Color(0xffd7ff00);
    const purple = Color(0xff8a2be2);
    const dividerColor = Color(0xff3a3a3f);

    final categories = ['전체', '중고거래', '구해요', '경매', '추천'];

    final chats = _chatItems;
    final filteredChats = _selectedCategory == '전체'
        ? chats
        : chats.where((item) => item.category == _selectedCategory).toList();

    int getSelectedIndexFromRoute(BuildContext context) {
      final routeName = ModalRoute.of(context)?.settings.name;

      switch (routeName) {
        case AppRouter.main:
          return 0;
        case AppRouter.write:
          return 1;
        case AppRouter.community:
          return 2;
        case AppRouter.chat:
          return 3;
        case AppRouter.mypage:
          return 4;
        default:
          return 0;
      }
    }

    return AkibaShell(
      selectedIndex: getSelectedIndexFromRoute(context),
      backgroundColor: bgColor,
      child: Container(
        height: MediaQuery.of(context).size.height,
        decoration: const BoxDecoration(color: Color(0xff141414)),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              // crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '채팅',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.notifications_none,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                SizedBox(
                  height: 42,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: categories.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 10),
                    itemBuilder: (context, index) {
                      final category = categories[index];
                      final isSelected = _selectedCategory == category;

                      return ChatCategory(
                        isSelected: isSelected,
                        lime: lime,
                        purple: purple,
                        category: category,
                        onTap: () {
                          setState(() {
                            _selectedCategory = category;
                          });
                        },
                      ); //여기까지 박스 하나짜리임 이거 api로 가져와서 해보자이
                    },
                  ),
                ),

                const SizedBox(height: 22),

                if (_isLoading)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 48),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (_errorText != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 48),
                    child: Text(
                      _errorText!,
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  )
                else if (filteredChats.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 48),
                    child: Text(
                      '선택한 카테고리의 채팅이 없습니다.',
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  )
                else
                  ListView.separated(
                    itemCount: filteredChats.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    separatorBuilder: (_, __) => const Divider(
                      color: dividerColor,
                      height: 28,
                      thickness: 1,
                    ),
                    itemBuilder: (context, index) {
                      final item = filteredChats[index];

                      return GestureDetector(
                        onTap: () {
                          Navigator.of(context).pushNamed(
                            AppRouter.chatRoomPath(item.roodId),
                            arguments: ChatRoomRouteArgs(
                              userName: item.userName,
                              itemTitle: item.title,
                              itemImageUrl: item.imageUrl,
                              priceText: item.priceText,
                            ),
                          );
                        },
                        child: _ChatListItem(
                          item: item,
                          lime: lime,
                          purple: purple,
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<dynamic> _extractRoomList(dynamic decoded) {
    if (decoded is List) return decoded;
    if (decoded is Map<String, dynamic>) {
      for (final key in ['data', 'content', 'result', 'rooms', 'items']) {
        final value = decoded[key];
        if (value is List) return value;
        if (value is Map<String, dynamic>) {
          final nested = value['content'] ?? value['items'] ?? value['rooms'];
          if (nested is List) return nested;
        }
      }
    }
    return [];
  }

  Future<ChatItemModel> _buildChatItemFromRoom(dynamic room) async {
    final map = room is Map<String, dynamic>
        ? room
        : room is Map
        ? Map<String, dynamic>.from(room)
        : <String, dynamic>{};
    final roomType = (map['roomType'] ?? map['category'] ?? '전체').toString();
    final roomId = _parseInt(map['roomId'] ?? map['id']);
    final marketPostId = _parseInt(map['marketPostId'] ?? map['postId']);
    final post = marketPostId > 0 ? await _fetchMarketPost(marketPostId) : null;

    return ChatItemModel(
      roodId: roomId,
      marketPostId: marketPostId,
      imageUrl: _postImageUrl(post, map),
      title:
          (post?['title'] ?? map['title'] ?? map['marketPostTitle'] ?? '상품 정보')
              .toString(),
      preview:
          (map['lastMessage'] ??
                  map['lastMessageContent'] ??
                  post?['content'] ??
                  '')
              .toString(),
      priceText: _formatPrice(
        _parseInt(post?['price'] ?? post?['currentPrice'] ?? post?['startPrice']),
      ),
      category: _mapRoomTypeToCategory(roomType),
      userName:
          (map['targetNickname'] ??
                  map['nickname'] ??
                  map['userName'] ??
                  post?['sellerNickname'] ??
                  (post?['seller'] is Map ? post!['seller']['nickname'] : null) ??
                  '상대방')
              .toString(),
      dateText:
          (map['lastMessageAtText'] ??
                  map['updatedAtText'] ??
                  _formatDateText(map['createdAt']))
              .toString(),
    );
  }

  Future<Map<String, dynamic>?> _fetchMarketPost(int marketPostId) async {
    try {
      final response = await Chatapi.getMarketPost(marketPostId);
      if (response.statusCode < 200 || response.statusCode >= 300) return null;
      final decoded = jsonDecode(response.body);
      final body = decoded is Map<String, dynamic>
          ? decoded['data'] is Map
                ? decoded['data']
                : decoded['result'] is Map
                ? decoded['result']
                : decoded
          : decoded;
      return body is Map ? Map<String, dynamic>.from(body) : null;
    } catch (error) {
      debugPrint('chat market post fetch error: $error');
      return null;
    }
  }

  String _postImageUrl(Map<String, dynamic>? post, Map<String, dynamic> room) {
    final roomImage = room['thumbnailUrl'] ?? room['imageUrl'];
    if (roomImage is String && roomImage.isNotEmpty) {
      return ApiConfig.resourceUrl(roomImage);
    }

    final postImage = post?['thumbnailUrl'] ?? post?['imageUrl'];
    if (postImage is String && postImage.isNotEmpty) {
      return ApiConfig.resourceUrl(postImage);
    }

    final images = post?['images'] ?? post?['imageUrls'];
    if (images is List && images.isNotEmpty) {
      final first = images.first;
      if (first is String) return ApiConfig.resourceUrl(first);
      if (first is Map) {
        return ApiConfig.resourceUrl(
          (first['imageUrl'] ?? first['url'])?.toString(),
        );
      }
    }

    return '';
  }

  int _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  String _formatPrice(int price) {
    if (price <= 0) return '가격 정보 없음';
    final text = price.toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (match) => ',',
    );
    return '$text원';
  }

  String _formatDateText(dynamic value) {
    final raw = value?.toString() ?? '';
    final date = DateTime.tryParse(raw);
    if (date == null) return '';
    final diff = DateTime.now().difference(date.toLocal());
    if (diff.inDays > 0) return '${diff.inDays}일전';
    if (diff.inHours > 0) return '${diff.inHours}시간전';
    if (diff.inMinutes > 0) return '${diff.inMinutes}분전';
    return '방금 전';
  }

  String _mapRoomTypeToCategory(String roomType) {
    switch (roomType.toUpperCase()) {
      case 'MARKET':
      case 'USED':
      case '중고거래':
        return '중고거래';
      case 'REQUEST':
      case 'DEMAND':
      case '구해요':
        return '구해요';
      case 'AUCTION':
      case '경매':
        return '경매';
      case 'RECOMMEND':
      case '추천':
        return '추천';
      default:
        return roomType;
    }
  }
}

class ChatCategory extends StatelessWidget {
  const ChatCategory({
    super.key,
    required this.lime,
    required this.purple,
    required this.isSelected,
    required this.category,
    required this.onTap,
  });

  final bool isSelected;
  final Color lime;
  final Color purple;
  final String category;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18),
        decoration: BoxDecoration(
          color: Color(0xff141414),
          borderRadius: BorderRadius.circular(999),
          border: isSelected ? Border.all(color: lime, width: 1) : null,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: purple,
                    blurRadius: 0,
                    spreadRadius: 1,
                    offset: Offset(0, 2),
                  ),
                ]
              : null,
        ),
        alignment: Alignment.center,
        child: Text(
          category,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _ChatListItem extends StatelessWidget {
  final ChatItemModel item;
  final Color lime;
  final Color purple;

  const _ChatListItem({
    required this.item,
    required this.lime,
    required this.purple,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: SizedBox(
              width: 98,
              height: 98,
              child: item.imageUrl.isEmpty
                  ? Container(
                      color: const Color(0xff202020),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.image_outlined,
                        color: Colors.white38,
                      ),
                    )
                  : AkibaNetworkImage(
                      url: item.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_) => Container(
                        color: const Color(0xff202020),
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.image_outlined,
                          color: Colors.white38,
                        ),
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 14),

          Expanded(
            child: SizedBox(
              height: 98,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: lime,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.more_vert,
                        color: Colors.white,
                        size: 22,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item.preview.isEmpty ? item.priceText : item.preview,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      Text(
                        item.category,
                        style: TextStyle(
                          color: purple,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        item.userName,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        item.dateText,
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
