import 'package:flutter/material.dart';
import 'dart:math';

class LeapYearCompass extends StatelessWidget {
  const LeapYearCompass({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: CustomPaint(
        size: const Size(80, 80),
        painter: LeapYearCompassPainter(DateTime.now().year),
      ),
    );
  }
}

class LeapYearCompassPainter extends CustomPainter {
  final int year;

  LeapYearCompassPainter(this.year);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Color(0xFF2A292A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.2;

    final double centerX = size.width / 2;
    final double centerY = size.height / 2;
    final double radius = min(centerX, centerY) - 17;

    const double angleIncrement = 2 * pi / 4; // 4 points (L, 1, 2, 3)
    final List<String> points = ['L', '1', '2', '3'];

    // Determine the pointer angle based on the year
    final int yearsSinceLastLeapYear = _yearsSinceLastLeapYear(year);
    final double pointerAngle = yearsSinceLastLeapYear * angleIncrement;

    // Draw the pointer with an arrowhead
    paint.color = Colors.red;
    _drawArrowheadPointer(
        canvas, centerX, centerY, pointerAngle, radius, paint);

    // Draw the text labels for each point
    for (int i = 0; i < points.length; i++) {
      final double angle = i * angleIncrement;
      final double x = centerX + radius * cos(angle);
      final double y = centerY + radius * sin(angle);

      final TextPainter textPainter = TextPainter(
        text: TextSpan(
          text: points[i],
          style: TextStyle(color: Color(0xFF2A292A), fontSize: 14),
        ),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      )..layout();

      final double textX = x - textPainter.width / 2;
      final double textY = y - textPainter.height / 2;
      textPainter.paint(canvas, Offset(textX, textY));
    }
  }

  // Calculate the number of years since the last leap year
  int _yearsSinceLastLeapYear(int year) {
    int yearsSinceLeap = 0;
    while (!isLeapYear(year - yearsSinceLeap)) {
      yearsSinceLeap++;
    }
    return yearsSinceLeap % 4; // Map it between 0 to 3
  }

  // Draw the pointer with an arrowhead
  void _drawArrowheadPointer(Canvas canvas, double centerX, double centerY,
      double pointerAngle, double radius, Paint paint) {
    final double pointerLength = radius - 12; // Length of the pointer
    final double endX = centerX + pointerLength * cos(pointerAngle);
    final double endY = centerY + pointerLength * sin(pointerAngle);

    // Draw the pointer line
    canvas.drawLine(Offset(centerX, centerY), Offset(endX, endY), paint);

    // Draw the arrowhead
    const double arrowHeadSize = 6;
    final double arrowAngle = pi / 6; // 30 degrees for the arrowhead

    final double arrowheadX1 =
        endX - arrowHeadSize * cos(pointerAngle - arrowAngle);
    final double arrowheadY1 =
        endY - arrowHeadSize * sin(pointerAngle - arrowAngle);
    final double arrowheadX2 =
        endX - arrowHeadSize * cos(pointerAngle + arrowAngle);
    final double arrowheadY2 =
        endY - arrowHeadSize * sin(pointerAngle + arrowAngle);

    final Path arrowheadPath = Path()
      ..moveTo(endX, endY)
      ..lineTo(arrowheadX1, arrowheadY1)
      ..lineTo(arrowheadX2, arrowheadY2)
      ..close();

    canvas.drawPath(arrowheadPath, paint);
  }

  bool isLeapYear(int year) {
    return (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
