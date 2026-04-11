import 'dart:convert';
import 'dart:ui' as html;
import 'dart:html';
import 'package:akiba/chat/api/chatApi.dart';
import 'package:http/http.dart' as http;
import 'package:localstorage/localstorage.dart';

String baseURL = 'https://dev-api.akibaha.shop/';

class Loginapi {
  static Future<http.Response> loginAct(String Code, String state) async {
    final url = Uri.parse('${baseURL}api/users/login');
    final body = {
      "provider": "NAVER",
      "code": Code,
      "state": state,
      "env": "dev",
    };
    // final body = {
    //   // 배포 기준 ???
    //   "provider": "NAVER",
    //   "code": Code,
    //   "state": state,
    //   "env": "prod",
    // };

    final reqBody = jsonEncode(body);
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: reqBody,
    );

    final resBody = jsonDecode(response.body);

    window.localStorage['accessToken'] = resBody['accessToken'].toString();
    window.localStorage['refreshToken'] = resBody['refreshToken'].toString();
    //   if (response.statusCode == 200) {
    //     print('Login successful');
    //     ChatService.connect(resBody['accessToken'].toString());
    //   } else {
    //     print('Login failed: ${response.statusCode}');
    //   }
    return response;
  }

  static Future<http.Response> setNickName(String accessToken) async {
    final url = Uri.parse('${baseURL}api/users/me');
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $accessToken'},
    );

    return response;
  }
}
