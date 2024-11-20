import 'package:flutter/material.dart';

class MoonCard extends StatelessWidget {
  final String icon;

  const MoonCard({
    super.key,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Image(
          height: 52,
          width: 52,
          image: AssetImage('assets/$icon'),
        ),
        SizedBox(height: 8),
        Text(
          'Current Phase',
          style: TextStyle(
            letterSpacing: -.4,
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0XFFA2811A),
          ),
        ),
      ],
    );
  }
}
