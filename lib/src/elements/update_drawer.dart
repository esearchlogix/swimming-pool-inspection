import 'package:flutter/material.dart';

class ExpansionTileDrawer extends StatelessWidget {
  static final List<String> _listViewData = [
    "Inducesmile.com",
    "Flutter Dev",
    "Android Dev",

  ];

  List<ExpansionTile> _listOfExpansions = List<ExpansionTile>.generate(
      1,
          (i) => ExpansionTile(
        title: Text("Expansion $i"),
        children: _listViewData
            .map((data) => ListTile(
          leading: Icon(Icons.person),
          title: Text(data),
          subtitle: Text("a subtitle here"),
        ))
            .toList(),
      ));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("ExpansionTile in Drawer Example"),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.all(8.0),
          children:
          _listOfExpansions.map((expansionTile) => expansionTile).toList(),
        ),
      ),
      body: Center(
        child: Text('Main Body'),
      ),
    );
  }
}