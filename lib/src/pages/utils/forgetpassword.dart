import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:poolinspection/res/string.dart';
import 'package:poolinspection/src/controllers/user_controller.dart';
import 'package:poolinspection/src/elements/BlockButtonWidget.dart';
import 'package:poolinspection/config/app_config.dart' as config;
import 'package:poolinspection/src/elements/inputdecoration.dart';

class ForgetPassword extends StatefulWidget {
  @override
  _ForgetPasswordState createState() => _ForgetPasswordState();
}

class _ForgetPasswordState extends StateMVC<ForgetPassword> {
  final textcontroller = TextEditingController();
  UserController _con;
  _ForgetPasswordState() : super(UserController()) {
    _con = controller;
  }
  @override
  Widget build(BuildContext context) {
    final _ac = config.App(context);
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Padding(
        padding: const EdgeInsets.all(40),
        child: ListView(
          // mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(height: 30),

           Icon(Icons.lock,size: 50,),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  "Forgot Your Password?",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.w500)
                      .merge(
                    TextStyle(color: Colors.black, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            // Text(
            //   'We are sending OTP to validate your email. Hang on!',
            //   style: Theme.of(context).textTheme.body1,
            //   textAlign: TextAlign.center,
            // ),
            SizedBox(height: 30),
            FormBuilder(
                key: _con.forgetPasswordKey,
                initialValue: {"email": "sumit@beedev.com.au"},
                autovalidate: true,
                child: FormBuilderTextField(
                  controller: textcontroller,
                  attribute: "email",
                  keyboardType: TextInputType.emailAddress,
                  // textInputAction: TextInputAction.send,
                  decoration: buildInputDecoration(
                      context, "Email Address", "john@gmail.com"),
                  validators: [
                    FormBuilderValidators.email(),
                    FormBuilderValidators.required()
                  ],
                )),
            SizedBox(height: 15),
            // Text(
            //   'Mail has been sent to poolinspection@gmail.com',
            //   style: Theme.of(context).textTheme.caption,
            //   textAlign: TextAlign.center,
            // ),
            SizedBox(height: 30),
            _con.forgetPassLoader
                ? SizedBox(
                    width: 15,
                    child: Center(child: CircularProgressIndicator()))
                : SizedBox(
                    width: MediaQuery.of(context).size.height * 1,
                    child: new BlockButtonWidget(
                      onPressed: () =>
                          _con.forgetPassword(context, textcontroller.text),
                      color: Theme.of(context).accentColor,
                      text: Text(S.send_mail.toUpperCase(),
                          style: Theme.of(context).textTheme.title.merge(
                              TextStyle(
                                  color: Theme.of(context).primaryColor))),
                    ),
                  ),
            SizedBox(height: 20),
            FlatButton(
              onPressed: () {
                Navigator.pop(context);
               // Navigator.of(context).pushReplacementNamed('/Login');
              },
              textColor: Theme.of(context).hintColor,
              child: Text(S.i_have_account_back_to_login),
            )
          ],
        ),
      ),
    );
  }
}
