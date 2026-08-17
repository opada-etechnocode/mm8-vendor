import 'dart:io';
import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:sixvalley_vendor_app/utill/images.dart';

int memoryCachePixels(BuildContext context, {double? width, double? height, int maxPixels = 720}) {
  final double dpr = MediaQuery.devicePixelRatioOf(context);
  final Size screen = MediaQuery.sizeOf(context);
  double logical = width ?? height ?? screen.shortestSide;
  if (!logical.isFinite || logical <= 0) {
    logical = screen.shortestSide;
  }
  return max(64, min(maxPixels, (logical * dpr).round()));
}

class CustomImageWidget extends StatelessWidget {
  final String image;
  final double? height;
  final double? width;
  final BoxFit fit;
  final String? placeholder;
  const CustomImageWidget({super.key, required this.image, this.height, this.width, this.fit = BoxFit.cover, this.placeholder = Images.placeholderImage});

  @override
  Widget build(BuildContext context) {
    if (image.isEmpty) {
      return Image.asset(placeholder?? Images.placeholderImage, height: height, width: width, fit: BoxFit.cover);
    }
    final int cache = memoryCachePixels(context, width: width, height: height);
    return CachedNetworkImage(
      placeholder: (context, url) => Image.asset(placeholder?? Images.placeholderImage, height: height, width: width, fit: BoxFit.cover),
      imageUrl: image, fit: fit,
      height: height,width: width,
      memCacheWidth: cache,
      maxWidthDiskCache: cache,
      errorWidget: (c, o, s) => Image.asset(placeholder?? Images.placeholderImage, height: height, width: width, fit: BoxFit.cover),
    );
  }
}

class MemorySafeFileImage extends StatelessWidget {
  final File file;
  final double width;
  final double height;
  final BoxFit fit;
  const MemorySafeFileImage({
    super.key,
    required this.file,
    required this.width,
    required this.height,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    final int cache = memoryCachePixels(context, width: width, height: height);
    return Image.file(
      file,
      width: width,
      height: height,
      fit: fit,
      cacheWidth: cache,
      filterQuality: FilterQuality.low,
    );
  }
}
