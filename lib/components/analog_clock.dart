import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AnalogClock extends StatefulWidget {
  const AnalogClock({super.key});

  @override
  _AnalogClockState createState() => _AnalogClockState();
}

class _AnalogClockState extends State<AnalogClock> {
  late ui.Image hourHandImage;
  late ui.Image minuteHandImage;
  late ui.Image monthHandImage;
  late ui.Image dayPointerImage;
  late ui.Image dotImage;

  @override
  void initState() {
    super.initState();
    _loadImages();
    Timer.periodic(const Duration(milliseconds: 1000), (_) => setState(() {}));
  }

  // Load the images asynchronously
  Future<void> _loadImages() async {
    final minuteImage = await loadImage('assets/minute_hand.png');
    final hourImage = await loadImage('assets/hour_hand.png');
    final dayPointerImage = await loadImage('assets/day_pointer.png');
    final monthPointerImage = await loadImage('assets/month_pointer.png');
    final dotImage = await loadImage('assets/dot.png');

    setState(() {
      hourHandImage = hourImage;
      minuteHandImage = minuteImage;
      monthHandImage = monthPointerImage;
      this.dayPointerImage = dayPointerImage;
      this.dotImage = dotImage;
    });
  }

  Future<ui.Image> loadImage(String path) async {
    final ByteData data = await rootBundle.load(path);
    final List<int> bytes = data.buffer.asUint8List();
    final image = await decodeImageFromList(Uint8List.fromList(bytes));
    return image;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 48),
      alignment: Alignment.center,
      height: 320,
      child: CustomPaint(
        size: const Size(200, 200),
        painter: ClockPainter(
            hourHandImage, // Pass hour image
            minuteHandImage, // Pass minute image
            dayPointerImage,
            monthHandImage,
            dotImage // Pass day pointer image
            ),
      ),
    );
  }

  @override
  void dispose() {
    hourHandImage.dispose();
    minuteHandImage.dispose();
    monthHandImage.dispose();
    dayPointerImage.dispose();
    dotImage.dispose();
    super.dispose();
  }
}

class ClockPainter extends CustomPainter {
  final ui.Image hourHandImage; // Hour hand image
  final ui.Image minuteHandImage; // Minute hand image
  final ui.Image dayPointerImage;
  final ui.Image monthHandImage;
  final ui.Image dotImage;

  ClockPainter(this.hourHandImage, this.minuteHandImage, this.dayPointerImage,
      this.monthHandImage, this.dotImage);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final center = size.width / 2;
    final radius = min(size.width / 1.2, size.height / 1.2);

