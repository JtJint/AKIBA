import 'dart:convert';
import 'dart:html' as html;

import 'package:akiba/chat/api/chatApi.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ChatingPage extends StatefulWidget {
  final int roomId;
  final String userName;
  final String itemTitle;
  final String? itemImageUrl;
  final String? priceText;

  const ChatingPage({
    super.key,
    required this.roomId,
    this.userName = '아이디',
    this.itemTitle = '상품 정보',
    this.itemImageUrl,
    this.priceText,
  });

  @override
  State<ChatingPage> createState() => _ChatingPageState();
}

class _ChatingPageState extends State<ChatingPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<_ChatMessage> _messages = [];

  bool _isLoading = true;
  bool _isSending = false;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _loadMessages();
    _initializeRealtimeChat();
  }

  @override
  void dispose() {
    ChatService.instance.unsubscribeRoom(widget.roomId);
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadMessages() async {
    setState(() {
      _isLoading = true;
      _errorText = null;
    });

    try {
      final http.Response response = await Chatapi.getMessages(widget.roomId);
      // print(response.body);
      final dynamic decoded = jsonDecode(response.body);
      final List<dynamic> rawMessages = _extractMessageList(decoded);

      setState(() {
        _messages
          ..clear()
          ..addAll(
            rawMessages
                .map(_ChatMessage.fromJson)
                .where((message) => message.content.trim().isNotEmpty),
          );
        _isLoading = false;
      });

      _scrollToBottom();
    } catch (_) {
      setState(() {
        _isLoading = false;
        _errorText = '채팅 내용을 불러오지 못했습니다.';
      });
    }
  }

  Future<void> _initializeRealtimeChat() async {
    ChatService.instance.connectIfLoggedIn();

    for (var attempt = 0; attempt < 10; attempt++) {
      if (ChatService.instance.isConnected) {
        ChatService.instance.subscribeRoom(
          widget.roomId,
          _handleRealtimeMessage,
        );
        print(
          '[chat] subscribeRoom success roomId=${widget.roomId}, attempt=$attempt',
        );
        return;
      }

      await Future.delayed(const Duration(milliseconds: 300));
    }

    print(
      '[chat] subscribeRoom skipped roomId=${widget.roomId}, socket not connected',
    );
  }

  List<dynamic> _extractMessageList(dynamic decoded) {
    if (decoded is List) {
      return decoded;
    }

    if (decoded is Map<String, dynamic>) {
      final candidates = [
        decoded['messages'],
        decoded['data'],
        decoded['content'],
        decoded['result'],
      ];

      for (final candidate in candidates) {
        if (candidate is List) {
          return candidate;
        }
      }
    }

    return [];
  }

  void _handleRealtimeMessage(dynamic payload) {
    final message = _ChatMessage.fromJson(payload);
    if (message.content.trim().isEmpty) {
      return;
    }

    if (!mounted) {
      return;
    }

    setState(() {
      final alreadyExists = _messages.any(
        (item) =>
            item.content == message.content &&
            item.timeLabel == message.timeLabel &&
            item.isMine == message.isMine,
      );

      if (!alreadyExists) {
        _messages.add(message);
      }
    });

    _scrollToBottom();
  }

  Future<void> _sendMessage() async {
    final content = _messageController.text.trim();

    if (content.isEmpty || _isSending) {
      print(
        '[chat] _sendMessage blocked roomId=${widget.roomId}, empty=${content.isEmpty}, isSending=$_isSending',
      );
      return;
    }

    final optimisticMessage = _ChatMessage(
      content: content,
      timeLabel: _formatNowTime(),
      dateLabel: _formatNowDateLabel(),
      dateKey: _formatNowDateKey(),
      isMine: true,
      senderName: '나',
    );

    setState(() {
      _isSending = true;
      _messages.add(optimisticMessage);
    });
    _messageController.clear();
    _scrollToBottom();

    try {
      print('[chat] calling ChatService.sendMessage roomId=${widget.roomId}');
      ChatService.instance.sendMessage(widget.roomId, content);
      print('[chat] ChatService.sendMessage returned roomId=${widget.roomId}');
    } catch (_) {
      print('[chat] sendMessage threw error roomId=${widget.roomId}');
      setState(() {
        _messages.remove(optimisticMessage);
        _errorText = '메시지 전송에 실패했습니다.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
        });
      }
    }
  }

  String _formatNowTime() {
    final now = DateTime.now();
    final hour = now.hour % 12 == 0 ? 12 : now.hour % 12;
    final minute = now.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  String _formatNowDateLabel() {
    final now = DateTime.now();
    return '${now.year}년 ${now.month}월 ${now.day}일';
  }

  String _formatNowDateKey() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) {
        return;
      }

      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final contentWidth = screenWidth.clamp(360.0, 800.0);
    const background = Color(0xff141414);
    const surface = Color(0xff0b0b0d);
    const bubble = Color(0xff000000);
    const lime = Color(0xffd7ff00);
    const soft = Color(0xff8d8d93);

    return Center(
      child: SizedBox(
        width: contentWidth,
        child: Scaffold(
          backgroundColor: Color(0xff141414),
          appBar: AppBar(
            backgroundColor: background,
            elevation: 0,
            leading: IconButton(
              onPressed: () => Navigator.of(context).maybePop(),
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
            ),
            centerTitle: true,
            title: GestureDetector(
              onTap: () {
                print(_messages.map((e) => e.content).toList());
              },
              child: Text(
                widget.userName,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 22,
                ),
              ),
            ),
            actions: [
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.more_vert, color: Colors.white),
              ),
            ],
          ),
          body: Column(
            children: [
              _ItemSummaryCard(
                title: widget.itemTitle,
                imageUrl: widget.itemImageUrl,
                priceText: widget.priceText,
              ),
              Expanded(
                child: Container(
                  color: surface,
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _errorText != null && _messages.isEmpty
                      ? Center(
                          child: Text(
                            _errorText!,
                            style: const TextStyle(color: Colors.white70),
                          ),
                        )
                      : ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.fromLTRB(16, 28, 16, 24),
                          itemCount: _messages.length,
                          itemBuilder: (context, index) {
                            final message = _messages[index];
                            final previous = index > 0
                                ? _messages[index - 1]
                                : null;
                            final showDate =
                                message.dateLabel.isNotEmpty &&
                                (previous == null ||
                                    previous.dateKey != message.dateKey);

                            return Column(
                              children: [
                                if (showDate)
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 20),
                                    child: Text(
                                      message.dateLabel,
                                      style: const TextStyle(
                                        color: Color(0xffbdbdbd),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                _MessageBubble(message: message, lime: lime),
                                const SizedBox(height: 16),
                              ],
                            );
                          },
                        ),
                ),
              ),
              if (_errorText != null && _messages.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    _errorText!,
                    style: const TextStyle(color: soft, fontSize: 12),
                  ),
                ),
              SafeArea(
                top: false,
                child: Container(
                  color: background,
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.add, color: Colors.white70),
                      ),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: bubble,
                            borderRadius: BorderRadius.circular(2),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          child: TextField(
                            controller: _messageController,
                            style: const TextStyle(color: Colors.white),
                            cursorColor: lime,
                            onSubmitted: (value) {
                              _sendMessage();
                            },
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              hintText: '메시지를 입력하세요',
                              hintStyle: TextStyle(color: Colors.white38),
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          print(
                            '[chat] send button tapped roomId=${widget.roomId}',
                          );
                          _sendMessage();
                        },
                        icon: Icon(
                          Icons.send_outlined,
                          color: _isSending ? Colors.white24 : Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ItemSummaryCard extends StatelessWidget {
  final String title;
  final String? imageUrl;
  final String? priceText;

  const _ItemSummaryCard({
    required this.title,
    required this.imageUrl,
    required this.priceText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: imageUrl != null && imageUrl!.isNotEmpty
                ? Image.network(
                    imageUrl!,
                    width: 52,
                    height: 52,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _fallbackThumb(),
                  )
                : _fallbackThumb(),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  priceText ?? '가격 정보 없음',
                  style: const TextStyle(
                    color: Color(0xffd7ff00),
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _fallbackThumb() {
    return Container(
      width: 52,
      height: 52,
      color: const Color(0xff232326),
      alignment: Alignment.center,
      child: const Icon(Icons.image_outlined, color: Colors.white38),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final _ChatMessage message;
  final Color lime;

  const _MessageBubble({required this.message, required this.lime});

  @override
  Widget build(BuildContext context) {
    final rowAlignment = message.isMine
        ? CrossAxisAlignment.end
        : CrossAxisAlignment.start;

    return Column(
      crossAxisAlignment: rowAlignment,
      children: [
        if (!message.isMine)
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 6),
            child: Text(
              message.senderName,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        Row(
          mainAxisAlignment: message.isMine
              ? MainAxisAlignment.end
              : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (!message.isMine)
              Container(
                width: 30,
                height: 30,
                margin: const EdgeInsets.only(right: 8),
                decoration: const BoxDecoration(
                  color: Color(0xfff3f3f3),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.person,
                  size: 18,
                  color: Color(0xff141414),
                ),
              ),
            if (message.isMine)
              Padding(
                padding: const EdgeInsets.only(right: 8, bottom: 4),
                child: Text(
                  message.timeLabel,
                  style: TextStyle(
                    color: lime,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            Flexible(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 260),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(2),
                ),
                child: Text(
                  message.content,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    height: 1.45,
                  ),
                ),
              ),
            ),
            if (!message.isMine)
              Padding(
                padding: const EdgeInsets.only(left: 8, bottom: 4),
                child: Text(
                  message.timeLabel,
                  style: TextStyle(
                    color: lime,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _ChatMessage {
  final String content;
  final String timeLabel;
  final String dateLabel;
  final String dateKey;
  final bool isMine;
  final String senderName;

  const _ChatMessage({
    required this.content,
    required this.timeLabel,
    required this.dateLabel,
    required this.dateKey,
    required this.isMine,
    required this.senderName,
  });

  factory _ChatMessage.fromJson(dynamic raw) {
    final map = raw is Map<String, dynamic>
        ? raw
        : raw is Map
        ? Map<String, dynamic>.from(raw)
        : <String, dynamic>{};

    final senderId = _firstNonNull([
      map['senderId'],
      map['userId'],
      map['memberId'],
      map['writerId'],
    ])?.toString();

    final myUserId = html.window.localStorage['userId'];
    final isMine = _firstTruthy([
      map['isMine'] == true,
      senderId != null && myUserId != null && senderId == myUserId,
      map['senderType'] == 'ME',
    ]);

    final createdAt = _parseDateTime(
      _firstNonNull([
        map['createdAt'],
        map['createdDate'],
        map['sendAt'],
        map['sentAt'],
        map['timestamp'],
      ]),
    );

    return _ChatMessage(
      content:
          _firstNonNull([
            map['content'],
            map['message'],
            map['text'],
          ])?.toString() ??
          '',
      timeLabel: createdAt != null
          ? '${createdAt.hour.toString().padLeft(2, '0')}:${createdAt.minute.toString().padLeft(2, '0')}'
          : '',
      dateLabel: createdAt != null
          ? '${createdAt.year}년 ${createdAt.month}월 ${createdAt.day}일'
          : '',
      dateKey: createdAt != null
          ? '${createdAt.year}-${createdAt.month.toString().padLeft(2, '0')}-${createdAt.day.toString().padLeft(2, '0')}'
          : '',
      isMine: isMine,
      senderName:
          _firstNonNull([
            map['senderNickname'],
            map['nickname'],
            map['senderName'],
            map['username'],
          ])?.toString() ??
          '상대방',
    );
  }

  static Object? _firstNonNull(List<Object?> values) {
    for (final value in values) {
      if (value != null) {
        return value;
      }
    }
    return null;
  }

  static bool _firstTruthy(List<bool> values) {
    for (final value in values) {
      if (value) {
        return true;
      }
    }
    return false;
  }

  static DateTime? _parseDateTime(Object? raw) {
    if (raw == null) {
      return null;
    }

    if (raw is String && raw.isNotEmpty) {
      return DateTime.tryParse(raw)?.toLocal();
    }

    return null;
  }
}
