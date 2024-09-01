import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

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
    _drawClockTicks(canvas, size, paint, center, radius);
    _drawMoonPhaseImage(
        canvas, size, center, radius); // Draw the moon phase image first
    _drawClockHands(
        canvas, size, paint, center, radius); // Draw the clock hands last
  }

  void _drawClockCircle(
      Canvas canvas, Size size, Paint paint, double center, double radius) {
    paint.strokeWidth = 2;
    paint.color = Colors.white;
    canvas.drawCircle(Offset(center, center), radius, paint);
  }

  void _drawClockTicks(
      Canvas canvas, Size size, Paint paint, double center, double radius) {
    paint.strokeWidth = 6;
    for (int i = 0; i < 12; i++) {
      final angle = i * pi / 6;
      _drawTick(canvas, paint, center, radius, angle, 0.9, 0.8);
    }

    paint.strokeWidth = 2;
    paint.color = Colors.white.withOpacity(0.6);
    for (int i = 0; i < 60; i++) {
      final angle = i * pi / 30;
      if (i % 5 != 0) {
        _drawTick(canvas, paint, center, radius, angle, 0.95, 0.9);
      }
    }
  }

  void _drawTick(Canvas canvas, Paint paint, double center, double radius,
      double angle, double startMultiplier, double endMultiplier) {
    final tickStartX = center + radius * startMultiplier * cos(angle - pi / 2);
    final tickStartY = center + radius * startMultiplier * sin(angle - pi / 2);
    final tickEndX = center + radius * endMultiplier * cos(angle - pi / 2);
    final tickEndY = center + radius * endMultiplier * sin(angle - pi / 2);
    canvas.drawLine(
      Offset(tickStartX, tickStartY),
      Offset(tickEndX, tickEndY),
      paint,
    );
  }

  void _drawClockHands(
      Canvas canvas, Size size, Paint paint, double center, double radius) {
    final now = DateTime.now();
    final secondsAngle = (now.second + now.millisecond / 1000) * 6.0;
    final minutesAngle = (now.minute + now.second / 60) * 6.0;
    final hoursAngle = (now.hour % 12 + now.minute / 60) * 30.0;

    paint.strokeWidth = 6;
    paint.color = Colors.white;
    _drawHand(canvas, paint, center, radius, hoursAngle, 0.5);

    paint.strokeWidth = 4;
    paint.color = Colors.white;
    _drawHand(canvas, paint, center, radius, minutesAngle, 0.7);

    paint.strokeWidth = 2;
    paint.color = Colors.orangeAccent;
    _drawHand(canvas, paint, center, radius, secondsAngle, 0.9);
  }

  void _drawHand(Canvas canvas, Paint paint, double center, double radius,
      double angle, double lengthMultiplier) {
    final endX =
        center + radius * lengthMultiplier * cos((angle - 90) * pi / 180);
    final endY =
        center + radius * lengthMultiplier * sin((angle - 90) * pi / 180);
    canvas.drawLine(
      Offset(center, center),
      Offset(endX, endY),
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
          center: Offset(center, center + radius * 0.5),
          width: radius * 0.3,
          height: radius * 0.3);

      canvas.drawImageRect(
        imageInfo.image,
        Rect.fromLTWH(0, 0, imageInfo.image.width.toDouble(),
            imageInfo.image.height.toDouble()),
        rect,
        Paint(),
      );
    }));
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
        return 'assets/full_moon.png';
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
