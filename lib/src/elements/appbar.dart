import 'package:flutter/material.dart';

Widget appBar(BuildContext context) {
  return AppBar(
    title: Text("BEEDEV"),
    actions: <Widget>[
      IconButton(icon: Icon(Icons.search), onPressed: () => print("Search")),
      IconButton(
          icon: Icon(Icons.settings),
          onPressed: () => Navigator.of(context).pushNamed('/Setting')),
  
    ],
  );
}
