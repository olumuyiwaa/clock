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
    String date = DateTime.now().day.toString();
    List<String> monthNames = [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec"
    ];

    String month = monthNames[DateTime.now().month - 1];
    List<String> weekdayNames = [
      "Mon",
      "Tues",
      "Weds",
      "Thus",
      "Fri",
      "Sat",
      "Sun"
    ];

    String weekday = weekdayNames[DateTime.now().weekday - 1];
    String day = '$weekday $date';

    _drawClockCircle(canvas, size, paint, center, radius);
    _drawClockTicks(canvas, size, paint, center, radius);
    _drawMoonPhaseImage(canvas, size, center, radius);
    _drawMonth(canvas, size, center, radius, month);
    _drawDay(
        canvas, size, center, radius, day); // Draw the moon phase image first
    _drawClockHands(
        canvas, size, paint, center, radius); // Draw the clock hands last
  }

  void _drawClockCircle(
      Canvas canvas, Size size, Paint paint, double center, double radius) {
    paint.strokeWidth = 2;
    paint.color = Color(0xFF2A292A);
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
    paint.color = Color(0xFF2A292A).withOpacity(0.6);
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
    paint.color = Color(0xFF2A292A);
    _drawHand(canvas, paint, center, radius, hoursAngle, 0.5);

    paint.strokeWidth = 4;
    paint.color = Color(0xFF2A292A);
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

    // Add a small circle at the center to enhance the appearance
    canvas.drawCircle(Offset(center, center), 2, paint);
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
          width: radius * 0.36,
          height: radius * 0.36);

      canvas.drawImageRect(
        imageInfo.image,
        Rect.fromLTWH(0, 0, imageInfo.image.width.toDouble(),
            imageInfo.image.height.toDouble()),
        rect,
        Paint(),
      );
    }));
  }

  void _drawDay(
      Canvas canvas, Size size, double center, double radius, String day) {
    // Create a TextSpan to represent the text you want to draw.
    final textSpan = TextSpan(
      text: day,
      style: TextStyle(
        color: Color(0xFF2A292A), // Set the color of the text
        fontSize: radius * 0.10, // Adjust the font size relative to the radius
        fontWeight: FontWeight.bold, // Set the font weight (optional)
      ),
    );

    // Use a TextPainter to layout and draw the text on the canvas.
    final textPainter = TextPainter(
      text: textSpan,
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    // Layout the text to determine its size
    textPainter.layout();

    // Calculate the position where you want to draw the text
    final offsetX = center * 1.9 - textPainter.width / 2;
    final offsetY = center * 0.19 + radius * 0.5 - textPainter.height / 2;
    final offset = Offset(offsetX, offsetY);

    // Define the rectangle that will serve as the frame
    final rect = Rect.fromCenter(
      center: Offset(
          offsetX + textPainter.width / 2, offsetY + textPainter.height / 2),
      width: textPainter.width + 12, // Adjust the width of the frame (padding)
      height:
          textPainter.height + 8, // Adjust the height of the frame (padding)
    );

    // Draw the blue background with rounded corners
    final paint = Paint()
      ..color = Colors.orangeAccent
      ..style = PaintingStyle.fill;

    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, Radius.circular(4)), // Border radius of 4
      paint,
    );

    // Draw the text on top of the background
    textPainter.paint(canvas, offset);
  }

  void _drawMonth(
      Canvas canvas, Size size, double center, double radius, String month) {
    // Create a TextSpan to represent the text you want to draw.
    final textSpan = TextSpan(
      text: month,
      style: TextStyle(
        color: Color(0xFF2A292A), // Set the color of the text
        fontSize: radius * 0.10, // Adjust the font size relative to the radius
        fontWeight: FontWeight.bold, // Set the font weight (optional)
      ),
    );

    // Use a TextPainter to layout and draw the text on the canvas.
    final textPainter = TextPainter(
      text: textSpan,
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    // Layout the text to determine its size
    textPainter.layout();

    // Calculate the position where you want to draw the text
    final offsetX = center * 0.2 - textPainter.width / 2;
    final offsetY = center * 0.19 + radius * 0.5 - textPainter.height / 2;
    final offset = Offset(offsetX, offsetY);

    // Define the rectangle that will serve as the frame
    final rect = Rect.fromCenter(
      center: Offset(
          offsetX + textPainter.width / 2, offsetY + textPainter.height / 2),
      width: textPainter.width + 12, // Adjust the width of the frame (padding)
      height:
          textPainter.height + 8, // Adjust the height of the frame (padding)
    );

    // Draw the blue background with rounded corners
    final paint = Paint()
      ..color = Colors.orangeAccent
      ..style = PaintingStyle.fill;

    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, Radius.circular(4)), // Border radius of 4
      paint,
    );

    // Draw the text on top of the background
    textPainter.paint(canvas, offset);
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
