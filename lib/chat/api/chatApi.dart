import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;
import 'package:akiba/api/auth_http_client.dart';
import 'package:akiba/config/api_config.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:stomp_dart_client/stomp_handler.dart';

import '../../APIs/Board/BoardApi.dart';

class Chatapi {
  static Future<http.Response> getRooms() async {
    final url = Uri.parse('${baseURL}api/chat/rooms');
    final response = await AuthHttpClient.get(url);
    return response;
  }

  static Future<http.Response> postRoom(
    String roomType,
    int marketPostId,
    int targetUserId,
  ) async {
    final url = Uri.parse('${baseURL}api/chat/rooms');
    final response = await AuthHttpClient.post(
      url,
      headers: const {'Content-Type': 'application/json'},
      body:
          '{"roomType": "$roomType", "marketPostId": $marketPostId, "targetUserId": $targetUserId}',
    );
    return response;
  }

  static Future<http.Response> getMessages(int roomId) async {
    final url = Uri.parse('${baseURL}api/chat/rooms/$roomId/messages');
    final response = await AuthHttpClient.get(url);
    return response;
  }

  static Future<http.Response> deleteRoom(int roomId) async {
    final url = Uri.parse('${baseURL}api/chat/rooms/$roomId');
    final response = await AuthHttpClient.delete(url);
    return response;
  }
}

class ChatService {
  ChatService._();

  static final ChatService instance = ChatService._();

  StompClient? _stompClient;
  bool _isConnecting = false;
  bool _isConnected = false;
  bool _lifecycleRegistered = false;
  bool _authListenerRegistered = false;
  String? _connectedToken;
  final List<StreamSubscription> _lifecycleSubscriptions = [];

  // roomId별 구독 해제 함수 저장
  final Map<int, StompUnsubscribe> _subscriptions = {};
  final Map<int, Function(dynamic)> _subscriptionCallbacks = {};

  bool get isConnected => _isConnected;

  void connect([String? accessToken]) {
    final token = accessToken ?? html.window.localStorage['accessToken'] ?? '';

    if (token.isEmpty) {
      debugPrint('웹소켓 연결 중단: accessToken 없음');
      return;
    }

    if ((_isConnecting || _isConnected) && _connectedToken == token) {
      return;
    }

    if (_isConnecting || _isConnected) {
      disconnect();
    }

    _isConnecting = true;
    _connectedToken = token;
    debugPrint(
      '웹소켓 연결 시도: url=${ApiConfig.webSocketUrl}, tokenLength=${token.length}, tokenPrefix=${token.substring(0, token.length > 12 ? 12 : token.length)}',
    );

    _stompClient = StompClient(
      config: StompConfig(
        url: ApiConfig.webSocketUrl,
        reconnectDelay: const Duration(seconds: 0),
        connectionTimeout: const Duration(seconds: 8),
        beforeConnect: () async {
          debugPrint('STOMP beforeConnect 실행');
        },
        onConnect: (frame) {
          _isConnecting = false;
          _isConnected = true;
          debugPrint(
            '연결 성공: command=${frame.command}, headers=${frame.headers}',
          );
          _resubscribeActiveRooms();
        },
        onDisconnect: (frame) {
          _isConnecting = false;
          _isConnected = false;
          debugPrint(
            '연결 끊김: command=${frame.command}, headers=${frame.headers}',
          );
        },
        onStompError: (frame) {
          _isConnecting = false;
          _isConnected = false;
          debugPrint(
            'STOMP 에러: command=${frame.command}, headers=${frame.headers}, body=${frame.body}',
          );
        },
        onWebSocketError: (error) {
          _isConnecting = false;
          _isConnected = false;
          debugPrint('WebSocket 에러: $error');
        },
        onWebSocketDone: () {
          _isConnecting = false;
          _isConnected = false;
          debugPrint('WebSocket 종료');
        },
        onDebugMessage: (message) {
          debugPrint('STOMP 디버그: $message');
        },
        stompConnectHeaders: {'Authorization': 'Bearer $token'},
        webSocketConnectHeaders: {'Authorization': 'Bearer $token'},
      ),
    );

    _stompClient!.activate();
  }

