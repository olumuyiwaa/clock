import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

class AnalogClock extends StatefulWidget {
  final int moonPhase;

  const AnalogClock({super.key, required this.moonPhase});

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
          painter: ClockPainter(moonPhase: widget.moonPhase),
        ));
  }
}

class ClockPainter extends CustomPainter {
  final int moonPhase;

  ClockPainter({required this.moonPhase});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final center = size.width / 2;
    final radius = min(size.width / 1.2, size.height / 1.2);

    _drawClockCircle(canvas, size, paint, center, radius);
    _drawMoonPhaseImage(canvas, size, center, radius);
    _drawWeekday(canvas, center, radius, paint);
    _drawDay(canvas, center, radius, paint);
    _drawClockHands(canvas, size, paint, center, radius);
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
    paint.color = Color(0xFF2A292A);
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
      8, // base width
      1, // tip width
      paint,
    );

    paint.color = Color(0xFFC0C0C0);
    _drawPointer(
      canvas,
      Offset(100, center),
      minutesAngle,
      radius * 0.92, // length
      8, // base width
      1, // tip width
      paint,
    );
    paint.color = Colors.orangeAccent;
    _drawPointer(
      canvas,
      Offset(100, center),
      secondsAngle,
      radius, // length
      4, // base width
      1.0, // tip width
      paint,
    );
  }

  void _drawMoonPhaseImage(
      Canvas canvas, Size size, double center, double radius) {
    final moonImagePath = _getMoonImagePath();
    final image = AssetImage(moonImagePath);

    final imageStream = image.resolve(ImageConfiguration.empty);
    imageStream.addListener(
        ImageStreamListener((ImageInfo imageInfo, bool synchronousCall) {
      final Rect rect = Rect.fromCenter(
          center: Offset(center, center + radius * 0.26),
          width: radius * 0.32,
          height: radius * 0.32);

      canvas.drawImageRect(
        imageInfo.image,
        Rect.fromLTWH(0, 0, imageInfo.image.width.toDouble(),
            imageInfo.image.height.toDouble()),
        rect,
        Paint(),
      );
    }));
  }

  void _drawDay(Canvas canvas, double center, double radius, Paint paint) {
    final now = DateTime.now();
    final dayAngle = (now.day) * (360 / 31);
    paint.color = Color(0xFF888989); // Color for the day pointer

    // Position the day pointer on the right
    final dayCenterX = center + radius * 0.48; // Shift to the right
    _drawPointer(
      canvas,
      Offset(dayCenterX, center),
      dayAngle,
      radius * 0.28, // length
      8, // base width
      1, // tip width
      paint,
    );
  }

  void _drawWeekday(Canvas canvas, double center, double radius, Paint paint) {
    final now = DateTime.now();
    final weekdayAngle = (now.weekday) * (360 / 7);
    paint.color = Color(0xFF888989); // Color for the weekday pointer

    // Position the weekday pointer on the left
    final weekdayCenterX = center - radius * 0.48; // Shift to the left
    _drawPointer(
      canvas,
      Offset(weekdayCenterX, center),
      weekdayAngle,
      radius * 0.28, // length
      8, // base width
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

    // Calculate the points for the clock hand shape
    final point1 = Offset(
      center.dx + (baseWidth / 2) * cos(angleRad + pi / 2),
      center.dy + (baseWidth / 2) * sin(angleRad + pi / 2),
    );

    final point2 = Offset(
      center.dx + (baseWidth / 2) * cos(angleRad - pi / 2),
      center.dy + (baseWidth / 2) * sin(angleRad - pi / 2),
    );

    final tipPoint = Offset(
      center.dx + length * cos(angleRad),
      center.dy + length * sin(angleRad),
    );

    // Create a path for the tapered clock hand
    final path = Path()
      ..moveTo(point1.dx, point1.dy)
      ..lineTo(point2.dx, point2.dy)
      ..lineTo(tipPoint.dx, tipPoint.dy)
      ..close();

    // Draw the clock hand
    canvas.drawPath(path, paint);

    // Draw a circle at the pivot point
    paint.color = paint.color.withOpacity(0.8);
    canvas.drawCircle(center, baseWidth * 0.8, paint);
  }

  String _getMoonImagePath() {
    switch (moonPhase) {
      case 0:
        return 'assets/new_moon1.png';
      case 1:
        return 'assets/waxing_crescent.png';
      case 2:
        return 'assets/first_quarter.png';
      case 3:
        return 'assets/waxing_gibbous.png';
      case 4:
        return 'assets/full_moon1.png';
      case 5:
        return 'assets/waning_gibbous.png';
      case 6:
        return 'assets/last_quarter.png';
      case 7:
        return 'assets/waning_crescent.png';
      default:
        return 'assets/new_moon1.png';
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
