import 'package:flutter/material.dart';

class AppStyles {
  static const TextStyle titleText = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: Colors.black,
  );

  static const TextStyle subtitleText = TextStyle(
    fontSize: 16,
    color: Colors.grey,
  );

  static InputDecoration inputDecoration(String hintText) {
    return InputDecoration(
      hintText: hintText,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide.none,
      ),
    );
  }

  static const BoxDecoration buttonDecoration = BoxDecoration(
    color: Colors.black,
    borderRadius: BorderRadius.all(Radius.circular(8.0)),
    boxShadow: [
      BoxShadow(
        color: Colors.black26,
        blurRadius: 4.0,
        offset: Offset(0, 2),
      ),
    ],
  );

  static const EdgeInsets buttonPadding = EdgeInsets.symmetric(vertical: 16.0);
  static const EdgeInsets resultAreaPadding = EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0);

  static const BoxDecoration resultAreaDecoration = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.all(Radius.circular(8.0)),
    boxShadow: [
      BoxShadow(
        color: Colors.black26,
        blurRadius: 4.0,
        offset: Offset(0, 2),
      ),
    ],
  );
}
