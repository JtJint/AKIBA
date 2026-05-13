import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;
import 'dart:typed_data';

import 'package:akiba/api/auth_http_client.dart';
import 'package:akiba/config/api_config.dart';
import 'package:http/http.dart' as http;

class MediaApi {
  static const int _maxImageSide = 1600;
  static const double _jpegQuality = 0.82;

  static Future<int> upload(html.File file) async {
    final uploadFile = await _prepareUploadFile(file);
    final streamed = await _sendUploadRequest(uploadFile);
    final response = await http.Response.fromStream(streamed);

    if (response.statusCode == 401 &&
        await AuthHttpClient.refreshAccessToken()) {
      final retryStreamed = await _sendUploadRequest(uploadFile);
      final retryResponse = await http.Response.fromStream(retryStreamed);
      return _handleUploadResponse(retryResponse);
    }

    return _handleUploadResponse(response);
  }

  static Future<http.StreamedResponse> _sendUploadRequest(_UploadFile file) {
    final request = http.MultipartRequest(
      'POST',
      ApiConfig.uri('api/media/upload'),
    )..headers.addAll(AuthHttpClient.authHeaders());
    request.files.add(
      http.MultipartFile.fromBytes('file', file.bytes, filename: file.name),
    );

    return request.send();
  }

  static int _handleUploadResponse(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw MediaUploadException(response.statusCode, response.body);
    }

    return _extractMediaId(jsonDecode(response.body));
  }

  static Future<List<int>> uploadAll(List<html.File> files) async {
    final mediaIds = <int>[];
    for (final file in files) {
      mediaIds.add(await upload(file));
    }
    return mediaIds;
  }

  static Future<_UploadFile> _prepareUploadFile(html.File file) async {
    final originalBytes = await _readFileBytes(file);
    if (!_isCompressibleImage(file)) {
      return _UploadFile(name: file.name, bytes: originalBytes);
    }

    try {
      final compressedBytes = await _resizeAndCompress(file);
      final selectedBytes = compressedBytes.length < originalBytes.length
          ? compressedBytes
          : originalBytes;
      return _UploadFile(name: _jpegFileName(file.name), bytes: selectedBytes);
    } catch (_) {
      return _UploadFile(name: file.name, bytes: originalBytes);
    }
  }

  static bool _isCompressibleImage(html.File file) {
    return const {'image/jpeg', 'image/png', 'image/webp'}.contains(file.type);
  }

  static Future<Uint8List> _resizeAndCompress(html.File file) async {
    final objectUrl = html.Url.createObjectUrl(file);
    try {
      final image = html.ImageElement(src: objectUrl);
      await image.onLoad.first;

      final sourceWidth = image.naturalWidth;
      final sourceHeight = image.naturalHeight;
      final scale = [
        _maxImageSide / sourceWidth,
        _maxImageSide / sourceHeight,
        1.0,
      ].reduce((a, b) => a < b ? a : b);
      final targetWidth = (sourceWidth * scale)
          .round()
          .clamp(1, sourceWidth)
          .toInt();
      final targetHeight = (sourceHeight * scale)
          .round()
          .clamp(1, sourceHeight)
          .toInt();

      final canvas = html.CanvasElement(
        width: targetWidth,
        height: targetHeight,
      );
      final context = canvas.context2D;
      context
        ..fillStyle = '#FFFFFF'
        ..fillRect(0, 0, targetWidth, targetHeight)
        ..drawImageScaled(image, 0, 0, targetWidth, targetHeight);

      final blob = await _canvasToBlob(canvas);
      return _readBlobBytes(blob);
    } finally {
      html.Url.revokeObjectUrl(objectUrl);
    }
  }

  static Future<html.Blob> _canvasToBlob(html.CanvasElement canvas) {
    return canvas.toBlob('image/jpeg', _jpegQuality);
  }

  static Future<Uint8List> _readFileBytes(html.File file) {
    return _readBlobBytes(file);
  }

  static Future<Uint8List> _readBlobBytes(html.Blob blob) {
    final reader = html.FileReader();
    final completer = Completer<Uint8List>();

    reader.onLoad.listen((_) {
      final result = reader.result;
      if (result is ByteBuffer) {
        completer.complete(result.asUint8List());
        return;
      }
      if (result is Uint8List) {
        completer.complete(result);
        return;
      }
      completer.completeError(StateError('이미지 파일을 읽지 못했습니다.'));
    });
    reader.onError.listen((_) {
      completer.completeError(StateError('이미지 파일을 읽지 못했습니다.'));
    });
    reader.readAsArrayBuffer(blob);

    return completer.future;
  }

  static String _jpegFileName(String fileName) {
    final name = fileName.trim().isEmpty ? 'upload' : fileName.trim();
    final dotIndex = name.lastIndexOf('.');
    if (dotIndex <= 0) return '$name.jpg';
    return '${name.substring(0, dotIndex)}.jpg';
  }

  static int _extractMediaId(dynamic decoded) {
    if (decoded is Map<String, dynamic>) {
      final candidates = [
        decoded['mediaId'],
        decoded['id'],
        decoded['data'] is Map ? decoded['data']['mediaId'] : null,
        decoded['result'] is Map ? decoded['result']['mediaId'] : null,
      ];
      for (final candidate in candidates) {
        final parsed = int.tryParse(candidate?.toString() ?? '');
        if (parsed != null) return parsed;
      }
    }
    throw StateError('mediaId를 응답에서 찾지 못했습니다.');
  }
}

class MediaUploadException implements Exception {
  const MediaUploadException(this.statusCode, this.body);

  final int statusCode;
  final String body;

  @override
  String toString() => 'MediaUploadException($statusCode): $body';
}

class _UploadFile {
  const _UploadFile({required this.name, required this.bytes});

  final String name;
  final Uint8List bytes;
}
