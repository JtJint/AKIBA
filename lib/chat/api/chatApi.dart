import 'dart:html';
import 'package:http/http.dart' as http;
import 'package:localstorage/localstorage.dart';
import 'dart:convert';
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:stomp_dart_client/stomp_frame.dart';
import 'package:stomp_dart_client/stomp_handler.dart';

import '../../APIs/Board/BoardApi.dart';

class Chatapi {
  static Future<http.Response> getRooms() async {
    final accessToken = window.localStorage['accessToken'];

    final url = Uri.parse('${baseURL}api/chat/rooms');
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $accessToken'},
    );
    return response;
  }

  static Future<http.Response> postRoom(
    String roomType,
    int marketPostId,
    int targetUserId,
  ) async {
    final accessToken = window.localStorage['accessToken'];

    final url = Uri.parse('${baseURL}api/chat/rooms');
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body:
          '{"roomType": "$roomType", "marketPostId": $marketPostId, "targetUserId": $targetUserId}',
    );
    return response;
  }

  static Future<http.Response> getMessages(int roomId) async {
    final accessToken = window.localStorage['accessToken'];

    final url = Uri.parse('${baseURL}api/chat/rooms/$roomId/messages');
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $accessToken'},
    );
    return response;
  }

  static Future<http.Response> deleteRoom(int roomId) async {
    final accessToken = window.localStorage['accessToken'];

    final url = Uri.parse('${baseURL}api/chat/rooms/$roomId');
    final response = await http.delete(
      url,
      headers: {'Authorization': 'Bearer $accessToken'},
    );
    return response;
  }
}

class ChatService {
  late StompClient stompClient;

  // roomId별 구독 해제 함수 저장
  final Map<int, StompUnsubscribe> _subscriptions = {};

  void connect(String accessToken) {
    stompClient = StompClient(
      config: StompConfig(
        url: 'wss://dev-api.akibaha.shop/ws/chat/websocket',
        onConnect: (frame) {
          print('연결 성공');
        },
        onDisconnect: (frame) {
          print('연결 끊김');
        },
        onStompError: (frame) {
          print('STOMP 에러: ${frame.body}');
        },
        onWebSocketError: (error) {
          print('WebSocket 에러: $error');
        },
        stompConnectHeaders: {'Authorization': 'Bearer $accessToken'},
        webSocketConnectHeaders: {'Authorization': 'Bearer $accessToken'},
      ),
    );

    stompClient.activate();
  }

  void subscribeRoom(int roomId, Function(dynamic) onMessage) {
    // 이미 같은 방 구독 중이면 중복 구독 방지
    unsubscribeRoom(roomId);

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
  }

  void sendMessage(int roomId, String content) {
    stompClient.send(
      destination: '/app/chat/message',
      body: jsonEncode({
        'roomId': roomId,
        'messageType': 'TEXT',
        'content': content,
        'mediaId': null,
      }),
    );
  }

  void disconnect() {
    for (final unsubscribe in _subscriptions.values) {
      unsubscribe();
    }
    _subscriptions.clear();

    stompClient.deactivate();
  }
}
