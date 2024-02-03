import 'package:flutter/material.dart';

class InfoCircle extends StatelessWidget {
  final bool active;
  final String day;
  const InfoCircle({super.key, required this.active, required this.day});

  @override
  Widget build(BuildContext context) {
    print(day);
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
