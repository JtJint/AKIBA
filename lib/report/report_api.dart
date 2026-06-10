import 'dart:convert';

import 'package:akiba/api/auth_http_client.dart';
import 'package:akiba/config/api_config.dart';
import 'package:http/http.dart' as http;

class ReportApi {
  static Future<http.Response> createReport({
    required int targetUserId,
    required String reportType,
    required String reason,
    required String detail,
    int? targetPostId,
  }) {
    return AuthHttpClient.post(
      ApiConfig.uri('api/reports'),
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode({
        'targetUserId': targetUserId,
        'reportType': reportType,
        'reason': reason,
        'detail': detail,
        if (targetPostId != null) 'targetPostId': targetPostId,
      }),
    );
  }
}
