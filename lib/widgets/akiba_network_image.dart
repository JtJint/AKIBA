import 'package:akiba/config/api_config.dart';
import 'package:flutter/material.dart';

class AkibaNetworkImage extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final resolvedUrl = ApiConfig.resourceUrl(url);
    if (resolvedUrl.isEmpty) return _buildError(context);

    return Image.network(
      resolvedUrl,
      width: width,
      height: height,
      fit: fit,
      gaplessPlayback: true,
      webHtmlElementStrategy: WebHtmlElementStrategy.prefer,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return SizedBox(
          width: width,
          height: height,
          child: const Center(
            child: SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        );
      },
      errorBuilder: (_, __, ___) => _buildError(context),
    );
  }

  Widget _buildError(BuildContext context) {
    return errorBuilder?.call(context) ?? SizedBox(width: width, height: height);
  }
}
