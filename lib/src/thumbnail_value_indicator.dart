import 'dart:ui' as ui;

import 'package:flutter/material.dart';

class ThumbnailValueIndicator extends SliderComponentShape {
  ThumbnailValueIndicator(
    this.thumbnailImages, {
    required this.width,
    required this.height,
    required this.borderRadius,
    required this.offset,
  });

  final List<ui.Image?> thumbnailImages;
  final double width;
  final double height;
  final double borderRadius;
  final Offset offset;

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return Size(width, height);
  }

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final canvas = context.canvas;

    final int index = (value * (thumbnailImages.length)).toInt().clamp(0, thumbnailImages.length - 1);

    if (thumbnailImages[index] == null) return;

    final Rect rect = Rect.fromCenter(center: center.translate(offset.dx, offset.dy), width: width, height: height);
    final RRect rrect = RRect.fromRectAndRadius(rect, Radius.circular(borderRadius));

    final paint = Paint();
    canvas
      ..drawRRect(rrect, paint)
      ..save()
      ..clipRRect(rrect)
      ..drawImageRect(
        thumbnailImages[index]!,
        Rect.fromLTRB(
          0,
          0,
          thumbnailImages[index]!.width.toDouble(),
          thumbnailImages[index]!.height.toDouble(),
        ),
        rect,
        paint,
      )
      ..restore();
  }
}
