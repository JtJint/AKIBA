import 'dart:convert';

import 'package:akiba/api/auth_http_client.dart';
import 'package:akiba/config/api_config.dart';
import 'package:http/http.dart' as http;

class MarketPostApi {
  static Future<http.Response> createUsedPost(UsedPostPayload payload) {
    return AuthHttpClient.post(
      ApiConfig.uri('api/used/posts'),
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode(payload.toJson()),
    );
  }

  static Future<http.Response> createAuctionPost(AuctionPostPayload payload) {
    return AuthHttpClient.post(
      ApiConfig.uri('api/auction/posts'),
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode(payload.toJson()),
    );
  }

  static Future<http.Response> createLimitedPost(LimitedPostPayload payload) {
    return AuthHttpClient.post(
      ApiConfig.uri('api/limited/posts'),
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode(payload.toJson()),
    );
  }
}

class UsedPostPayload {
  const UsedPostPayload({
    required this.title,
    required this.content,
    required this.price,
    required this.productCondition,
    required this.specialType,
    required this.categoryId,
    required this.deliveryMethod,
    required this.purchaseSource,
    this.receiptMediaId,
    required this.imageMediaIds,
    required this.tagNames,
  });

  final String title;
  final String content;
  final int price;
  final String productCondition;
  final String specialType;
  final int categoryId;
  final String deliveryMethod;
  final String purchaseSource;
  final int? receiptMediaId;
  final List<int> imageMediaIds;
  final List<String> tagNames;

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'content': content,
      'price': price,
      'productCondition': productCondition,
      'specialType': specialType,
      'categoryId': categoryId,
      'deliveryMethod': deliveryMethod,
      'purchaseSource': purchaseSource,
      if (receiptMediaId != null && receiptMediaId! > 0)
        'receiptMediaId': receiptMediaId,
      'imageMediaIds': imageMediaIds,
      'tagNames': tagNames,
    };
  }
}

class AuctionPostPayload {
  const AuctionPostPayload({
    required this.title,
    required this.content,
    required this.productCondition,
    required this.specialType,
    required this.categoryId,
    required this.startPrice,
    this.buyNowPrice,
    required this.bidStep,
    required this.endsAt,
    required this.deliveryMethod,
    required this.purchaseSource,
    this.receiptMediaId,
    required this.imageMediaIds,
    required this.tagNames,
  });

  final String title;
  final String content;
  final String productCondition;
  final String specialType;
  final int categoryId;
  final int startPrice;
  final int? buyNowPrice;
  final int bidStep;
  final DateTime endsAt;
  final String deliveryMethod;
  final String purchaseSource;
  final int? receiptMediaId;
  final List<int> imageMediaIds;
  final List<String> tagNames;

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'content': content,
      'productCondition': productCondition,
      'specialType': specialType,
      'categoryId': categoryId,
      'startPrice': startPrice,
      if (buyNowPrice != null) 'buyNowPrice': buyNowPrice,
      'bidStep': bidStep,
      'endsAt': endsAt.toIso8601String(),
      'deliveryMethod': deliveryMethod,
      'purchaseSource': purchaseSource,
      if (receiptMediaId != null && receiptMediaId! > 0)
        'receiptMediaId': receiptMediaId,
      'imageMediaIds': imageMediaIds,
      'tagNames': tagNames,
    };
  }
}

class LimitedPostPayload {
  const LimitedPostPayload({
    this.type = 'LIMITED',
    required this.title,
    required this.content,
    required this.price,
    required this.productCondition,
    required this.specialType,
    required this.categoryId,
    required this.deliveryMethod,
    required this.purchaseSource,
    this.receiptMediaId,
    required this.imageMediaIds,
    required this.tagNames,
  });

  final String type;
  final String title;
  final String content;
  final int price;
  final String productCondition;
  final String specialType;
  final int categoryId;
  final String deliveryMethod;
  final String purchaseSource;
  final int? receiptMediaId;
  final List<int> imageMediaIds;
  final List<String> tagNames;

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'title': title,
      'content': content,
      'price': price,
      'productCondition': productCondition,
      'specialType': specialType,
      'categoryId': categoryId,
      'deliveryMethod': deliveryMethod,
      'purchaseSource': purchaseSource,
      if (receiptMediaId != null && receiptMediaId! > 0)
        'receiptMediaId': receiptMediaId,
      'imageMediaIds': imageMediaIds,
      'tagNames': tagNames,
    };
  }
}
