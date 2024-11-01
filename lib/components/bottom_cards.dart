import 'package:flutter/material.dart';

class BottomCards extends StatelessWidget {
  final String? lastMonth;
  final String? lastDay;
  final String? nextMonth;
  final String? nextDay;
  final String? lastTitle;
  final String? nextTitle;
  final String icon;

  const BottomCards(
      {super.key,
      this.lastTitle,
      this.nextTitle,
      required this.icon,
      this.lastMonth,
      this.lastDay,
      this.nextMonth,
      this.nextDay});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Image(
          height: 48,
          width: 48,
          image: AssetImage('assets/$icon'),
        ),
        SizedBox(height: 8),
        Row(
          children: [
            Column(
              children: [
                Text(
                  lastMonth!,
                  style: TextStyle(color: Color(0xFF2A292A), fontSize: 14),
                ),
                Text(
                  lastDay!,
                  style: TextStyle(color: Color(0xFF2A292A), fontSize: 14),
                ),
                Text(
                  lastTitle!,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Color(0xFF2A292A), fontSize: 12),
                ),
              ],
            ),
            SizedBox(
              width: 8,
            ),
            Column(
              children: [
                Text(
                  nextMonth!,
                  style: TextStyle(color: Color(0XFFA2811A), fontSize: 14),
                ),
                Text(
                  nextDay!,
                  style: TextStyle(color: Color(0XFFA2811A), fontSize: 14),
                ),
                Text(
                  nextTitle!,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Color(0XFFA2811A), fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
