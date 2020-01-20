import 'dart:math';

import 'package:flutter/material.dart';

enum ClockText{
  roman,
  arabic
}

class ClockDialPainter extends CustomPainter {
  final clockText;

  final Color accentColour;

  final Paint tickPaint;
  final TextPainter textPainter;
  final TextStyle textStyle;

  final double tickLength = 10.0;
  final double tickWidth = 2;

  ClockDialPainter({this.clockText = ClockText.roman, this.accentColour})
      : tickPaint = new Paint(),
        textPainter = new TextPainter(
          textAlign: TextAlign.center,
          textDirection: TextDirection.rtl,
        ),
        textStyle = const TextStyle(
          color: Colors.black,
          fontFamily: 'Times New Roman',
          fontSize: 15.0,
        ) {
    tickPaint.color = Colors.black;
  }

  // an effective way to seperate each 5 second indicator with 4 individual second indicators
  // is to duplicate and overlap each painter

  @override
  void paint(Canvas clock, Size size) {
    final angle = 0.5 * pi / 15;
    final radius = size.width / 2;
    clock.save();

    // drawing
    clock.translate(radius, radius);
    for (var i = 0; i < 60; i++) {
      tickPaint.strokeWidth = 0.5;

      tickPaint.color = accentColour;

      clock.drawLine(new Offset(0.0, -radius),
      new Offset(0.0, -radius + tickLength), tickPaint);

      clock.rotate(angle);
    }

    clock.restore();

    final angle2 = 2 * pi / 12;
    final radius2 = size.width / 2;
    clock.save();

    // drawing
    clock.translate(radius2, radius2);
    for (var i = 0; i < 60; i++) {
      tickPaint.strokeWidth = 3;

      clock.drawLine(new Offset(0.0, -radius2),
      new Offset(0.0, -radius2 + tickLength), tickPaint);

      clock.rotate(angle2);
    }

    clock.restore();
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}