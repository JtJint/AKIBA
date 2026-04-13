import 'package:flutter/material.dart';

class ChatItemModel {
  final int roodId;
  final String imageUrl;
  final String title;
  final String preview;
  final String category;
  final String userName;
  final String dateText;

  ChatItemModel({
    required this.roodId,
    required this.imageUrl,
    required this.title,
    required this.preview,
    required this.category,
    required this.userName,
    required this.dateText,
  });
}


 //여기까지 박스 하나짜리임 이거 api로 가져와서 해보자이