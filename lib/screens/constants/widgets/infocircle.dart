import 'package:flutter/material.dart';

class InfoCircle extends StatelessWidget {
  final bool active;
  final String day;
  final Color? boxColor;
  final Color? textColor;
  const InfoCircle({
    super.key,
    required this.active,
    required this.day,
    required this.boxColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    
    return Container(
      height: 70,
      width: 70,
      decoration: BoxDecoration(
        color: active ? Colors.pink[500] : Colors.grey[300],
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(day,
            style: TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.bold,
              color: active ? Colors.white : Colors.black,
            )),
      ),
    );
  }
}
