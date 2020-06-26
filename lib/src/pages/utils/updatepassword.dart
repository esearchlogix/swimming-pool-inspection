import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:poolinspection/res/string.dart';
import 'package:poolinspection/src/elements/BlockButtonWidget.dart';
import 'package:poolinspection/src/repository/user_repository.dart' as userRepo;
import 'package:poolinspection/config/app_config.dart' as config;
import 'package:poolinspection/src/controllers/user_controller.dart';

class UpdatePasswordWidget extends StatefulWidget {
  @override
  _UpdatePasswordWidgetState createState() => _UpdatePasswordWidgetState();
}

class _UpdatePasswordWidgetState extends StateMVC<UpdatePasswordWidget> {
  final focus = FocusNode();

  UserController _con;
  _UpdatePasswordWidgetState() : super(UserController()) {
    _con = controller;
  }
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _con.scaffoldKey,
        body: Padding(
          padding: const EdgeInsets.all(40.0),
          child: ListView(children: <Widget>[
            Container(
              height: config.App(context).appHeight(20),
              child: Image.asset("assets/img/logo.png"),
            ),
            Text(
              S.updatepassword,
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.w500).merge(
                  TextStyle(color: Colors.black, fontWeight: FontWeight.w700)),
            ),
            SizedBox(height: 20),

            Form(
              key: _con.updatePasswordKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  TextFormField(
                    onFieldSubmitted: (v) {
                      FocusScope.of(context).requestFocus(focus);
                    },
                    keyboardType: TextInputType.text,
                    onSaved: (input) => _con.user.password = input,
                    validator: (input) => input.length < 3
                        ? 'Should be more than 3 characters'
                        : null,
                    obscureText: _con.hidePassword,
                    decoration: InputDecoration(
                      labelText: "old password",
                      labelStyle: TextStyle(color: Colors.blueGrey),
                      contentPadding: EdgeInsets.all(12),
                      hintText: '••••••••••••',
                      hintStyle: TextStyle(
                          color: Theme.of(context).focusColor.withOpacity(0.7)),
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            _con.hidePassword = !_con.hidePassword;
                          });
                        },
                        color: Theme.of(context).focusColor,
                        icon: Icon(_con.hidePassword
                            ? Icons.visibility
                            : Icons.visibility_off),
                      ),
                    ),
                  ),
                  SizedBox(height: 15),
                  TextFormField(
                    onFieldSubmitted: (v) {
                      FocusScope.of(context).requestFocus(focus);
                    },
                    focusNode: focus,
                    keyboardType: TextInputType.text,
                    onSaved: (input) => _con.user.confirmPassword = input,
                    validator: (input) => input.length < 3
                        ? 'Should be more than 3 characters'
                        : null,
                    obscureText: _con.hidePassword,
                    decoration: InputDecoration(
                      labelText: "new password",
                      labelStyle: TextStyle(color: Colors.blueGrey),
                      contentPadding: EdgeInsets.all(12),
                      hintText: '••••••••••••',
                      hintStyle: TextStyle(
                          color: Theme.of(context).focusColor.withOpacity(0.7)),
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            _con.hidePassword = !_con.hidePassword;
                          });
                        },
                        color: Theme.of(context).focusColor,
                        icon: Icon(_con.hidePassword
                            ? Icons.visibility
                            : Icons.visibility_off),
                      ),
                    ),
                  ),
                  SizedBox(height: 15),
                  BlockButtonWidget(
                      text: Text(
                        S.updatepassword,
                        style: TextStyle(color: Theme.of(context).primaryColor),
                      ),
                      color: Theme.of(context).accentColor,
                      onPressed: () => _con.updatePassword(context)
                      // print(_con.user.password);
                      // },
                      ),
                  SizedBox(height: 30),
                  // FlatButton(
                  //   onPressed: () {
                  //     Navigator.of(context)
                  //         .pushReplacementNamed('/ForgetPassword');
                  //   },
                  //   textColor: Theme.of(context).hintColor,
                  //   child: Text(S.i_forgot_password),
                  // ),
                  // FlatButton(
                  //   onPressed: () {
                  //     Navigator.of(context).pushReplacementNamed('/SignUp');
                  //   },
                  //   textColor: Theme.of(context).hintColor,
                  //   child: Text(S.i_dont_have_an_account),
                  // ),
                ],
              ),
            ),
            // SizedBox(height: 30),

            // SizedBox(
            //     height: config.App(context).appHorizontalPadding(20)),
            // Row(
            //   children: <Widget>[
            //     Text(
            //       "@ 2020 Pool Inspection",
            //       style:
            //           TextStyle(fontSize: 16, fontWeight: FontWeight.w500)
            //               .merge(TextStyle(
            //                   color: Colors.grey,
            //                   fontWeight: FontWeight.w700)),
            //     ),
            //   ],
            // )
          ]),
        ));
  }
}
