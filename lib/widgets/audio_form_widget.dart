import 'package:flutter/material.dart';
import 'package:just_waveform/just_waveform.dart';

import 'audio_wave_form_painter.dart';

class AudioWaveformWidget extends StatefulWidget {
  final Color waveColor;
  final double scale;
  final double strokeWidth;
  final int numBars;
  final Waveform waveform;
  final Duration currentPosition;

  const AudioWaveformWidget({
    Key? key,
    required this.waveform,
    required this.currentPosition,
    required this.numBars,
    this.waveColor = const Color(0xffCA8AB2),
    this.scale = 1.0,
    this.strokeWidth = 5.0,
  }) : super(key: key);

  @override
  _AudioWaveformState createState() => _AudioWaveformState();
}

class _AudioWaveformState extends State<AudioWaveformWidget> {
  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: CustomPaint(
        painter: AudioWaveformPainter(
          waveColor: widget.waveColor,
          waveform: widget.waveform,
          currentPosition: widget.currentPosition,
          scale: widget.scale,
          strokeWidth: widget.strokeWidth,
          numBars: widget.numBars,
        ),
      ),
    );
  }
}