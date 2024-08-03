import 'dart:math';

import 'package:flutter/material.dart';
import 'package:just_waveform/just_waveform.dart';

class AudioWaveformPainter extends CustomPainter {
  final double scale;
  final double strokeWidth;
  final int numBars;
  final Paint wavePaint;
  final Waveform waveform;
  final Duration currentPosition;

  AudioWaveformPainter({
    required this.waveform,
    required this.currentPosition,
    required this.numBars,
    Color waveColor = const Color(0xffCA8AB2),
    this.scale = 1.0,
    this.strokeWidth = 5.0,
  }) : wavePaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = strokeWidth
    ..strokeCap = StrokeCap.round
    ..color = waveColor;

  @override
  void paint(Canvas canvas, Size size) {
    double width = size.width;
    double height = size.height;
    double pixelsPerBar = width / numBars;
    final currentPixel = waveform.positionToPixel(currentPosition).toInt();
    final startPixel = max(0, currentPixel - numBars ~/ 2);

    for (int i = 0; i < numBars; i++) {
      final sampleIdx = startPixel + i;
      if (sampleIdx >= waveform.data.length) break;

      final x = i * pixelsPerBar + strokeWidth / 2;
      final minY = normalise(waveform.getPixelMin(sampleIdx), height);
      final maxY = normalise(waveform.getPixelMax(sampleIdx), height);

      canvas.drawLine(
        Offset(x, height),
        Offset(x, height - maxY),
        wavePaint,
      );
    }
    //
    // // Draw current playback position
    // final playHeadX = numBars / 2 * pixelsPerBar;
    // final playHeadPaint = Paint()
    //   ..color = Colors.red
    //   ..style = PaintingStyle.stroke
    //   ..strokeWidth = 1.0
    //   ..strokeCap = StrokeCap.round;
    //
    // canvas.drawLine(
    //   Offset(playHeadX, 0),
    //   Offset(playHeadX, height),
    //   playHeadPaint,
    // );
  }

  @override
  bool shouldRepaint(covariant AudioWaveformPainter oldDelegate) {
    return oldDelegate.currentPosition != currentPosition;
  }

  double normalise(int s, double height) {
    if (waveform.flags == 0) {
      final y = 32768 + (scale * s).clamp(-32768.0, 32767.0).toDouble();
      return height - (y * height / 65536);
    } else {
      final y = 128 + (scale * s).clamp(-128.0, 127.0).toDouble();
      return height - (y * height / 256);
    }
  }
}