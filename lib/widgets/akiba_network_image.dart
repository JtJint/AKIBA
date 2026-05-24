import 'dart:typed_data';

import 'package:akiba/api/auth_http_client.dart';
import 'package:flutter/material.dart';

class AkibaNetworkImage extends StatefulWidget {
  const AkibaNetworkImage({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.fit,
    this.errorBuilder,
  });

  final String url;
  final double? width;
  final double? height;
  final BoxFit? fit;
  final WidgetBuilder? errorBuilder;

  @override
  State<AkibaNetworkImage> createState() => _AkibaNetworkImageState();
}

class _AkibaNetworkImageState extends State<AkibaNetworkImage> {
  late Future<Uint8List> _bytesFuture;

  @override
  void initState() {
    super.initState();
    _bytesFuture = _fetchBytes();
  }

  @override
  void didUpdateWidget(covariant AkibaNetworkImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url) {
      _bytesFuture = _fetchBytes();
    }
  }

  Future<Uint8List> _fetchBytes() async {
    final uri = Uri.tryParse(widget.url);
    if (uri == null) {
      throw StateError('이미지 URL이 올바르지 않습니다.');
    }

    final response = await AuthHttpClient.get(uri);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw StateError('이미지 요청 실패 (${response.statusCode})');
    }
    return response.bodyBytes;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List>(
      future: _bytesFuture,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Image.memory(
            snapshot.data!,
            width: widget.width,
            height: widget.height,
            fit: widget.fit,
            gaplessPlayback: true,
            errorBuilder: (_, __, ___) => _buildError(context),
          );
        }

        if (snapshot.hasError) {
          return _buildError(context);
        }

        return SizedBox(
          width: widget.width,
          height: widget.height,
          child: const Center(
            child: SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        );
      },
    );
  }

  Widget _buildError(BuildContext context) {
    return widget.errorBuilder?.call(context) ??
        SizedBox(width: widget.width, height: widget.height);
  }
}
