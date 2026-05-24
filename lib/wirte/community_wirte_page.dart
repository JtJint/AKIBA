import 'dart:html' as html;

import 'package:akiba/community/api/board_api.dart';
import 'package:akiba/config/api_config.dart';
import 'package:akiba/media/api/media_api.dart';
import 'package:akiba/widgets/community_app_bar.dart';
import 'package:flutter/material.dart';

class CommunityWritePage extends StatefulWidget {
  const CommunityWritePage({super.key, required this.boardCode});

  final String boardCode;

  @override
  State<CommunityWritePage> createState() => _CommunityWritePageState();
}

class _CommunityWritePageState extends State<CommunityWritePage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _tagController = TextEditingController();
  final TextEditingController _linkController = TextEditingController();
  final List<html.File> _imageFiles = [];
  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _tagController.dispose();
    _linkController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final input = html.FileUploadInputElement()
      ..accept = 'image/*'
      ..multiple = true;
    input.click();
    await input.onChange.first;
    final files = input.files ?? const <html.File>[];
    if (!mounted || files.isEmpty) return;
    setState(() {
      _imageFiles
        ..clear()
        ..addAll(files.take(5));
    });
  }

  Future<void> _submit() async {
    if (_isSubmitting) return;

    final userId = int.tryParse(html.window.localStorage['userId'] ?? '');
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();
    final tags = _tagController.text
        .split(RegExp(r'[\s,#]+'))
        .map((tag) => tag.trim())
        .where((tag) => tag.isNotEmpty)
        .take(5)
        .toList();

    if (userId == null) {
      _showSnack('로그인 후 글을 작성할 수 있습니다.');
      return;
    }
    if (title.isEmpty || content.isEmpty) {
      _showSnack('제목과 내용을 입력해주세요.');
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final mediaIds = await MediaApi.uploadAll(_imageFiles);
      final imageUrls = mediaIds
          .map((id) => ApiConfig.uri('api/media/files/$id').toString())
          .toList();

      await BoardApi.createPost(
        boardCode: widget.boardCode,
        payload: BoardPostCreatePayload(
          userId: userId,
          title: title,
          content: content,
          imageUrls: imageUrls,
          hashtags: tags,
          saleOrAuctionLink: _linkController.text.trim(),
        ),
      );

      if (!mounted) return;
      _showSnack('글이 등록되었습니다.');
      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) return;
      _showSnack('글 등록 중 오류가 발생했습니다: $error');
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width.clamp(360.0, 800.0);

    return Center(
      child: SizedBox(
        width: width,
        child: Scaffold(
          backgroundColor: const Color(0xff141414),
          appBar: CommunityAppBar(
            showBack: true,
            centerTitle: true,
            title: Text(
              '${_boardLabel(widget.boardCode)} 글쓰기',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
            actions: [
              TextButton(
                onPressed: _isSubmitting ? null : _submit,
                child: Text(
                  _isSubmitting ? '등록중' : '등록',
                  style: const TextStyle(
                    color: Color(0xffD0FF00),
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Label(text: '제목'),
                const SizedBox(height: 8),
                _Input(controller: _titleController, hintText: '제목을 입력해주세요.'),
                const SizedBox(height: 18),
                _Label(text: '내용'),
                const SizedBox(height: 8),
                _Input(
                  controller: _contentController,
                  hintText: '내용을 입력해주세요.',
                  minLines: 8,
                  maxLines: 12,
                ),
                const SizedBox(height: 18),
                _Label(text: '이미지'),
                const SizedBox(height: 8),
                InkWell(
                  onTap: _pickImages,
                  child: Container(
                    height: 78,
                    decoration: BoxDecoration(
                      color: const Color(0xff202020),
                      borderRadius: BorderRadius.circular(2),
                      border: Border.all(color: const Color(0xff333333)),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.add_photo_alternate_outlined,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _imageFiles.isEmpty
                                ? '이미지 추가'
                                : '${_imageFiles.length}개 선택됨',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                _Label(text: '태그'),
                const SizedBox(height: 8),
                _Input(controller: _tagController, hintText: '#덕질 #우사기'),
                const SizedBox(height: 18),
                _Label(text: '판매/경매 링크'),
                const SizedBox(height: 8),
                _Input(
                  controller: _linkController,
                  hintText: '관련 링크가 있다면 입력해주세요.',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 14,
        fontWeight: FontWeight.w900,
      ),
    );
  }
}

class _Input extends StatelessWidget {
  const _Input({
    required this.controller,
    required this.hintText,
    this.minLines = 1,
    this.maxLines = 1,
  });

  final TextEditingController controller;
  final String hintText;
  final int minLines;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      minLines: minLines,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white),
      cursorColor: const Color(0xffD0FF00),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: Color(0xff777777)),
        filled: true,
        fillColor: const Color(0xff202020),
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xff333333)),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xffD0FF00)),
        ),
      ),
    );
  }
}

String _boardLabel(String boardCode) {
  return switch (boardCode) {
    'AUTHENTICITY' => '정품 감정',
    'QNA_HELP' => 'Q&A',
    _ => '자유',
  };
}
