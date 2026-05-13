import 'dart:html';
import 'package:akiba/config/api_config.dart';
import 'package:http/http.dart' as http;

String baseURL = ApiConfig.baseUrl;

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
