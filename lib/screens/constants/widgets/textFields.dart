import 'package:flutter/material.dart';

Widget CustomTextField({
  required TextEditingController controller,
  required String hintText,
  required String labelText,
  required TextInputType keyboardType,
  bool obscureText = false,
}) =>
    Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color.fromARGB(255, 234, 231, 231),
        ),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        decoration: InputDecoration(
          hintText: hintText,
          labelText: labelText,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(
              color: Color.fromARGB(255, 234, 231, 231),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              color: Colors.pink[900]!,
            ),
          ),
          hintStyle: const TextStyle(
            color: Colors.black,
            fontSize: 14,
          ),
        ),
      ),
    );
