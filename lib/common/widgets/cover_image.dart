import 'package:book_store/core/utils/asset_url.dart';
import 'package:flutter/material.dart';

class CoverImage extends StatelessWidget {
  final String? coverUrl;
  final double? width;
  final double? height;
  final double? aspectRatio;
  final double borderRadius;
  final BoxFit fit;

  const CoverImage({
    super.key,
    this.coverUrl,
    this.width,
    this.height,
    this.aspectRatio,
    this.borderRadius = 8.0,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    final provider = coverImageProvider(coverUrl);
    final decoration = BoxDecoration(
      borderRadius: BorderRadius.circular(borderRadius),
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
    );

    Widget image = Container(
      width: width,
      height: height,
      decoration: decoration,
      clipBehavior: Clip.antiAlias,
      child: provider != null
          ? Image(
              image: provider,
              fit: fit,
              errorBuilder: (_, error, stackTrace) => _placeholder(context),
            )
          : _placeholder(context),
    );

    if (aspectRatio != null) {
      image = SizedBox(
        width: width,
        child: AspectRatio(
          aspectRatio: aspectRatio!,
          child: image,
        ),
      );
    }

    return image;
  }

  Widget _placeholder(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: const Center(child: Icon(Icons.book)),
    );
  }
}