  void connectIfLoggedIn() {
    connect(html.window.localStorage['accessToken']);
  }

  void registerLifecycleHandlers() {
    if (!_authListenerRegistered) {
      _authListenerRegistered = true;
      AuthHttpClient.addAccessTokenRefreshListener(_handleAccessTokenRefreshed);
    }

    if (_lifecycleRegistered) {
      return;
    }

    _lifecycleRegistered = true;
    _lifecycleSubscriptions.addAll([
      html.window.onBeforeUnload.listen((_) {
        disconnect();
      }),
      html.window.onPageHide.listen((_) {
        disconnect();
      }),
    ]);
  }

  void subscribeRoom(int roomId, Function(dynamic) onMessage) {
    _subscriptionCallbacks[roomId] = onMessage;
    _subscribeRoomSocket(roomId, onMessage);
  }

  void _subscribeRoomSocket(int roomId, Function(dynamic) onMessage) {
    final stompClient = _stompClient;
    if (stompClient == null || !_isConnected) {
      return;
    }

    // 이미 같은 방 구독 중이면 중복 구독 방지
    final existing = _subscriptions.remove(roomId);
    existing?.call();

    final unsubscribe = stompClient.subscribe(
      destination: '/topic/chat/$roomId',
      callback: (frame) {
        if (frame.body == null) return;
        final message = jsonDecode(frame.body!);
        onMessage(message);
      },
    );

    _subscriptions[roomId] = unsubscribe;
  }

  void unsubscribeRoom(int roomId) {
    final unsubscribe = _subscriptions[roomId];
    if (unsubscribe != null) {
      unsubscribe(); // 이게 진짜 구독 해제
      _subscriptions.remove(roomId);
    }
    _subscriptionCallbacks.remove(roomId);
  }

  void _resubscribeActiveRooms() {
    if (_subscriptionCallbacks.isEmpty) {
      return;
    }

    final callbacks = Map<int, Function(dynamic)>.from(_subscriptionCallbacks);
    for (final entry in callbacks.entries) {
      _subscribeRoomSocket(entry.key, entry.value);
    }
  }

  void _handleAccessTokenRefreshed(String accessToken) {
    if (accessToken.isEmpty) {
      disconnect();
      return;
    }

    if (_subscriptionCallbacks.isEmpty && !_isConnected && !_isConnecting) {
      return;
    }

    if (_connectedToken == accessToken && (_isConnected || _isConnecting)) {
      return;
    }

    debugPrint('[chat] accessToken refreshed, reconnecting socket');
    disconnect(clearSubscriptionCallbacks: false);
    connect(accessToken);
  }

  void sendMessage(int roomId, String content) {
    final stompClient = _stompClient;
    if (stompClient == null || !_isConnected) {
      print(
        '[chat] sendMessage skipped roomId=$roomId, hasClient=${stompClient != null}, isConnected=$_isConnected',
      );
      return;
    }

    print(
      '[chat] sendMessage transmitting roomId=$roomId, destination=/app/chat/message, content="$content"',
    );
    stompClient.send(
      destination: '/app/chat/message',
      body: jsonEncode({
        'roomId': roomId,
        'messageType': 'TEXT',
        'content': content,
        'mediaId': null,
      }),
    );
    print('[chat] sendMessage done roomId=$roomId');
  }

  void disconnect({bool clearSubscriptionCallbacks = true}) {
    for (final unsubscribe in _subscriptions.values) {
      unsubscribe();
    }
    print('모든 구독 해제 완료');
    _subscriptions.clear();
    if (clearSubscriptionCallbacks) {
      _subscriptionCallbacks.clear();
    }

    _stompClient?.deactivate();
    _stompClient = null;
    _isConnecting = false;
    _isConnected = false;
    _connectedToken = null;
  }
}
