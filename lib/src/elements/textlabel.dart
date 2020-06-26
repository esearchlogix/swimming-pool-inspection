import 'package:flutter/material.dart';

textLabel(String text) {
  return Row(
    children: <Widget>[
      Text(text,
          textAlign: TextAlign.left,
          style: TextStyle(
              fontFamily: "AVENIRLTSTD",
              fontSize: 19,
              color: Color(0xff222222),
              fontWeight: FontWeight.w700)),
    ],
  );
}

textCenterLabel(String text) {
  return Text(text,
      textAlign: TextAlign.center,
      style: TextStyle(
          fontSize: 20, color: Colors.blueGrey, fontWeight: FontWeight.bold));
}
