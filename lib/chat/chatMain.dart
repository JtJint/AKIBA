import 'dart:convert';

import 'package:akiba/chat/api/chatApi.dart';
import 'package:akiba/chat/chatingPage.dart';
import 'package:akiba/chat/model/chatmodel.dart';
import 'package:akiba/models/sideBar.dart';
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
  dynamic chatRoomsData;
  Future<void> _fetchChatData() async {
    dynamic rt = await Chatapi.getRooms();
    debugPrint("chatRooms: ${rt.body}");
    setState(() {
      chatRooms = rt;
      chatRoomsData = chatRooms.body;
    });
  }

  @override
  Widget build(BuildContext context) {
    const bgColor = Color(0xff0b0b0d);
    const lime = Color(0xffd7ff00);
    const purple = Color(0xff8a2be2);
    const dividerColor = Color(0xff3a3a3f);

    final categories = ['전체', '중고거래', '구해요', '경매', '추천'];

    final fallbackChats = [
      ChatItemModel(
        roodId: 1,
        imageUrl: 'https://picsum.photos/seed/naruto/200/200',
        title: '반프레스토 나루토 점프 우..',
        preview: '네네 감사합니다.',
        category: '중고거래',
        userName: '아이디',
        dateText: '1일전',
      ),
    ];
    final chats = _buildChatItems().isNotEmpty
        ? _buildChatItems()
        : fallbackChats;
    final filteredChats = _selectedCategory == '전체'
        ? chats
        : chats.where((item) => item.category == _selectedCategory).toList();

    int getSelectedIndexFromRoute(BuildContext context) {
      final routeName = ModalRoute.of(context)?.settings.name;

      switch (routeName) {
        case '/main':
          return 0;
        case '/write':
          return 1;
        case '/community':
          return 2;
        case '/chat':
          return 3;
        case '/mypage':
          return 4;
        default:
          return 0;
      }
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final contentWidth = screenWidth.clamp(360.0, 800.0);
    return Scaffold(
      backgroundColor: bgColor,
      body: Center(
        child: Container(
          width: contentWidth,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MediaQuery.of(context).size.width > 442
                  ? LeftSidebar(
                      selectedIndex: getSelectedIndexFromRoute(context),
                      onTap: (index) {
                        switch (index) {
                          case 0:
                            Navigator.of(context).pushNamed('/main');
                            break;
                          case 1:
                            Navigator.of(context).pushNamed('/write');
                            break;
                          case 2:
                            Navigator.of(context).pushNamed('/community');
                            break;
                          case 3:
                            Navigator.of(context).pushNamed('/chat');
                            break;
                          case 4:
                            Navigator.of(context).pushNamed('/mypage');
                            break;
                        }
                      },
                    )
                  : SizedBox(width: 0),
              Container(
                width: screenWidth > 442 ? contentWidth - 80 : contentWidth,
                height: MediaQuery.of(context).size.height,
                decoration: BoxDecoration(color: const Color(0xff141414)),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 22,
                      vertical: 18,
                    ),
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
                            separatorBuilder: (_, __) =>
                                const SizedBox(width: 10),
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

                        if (filteredChats.isEmpty)
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
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => ChatingPage(
                                        roomId: item.roodId,
                                        userName: item.userName,
                                        itemTitle: item.title,
                                        itemImageUrl: item.imageUrl,
                                      ),
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
            ],
          ),
        ),
      ),
    );
  }

  List<ChatItemModel> _buildChatItems() {
    if (chatRoomsData == null) {
      return [];
    }

    try {
      final decoded = chatRoomsData is String
          ? jsonDecode(chatRoomsData)
          : chatRoomsData;
      final rooms = decoded is List
          ? decoded
          : decoded is Map<String, dynamic> && decoded['data'] is List
          ? decoded['data'] as List
          : decoded is Map<String, dynamic> && decoded['content'] is List
          ? decoded['content'] as List
          : <dynamic>[];

      return rooms.map((room) {
        final map = room is Map<String, dynamic>
            ? room
            : Map<String, dynamic>.from(room as Map);
        final roomType = (map['roomType'] ?? map['category'] ?? '전체')
            .toString();

        return ChatItemModel(
          roodId: (map['roomId'] ?? map['id'] ?? 0) as int,
          imageUrl:
              (map['thumbnailUrl'] ??
                      map['imageUrl'] ??
                      'https://picsum.photos/seed/chat/200/200')
                  .toString(),
          title: (map['title'] ?? map['marketPostTitle'] ?? '채팅방').toString(),
          preview: (map['lastMessage'] ?? map['lastMessageContent'] ?? '')
              .toString(),
          category: _mapRoomTypeToCategory(roomType),
          userName:
              (map['targetNickname'] ??
                      map['nickname'] ??
                      map['userName'] ??
                      '상대방')
                  .toString(),
          dateText: (map['lastMessageAtText'] ?? map['updatedAtText'] ?? '')
              .toString(),
        );
      }).toList();
    } catch (_) {
      return [];
    }
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
            child: Image.network(
              item.imageUrl,
              width: 98,
              height: 98,
              fit: BoxFit.cover,
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
                    item.preview,
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
