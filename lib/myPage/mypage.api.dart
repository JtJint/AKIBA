import 'package:akiba/api/auth_http_client.dart';
import 'package:akiba/config/api_config.dart';
import 'package:http/http.dart' as http;

String baseURL = ApiConfig.baseUrl;

class myPageAPI {
  static Future<http.Response> getProfile({int? targetUserId}) async {
    if (targetUserId == null) {
      return getMyProfile();
    }

    final url = Uri.parse('${baseURL}api/profile/$targetUserId');
    return AuthHttpClient.get(url);
  }

  static Future<http.Response> getMyProfile() async {
    final url = Uri.parse('${baseURL}api/profile/me');
    return AuthHttpClient.get(url);
  }

  static Future<http.Response> follow(int targetUserId) async {
    final url = Uri.parse('${baseURL}api/profile/$targetUserId/follow');
    return AuthHttpClient.post(url);
  }

  static Future<http.Response> unfollow(int targetUserId) async {
    final url = Uri.parse('${baseURL}api/profile/$targetUserId/unfollow');
    return AuthHttpClient.delete(url);
  }
}
