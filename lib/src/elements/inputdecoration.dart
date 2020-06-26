  import 'package:flutter/material.dart';

InputDecoration buildInputDecoration(
      BuildContext context, String label, String hint) {
    return InputDecoration(

      enabledBorder: new UnderlineInputBorder(
        borderSide: BorderSide(
            color: Color(0xff222222)
        ),
      ),
// and:
      focusedBorder: new UnderlineInputBorder(
        borderSide: BorderSide(
            color: Color(0xff222222)
        ),
      ),
      // labelText: label,
      // labelStyle: TextStyle(fontSize: 15,color: Colors.blueGrey),
      contentPadding: EdgeInsets.all(8),
      hintText: hint,
      hintStyle:
          TextStyle(color: Theme.of(context).focusColor.withOpacity(0.7),),
    );
  }