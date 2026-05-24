import 'package:akiba/api/auth_http_client.dart';
import 'package:akiba/config/api_config.dart';
import 'package:http/http.dart' as http;

String baseURL = ApiConfig.baseUrl;

class myPageAPI {
  static Future<http.Response> getProfile() async {
    final url = Uri.parse('${baseURL}api/users/me');
    final response = await AuthHttpClient.get(url);
    // print("getProfile response: ${response.body}");
    return response;
  }
}
