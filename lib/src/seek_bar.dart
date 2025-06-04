import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:thumbnail_slider/src/thumbnail_value_indicator.dart';

class SeekBar extends StatefulWidget {
  const SeekBar({
    required this.duration,
    required this.position,
    this.bufferedPosition,
    this.imageList,
    this.thumbnailWidth = 60,
    this.thumbnailHeight = 100,
    this.thumbnailBorderRadius = 8,
    this.thumbnailOffset = const Offset(0, -60),
    this.showElapsedTime = true,
    this.showRemainingTime = true,
    this.textStyle,
    this.leftTextPadding = const EdgeInsets.only(left: 16),
    this.rightTextPadding = const EdgeInsets.only(right: 16),
    super.key,
    this.onChanged,
    this.onChangeEnd,
    this.onEnd,
  });

  final Duration duration;
  final Duration position;
  final Duration? bufferedPosition;
  final ValueChanged<Duration>? onChanged;
  final ValueChanged<Duration>? onChangeEnd;
  final VoidCallback? onEnd;
  final List<String>? imageList;
  final double thumbnailWidth;
  final double thumbnailHeight;
  final double thumbnailBorderRadius;
  final Offset thumbnailOffset;
  final bool showElapsedTime;
  final bool showRemainingTime;
  final TextStyle? textStyle;
  final EdgeInsets leftTextPadding;
  final EdgeInsets rightTextPadding;

  @override
  SeekBarState createState() => SeekBarState();
}

class SeekBarState extends State<SeekBar> {
  double? _dragValue;
  late SliderThemeData _sliderThemeData;
  List<ui.Image?>? _thumbnailImages;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sliderThemeData = SliderTheme.of(context).copyWith(
      trackHeight: 2,
    );
  }

  @override
  void didUpdateWidget(covariant SeekBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageList != widget.imageList) {
      if (widget.imageList?.isNotEmpty ?? false) _loadThumbnails(widget.imageList!);
    }
  }

  Future<void> _loadThumbnails(List<String> imageList) async {
    _thumbnailImages = await Future.wait(
      imageList.map(_loadNetworkImage).toList(),
    );
    setState(() {});
  }

  Future<ui.Image?> _loadNetworkImage(String url) async {
    try {
      final http.Response response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final Completer<ui.Image> completer = Completer();
        ui.decodeImageFromList(Uint8List.view(response.bodyBytes.buffer), completer.complete);
        return completer.future;
      }
    } catch (e) {
      debugPrint('Failed to load image: $e');
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.duration == widget.position) {
      widget.onEnd?.call();
    }
    return Stack(
      children: [
        if (widget.bufferedPosition != null)
          SliderTheme(
            data: _sliderThemeData.copyWith(
              thumbShape: HiddenThumbComponentShape(),
            ),
            child: ExcludeSemantics(
              child: Slider(
                max: widget.duration.inMilliseconds.toDouble(),
                value:
                    min(widget.bufferedPosition!.inMilliseconds.toDouble(), widget.duration.inMilliseconds.toDouble()),
                onChanged: (value) {
                  setState(() {
                    _dragValue = value;
                  });
                  widget.onChanged?.call(Duration(milliseconds: value.round()));
                },
                onChangeEnd: (value) {
                  widget.onChangeEnd?.call(Duration(milliseconds: value.round()));
                  _dragValue = null;
                },
              ),
            ),
          ),
        SliderTheme(
          data: _sliderThemeData.copyWith(
            inactiveTrackColor: Colors.transparent,
            valueIndicatorShape: _thumbnailImages?.isNotEmpty ?? false
                ? ThumbnailValueIndicator(
                    _thumbnailImages!,
                    width: widget.thumbnailWidth,
                    height: widget.thumbnailHeight,
                    borderRadius: widget.thumbnailBorderRadius,
                    offset: widget.thumbnailOffset,
                  )
                : null,
          ),
          child: Slider(
            label: _thumbnailImages?.isNotEmpty ?? false ? '' : null,
            max: widget.duration.inMilliseconds.toDouble(),
            value:
                min(_dragValue ?? widget.position.inMilliseconds.toDouble(), widget.duration.inMilliseconds.toDouble()),
            onChanged: (value) {
              setState(() {
                _dragValue = value;
              });
              widget.onChanged?.call(Duration(milliseconds: value.round()));
            },
            onChangeEnd: (value) {
              widget.onChangeEnd?.call(Duration(milliseconds: value.round()));
              _dragValue = null;
            },
          ),
        ),
        if (widget.showElapsedTime)
          Positioned(
            left: 0,
            bottom: 0,
            child: Padding(
              padding: widget.leftTextPadding,
              child: Text(
                formatDuration(widget.position),
                style: widget.textStyle ?? Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white),
              ),
            ),
          ),
        if (widget.showRemainingTime)
          Positioned(
            right: 0,
            bottom: 0,
            child: Padding(
              padding: widget.rightTextPadding,
              child: Text(
                RegExp(r'((^0*[1-9]\d*:)?\d{2}:\d{2})\.\d+$').firstMatch('$_remaining')?.group(1) ??
                    formatDuration(_remaining),
                style: widget.textStyle ?? Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white),
              ),
            ),
          ),
      ],
    );
  }

  Duration get _remaining => widget.duration - widget.position;

  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final String minutes = twoDigits(duration.inMinutes.remainder(60));
    final String seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }
}

class HiddenThumbComponentShape extends SliderComponentShape {
  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) => Size.zero;

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
  }) {}
}
