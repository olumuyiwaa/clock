import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

class AnalogClock extends StatefulWidget {
  const AnalogClock({
    super.key,
  });

  @override
  _AnalogClockState createState() => _AnalogClockState();
}

class _AnalogClockState extends State<AnalogClock> {
  @override
  void initState() {
    super.initState();
    Timer.periodic(const Duration(milliseconds: 1), (_) => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.only(top: 48),
        alignment: Alignment.center,
        height: 320,
        child: CustomPaint(
          size: const Size(200, 200),
          painter: ClockPainter(),
        ));
  }
}

class ClockPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final center = size.width / 2;
    final radius = min(size.width / 1.2, size.height / 1.2);

    _drawClockCircle(canvas, size, paint, center, radius);
    _drawMonthIndicator(canvas, center, radius, paint);
    _drawWeekday(canvas, center, radius, paint);
    _drawDay(canvas, center, radius, paint);
    _drawClockHands(canvas, size, paint, center, radius);
  }

  void _drawMonthIndicator(
      Canvas canvas, double center, double radius, Paint paint) {
    final now = DateTime.now();
    // Calculate the angle for the current month
    final monthAngle = (now.month - 3) * (360 / 12);

    final indicatorLength = radius * 0.75;
    final arcRadius = 10.0;

    final arcCenter = Offset(
      center + indicatorLength * cos(monthAngle * pi / 180),
      center + indicatorLength * sin(monthAngle * pi / 180),
    );

    final rect = Rect.fromCircle(center: arcCenter, radius: arcRadius);

    // Draw the arc
    paint.color = Colors.red;
    paint.strokeWidth = 6.0;
    paint.style = PaintingStyle.stroke;

    final sweepAngle = pi / 5;

    // Draw the arc
    canvas.drawArc(
        rect, (monthAngle - 15) * pi / 180, sweepAngle, false, paint);
  }

  void _drawClockCircle(
      Canvas canvas, Size size, Paint paint, double center, double radius) {
    // Load the background image
    final backgroundImage = AssetImage('assets/watchface.png');
    final imageStream = backgroundImage.resolve(ImageConfiguration.empty);

    imageStream.addListener(
        ImageStreamListener((ImageInfo imageInfo, bool synchronousCall) {
      // Define the rectangle that will contain the background image
      final Rect rect = Rect.fromCenter(
          center: Offset(center, center),
          width: radius * 2,
          height: radius * 2);

      // Draw the background image
      canvas.drawImageRect(
        imageInfo.image,
        Rect.fromLTWH(0, 0, imageInfo.image.width.toDouble(),
            imageInfo.image.height.toDouble()),
        rect,
        Paint(),
      );
    }));

    paint.strokeWidth = 2;
    paint.color = Color(0xFFC0C0C0);
    canvas.drawCircle(Offset(center, center), radius, paint);
  }

  void _drawClockHands(
      Canvas canvas, Size size, Paint paint, double center, double radius) {
    final now = DateTime.now();
    final secondsAngle = (now.second + now.millisecond / 1000) * 6.0;
    final minutesAngle = (now.minute + now.second / 60) * 6.0;
    final hoursAngle = (now.hour % 12 + now.minute / 60) * 30.0;

    paint.color = Color(0xFFC0C0C0);
    _drawPointer(
      canvas,
      Offset(100, center),
      hoursAngle,
      radius * 0.6, // length
      4, // base width
      1, // tip width
      paint,
    );

    paint.color = Color(0xFFC0C0C0);
    _drawPointer(
      canvas,
      Offset(100, center),
      minutesAngle,
      radius * 0.92, // length
      4, // base width
      1, // tip width
      paint,
    );
    paint.color = Colors.orangeAccent;
    _drawPointer(
      canvas,
      Offset(100, center),
      secondsAngle,
      radius, // length
      2, // base width
      1.0, // tip width
      paint,
    );
  }

  void _drawDay(Canvas canvas, double center, double radius, Paint paint) {
    final now = DateTime.now();
    final dayAngle = (now.day) * (360 / 31);
    paint.color = Color(0xFFC0C0C0); // Color for the day pointer

    // Position the day pointer on the right
    final dayCenterX = center + radius * 0.48; // Shift to the right
    _drawPointer(
      canvas,
      Offset(dayCenterX, center),
      dayAngle,
      radius * 0.28, // length
      4, // base width
      1, // tip width
      paint,
    );
  }

  void _drawWeekday(Canvas canvas, double center, double radius, Paint paint) {
    final now = DateTime.now();
    final weekdayAngle = (now.weekday) * (360 / 7);
    paint.color = Color(0xFFC0C0C0); // Color for the weekday pointer

    // Position the weekday pointer on the left
    final weekdayCenterX = center - radius * 0.48; // Shift to the left
    _drawPointer(
      canvas,
      Offset(weekdayCenterX, center),
      weekdayAngle,
      radius * 0.28, // length
      4, // base width
      1, // tip width
      paint,
    );
  }

  void _drawPointer(
    Canvas canvas,
    Offset center,
    double angle,
    double length,
    double baseWidth,
    double tipWidth,
    Paint paint,
  ) {
    paint.style = PaintingStyle.fill;

    // Convert angle to radians and adjust for clock orientation
    final angleRad = (angle - 90) * pi / 180;

    // Calculate base points for the clock hand
    final leftBase = Offset(
      center.dx + (baseWidth / 2) * cos(angleRad + pi / 2),
      center.dy + (baseWidth / 2) * sin(angleRad + pi / 2),
    );
    final rightBase = Offset(
      center.dx + (baseWidth / 2) * cos(angleRad - pi / 2),
      center.dy + (baseWidth / 2) * sin(angleRad - pi / 2),
    );

    // Calculate side control points for a more pronounced curve
    final leftCurve = Offset(
      center.dx +
          (baseWidth * 2.5) * cos(angleRad + pi / 2.8), // Sharper inward angle
      center.dy + (baseWidth * 2.5) * sin(angleRad + pi / 2.8),
    );
    final rightCurve = Offset(
      center.dx +
          (baseWidth * 2.5) * cos(angleRad - pi / 2.8), // Sharper inward angle
      center.dy + (baseWidth * 2.5) * sin(angleRad - pi / 2.8),
    );

    // Calculate tip point
    final tipPoint = Offset(
      center.dx + length * cos(angleRad),
      center.dy + length * sin(angleRad),
    );

    // Create path for ace-like clock hand shape
    final path = Path()
      ..moveTo(leftBase.dx, leftBase.dy)
      ..quadraticBezierTo(leftCurve.dx, leftCurve.dy, tipPoint.dx, tipPoint.dy)
      ..quadraticBezierTo(
          rightCurve.dx, rightCurve.dy, rightBase.dx, rightBase.dy)
      ..close();

    // Draw the clock hand
    canvas.drawPath(path, paint);

    // Draw a circle at the pivot point
    paint.color;
    canvas.drawCircle(center, baseWidth * 2, paint);
    paint.color = Color(0xFF000000);
    canvas.drawCircle(center, baseWidth / 1.5, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
