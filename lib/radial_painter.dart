import 'dart:math';

import 'package:flutter/material.dart';

class RadialPainter extends CustomPainter {
  final Color? bgColor;
  final Color? lineColor;
  final int? totalTarget;
  final int? stepsCount;
  final double? widget;

  RadialPainter({
    this.bgColor,
    this.lineColor,
    this.totalTarget,
    this.stepsCount,
    this.widget,
  });

  @override
  void paint(Canvas canvas, Size size) {
    Paint bgline = Paint()
      ..color = bgColor!
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = widget!;
    Paint completeLine = Paint()
      ..color = lineColor!
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = widget!;

    // Calculate the progress (percentage of steps completed)
    double progress = (stepsCount! / totalTarget!)
        .clamp(0.0, 1.0); // Ensure it's within 0-1 range

    Offset center = Offset(size.width / 2, size.height / 2);
    double radius = min(size.width / 2, size.height / 2);
    // double sweepAnlge = pi;
    // Calculate the sweepAngle based on progress
    double sweepAngle = 2 * pi * progress;
    canvas.drawCircle(center, radius, bgline);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      sweepAngle,
      false,
      completeLine,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    // throw UnimplementedError();
    return true;
  }
}
