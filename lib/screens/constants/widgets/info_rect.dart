// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class InfoRect extends StatelessWidget {
  final String title;
  final Color? color;
  final Color? textColor;
  final double height;
  final double borderRadius;
  const InfoRect({
    super.key,
    required this.title,
    this.color,
    this.textColor,
    this.height = 34,
    this.borderRadius = 10,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      constraints: const BoxConstraints(minWidth: 88),
      decoration: BoxDecoration(
        color: (color ?? Colors.white).withOpacity(.85),
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: Colors.white.withOpacity(.4), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.15),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Text(
          title,
          style: TextStyle(
            color: textColor ?? _bestOnColor(color ?? Colors.white),
            fontWeight: FontWeight.w600,
            fontSize: 12,
            letterSpacing: .5,
          ),
        ),
      ),
    );
  }

  Color _bestOnColor(Color bg) {
    return bg.computeLuminance() > .55 ? Colors.black : Colors.white;
  }
}
