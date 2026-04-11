import 'dart:convert';
import 'dart:ui' as html;
import 'dart:html';
import 'package:http/http.dart' as http;
import 'package:localstorage/localstorage.dart';

String baseURL = 'https://dev-api.akibaha.shop/';

class myPageAPI {
  static Future<http.Response> getProfile() async {
    final accessToken = window.localStorage['accessToken'];

    final url = Uri.parse('${baseURL}api/profile/me');
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $accessToken'},
    );
    print("getProfile response: ${response.body}");
    return response;
  }
}