    _drawWatchFace(canvas, size, paint, center, radius);
    // _drawMonthIndicator(canvas, center, radius, paint);
    _drawWeekday(canvas, center, radius, paint);
    _drawDay(canvas, center, radius, paint);
    _drawClockHands(canvas, size, paint, center, radius);
    _drawCenterDot(canvas, center);
  }

  void _drawCenterDot(Canvas canvas, double center) {
    final paintForImage = Paint();

    // Calculate the position for the image (center of the clock)
    final imageCenter = Offset(center, center);

    // Scale the image if needed (optional)
    final scaleFactor = .32;
    final scaledWidth = dotImage.width * scaleFactor;
    final scaledHeight = dotImage.height * scaleFactor;

    // Rotate and draw the image at the center
    canvas.save();
    canvas.translate(imageCenter.dx, imageCenter.dy);
    canvas.scale(scaleFactor);

    // Draw the dot image centered at the origin (center of the clock)
    canvas.drawImage(
      dotImage,
      Offset(-scaledWidth * 1.5, -scaledHeight * 1.5),
      paintForImage,
    );

    canvas.restore();
  }

  // void _drawMonthIndicator(
  //     Canvas canvas, double center, double radius, Paint paint) {
  //   final now = DateTime.now();
  //   // Calculate the angle for the current month
  //   final monthAngle = (now.month - 3) * (360 / 12);
  //
  //   final indicatorLength = radius * 0.75;
  //   final arcRadius = 10.0;
  //
  //   final arcCenter = Offset(
  //     center + indicatorLength * cos(monthAngle * pi / 180),
  //     center + indicatorLength * sin(monthAngle * pi / 180),
  //   );
  //
  //   final rect = Rect.fromCircle(center: arcCenter, radius: arcRadius);
  //
  //   // Draw the arc
  //   paint.color = Colors.red;
  //   paint.strokeWidth = 6.0;
  //   paint.style = PaintingStyle.stroke;
  //
  //   final sweepAngle = pi / 5;
  //
  //   // Draw the arc
  //   canvas.drawArc(
  //       rect, (monthAngle - 15) * pi / 180, sweepAngle, false, paint);
  // }

  void _drawWatchFace(
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
  }

  void _drawClockHands(
      Canvas canvas, Size size, Paint paint, double center, double radius) {
    final now = DateTime.now();
    final monthAngle = (now.month) * (360 / 12);
    //  final secondsAngle = (now.second + now.millisecond / 1000) * 6.0;
    final minutesAngle = (now.minute + now.second / 60) * 6.0;
    final hoursAngle = (now.hour % 12 + now.minute / 60) * 30.0;

    // Draw hour hand using hourHandImage
    _drawHand(
      canvas,
      Offset(center, center),
      monthAngle,
      radius * 0.42, // Length
      2.8, // Base width
      monthHandImage,
    );
    _drawHand(
      canvas,
      Offset(center, center),
      hoursAngle,
      radius * 0.42, // Length
      2.8, // Base width
      hourHandImage, // Pass the hour hand image
    );

    // Draw minute hand using minuteHandImage
    _drawHand(
      canvas,
      Offset(center, center),
      minutesAngle,
      radius * 0.42, // Length
      2.8, // Base width
      minuteHandImage, // Pass the minute hand image
    );

    // // Draw second hand (same as before)
    // _drawSecondsPointer(
    //   canvas,
    //   Offset(center, center),
    //   secondsAngle,
    //   radius * 0.8, // Length
    //   2.4, // Base width
    //   paint,
    // );
  }

  void _drawHand(
    Canvas canvas,
    Offset center,
    double angle,
    double length,
    double baseWidth,
    ui.Image handImage, // Image for the hand
  ) {
    final angleRad = (angle - 90) * pi / 180;

    // Calculate the position for the image
    final imageCenter = Offset(
      center.dx + (length - handImage.height / 2) * cos(angleRad),
      center.dy + (length - handImage.height / 2) * sin(angleRad),
    );

    final paintForImage = Paint();

    // Scale the image if needed (optional)
    final scaleFactor = 1.0;
    final scaledWidth = handImage.width * scaleFactor;
    final scaledHeight = handImage.height * scaleFactor;

    // Rotate and draw the image at the calculated position
    canvas.save();
    canvas.translate(imageCenter.dx, imageCenter.dy);
    canvas.rotate(angleRad);
    canvas.scale(scaleFactor);

    canvas.drawImage(
      handImage,
      Offset(-scaledWidth / 2, -scaledHeight / 2),
      paintForImage,
    );

    canvas.restore();
  }

  // void _drawSecondsPointer(
  //   Canvas canvas,
  //   Offset center,
  //   double angle,
  //   double length,
  //   double baseWidth,
  //   Paint paint,
  // ) {
  //   paint.style = PaintingStyle.stroke;
  //   paint.strokeWidth = baseWidth;
  //   paint.color = Color(0xFFC0C0C0);
  //
  //   // Convert angle to radians and adjust for clock orientation
  //   final angleRad = (angle - 90) * pi / 180;
  //
  //   // Calculate the tip of the line
  //   final tipPoint = Offset(
  //     center.dx + length * cos(angleRad),
  //     center.dy + length * sin(angleRad),
  //   );
  //
  //   // Draw a line from the center to the tip for a straight seconds hand
  //   canvas.drawLine(center, tipPoint, paint);
  //
  //   // Draw a circle at the pivot point
  //   paint.color = Color(0xFFC0C0C0);
  //   canvas.drawCircle(center, baseWidth * 2, paint);
  //   paint.color = Color(0xFF000000);
  //   canvas.drawCircle(center, baseWidth / 1.5, paint);
  // }

  void _drawDay(Canvas canvas, double center, double radius, Paint paint) {
    final now = DateTime.now();
    final dayAngle = (now.day) * (360 / 31);
    final dayCenterX = center + radius * 0.48; // Shift to the right
    // Use the day pointer image
    _drawDatePointer(
      canvas,
      Offset(dayCenterX, center),
      dayAngle,
      radius * 0.28, // Length
      4, // Base width
      dayPointerImage, // Pass the day pointer image
    );
  }

  void _drawWeekday(Canvas canvas, double center, double radius, Paint paint) {
    final now = DateTime.now();
    final weekdayAngle = (now.weekday) * (360 / 7);
    final weekdayCenterX = center - radius * 0.48; // Shift to the left
    // Use the weekday pointer image
    _drawWeekdayPointer(
      canvas,
      Offset(weekdayCenterX, center),
      weekdayAngle,
      radius * 0.28, // Length
      4, // Base width
      dayPointerImage, // Pass the weekday pointer image
    );
  }

  void _drawWeekdayPointer(
    Canvas canvas,
    Offset center,
    double angle,
    double length,
    double baseWidth,
    ui.Image pointerImage, // Image for the pointer
  ) {
    final angleRad = (angle - 90) * pi / 180;

    // Calculate the position for the image
    final imageCenter = Offset(
      center.dx + (length - pointerImage.height / 2) * cos(angleRad),
      center.dy + (length - pointerImage.height / 2) * sin(angleRad),
    );

    // Scale the image if needed (optional)
    final scaleFactor = 1.0;
    final scaledWidth = pointerImage.width * scaleFactor;
    final scaledHeight = pointerImage.height * scaleFactor;

    final paintForImage = Paint();

    // Rotate and draw the image at the calculated position
    canvas.save();
    canvas.translate(imageCenter.dx, imageCenter.dy);
    canvas.rotate(angleRad);
    canvas.scale(scaleFactor);

    // Draw the image centered on the calculated position
    canvas.drawImage(
      pointerImage,
      Offset(-scaledWidth / 2, -scaledHeight / 2),
      paintForImage,
    );

    canvas.restore();
  }

  void _drawDatePointer(
    Canvas canvas,
    Offset center,
    double angle,
    double length,
    double baseWidth,
    ui.Image pointerImage, // Image for the pointer
  ) {
    final angleRad = (angle - 90) * pi / 180;

    // Calculate the position for the image
    final imageCenter = Offset(
      center.dx + (length - pointerImage.height / 2) * cos(angleRad),
      center.dy + (length - pointerImage.height / 2) * sin(angleRad),
    );

    // Scale the image if needed (optional)
    final scaleFactor = 1.0;
    final scaledWidth = pointerImage.width * scaleFactor;
    final scaledHeight = pointerImage.height * scaleFactor;

    final paintForImage = Paint();

    // Rotate and draw the image at the calculated position
    canvas.save();
    canvas.translate(imageCenter.dx, imageCenter.dy);
    canvas.rotate(angleRad);
    canvas.scale(scaleFactor);

    // Draw the image centered on the calculated position
    canvas.drawImage(
      pointerImage,
      Offset(-scaledWidth / 2, -scaledHeight / 2),
      paintForImage,
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
