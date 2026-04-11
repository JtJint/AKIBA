import 'package:akiba/chat/api/chatApi.dart';
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
  @override
  initState() {
    super.initState();
    _fetchChatData();
  }

  Response chatRooms = Response('', 200);
  dynamic chatRoomsData;
  Future<void> _fetchChatData() async {
    dynamic rt = await Chatapi.getRooms();
    print("chatRooms: ${rt.body}");
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

    final chats = [
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

    return Scaffold(
      backgroundColor: bgColor,
      body: Center(
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
              width: MediaQuery.of(context).size.width * 0.7,
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
                            final isSelected = index == 0;

                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 18,
                              ),
                              decoration: BoxDecoration(
                                color: Color(0xff141414),
                                borderRadius: BorderRadius.circular(999),
                                border: isSelected
                                    ? Border.all(color: lime, width: 1)
                                    : null,
                                boxShadow: isSelected
                                    ? const [
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
                                categories[index],
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ); //여기까지 박스 하나짜리임 이거 api로 가져와서 해보자이
                          },
                        ),
                      ),

                      const SizedBox(height: 22),

                      ListView.separated(
                        itemCount: chats.length,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        separatorBuilder: (_, __) => const Divider(
                          color: dividerColor,
                          height: 28,
                          thickness: 1,
                        ),
                        itemBuilder: (context, index) {
                          final item = chats[index];

                          return _ChatListItem(
                            item: item,
                            lime: lime,
                            purple: purple,
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
    return Row(
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
                    const Icon(Icons.more_vert, color: Colors.white, size: 22),
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
    );
  }
}
