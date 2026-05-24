import 'package:flutter/material.dart';

class StreaklyLogo extends StatelessWidget {
  final double size;
  const StreaklyLogo({super.key, this.size = 64});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(size * 0.28),
      child: Image.asset(
        'assets/icon/streakly_logo.png',
        width: size,
        height: size,
        fit: BoxFit.cover,
      ),
    );
  }
}
