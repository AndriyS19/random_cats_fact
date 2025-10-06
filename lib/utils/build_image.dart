import 'dart:io';
import 'package:flutter/material.dart';

Widget buildImage(String imageUrl, {BoxFit fit = BoxFit.cover}) {
  if (imageUrl.isEmpty) return Container(color: Colors.grey[200]);

  if (imageUrl.startsWith('http')) {
    return Image.network(
      imageUrl,
      fit: fit,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return Center(
          child: CircularProgressIndicator(
            value: progress.expectedTotalBytes != null
                ? progress.cumulativeBytesLoaded / progress.expectedTotalBytes!
                : null,
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) => Container(
        color: Colors.grey[200],
        child: const Center(child: Icon(Icons.broken_image)),
      ),
    );
  } else {
    // Local file image
    final file = File(imageUrl);
    if (!file.existsSync()) {
      return Container(
        color: Colors.grey[200],
        child: const Center(child: Icon(Icons.broken_image)),
      );
    }
    return Image.file(
      file,
      key: ValueKey(imageUrl),
      fit: fit,
      // Maximum quality rendering for saved images
      filterQuality: FilterQuality.high,
      isAntiAlias: true,
      cacheWidth: null,
      cacheHeight: null,
    );
  }
}
