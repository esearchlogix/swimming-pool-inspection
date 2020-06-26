import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:poolinspection/res/string.dart';
import 'package:poolinspection/src/controllers/user_controller.dart';
import 'package:poolinspection/src/elements/BlockButtonWidget.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:poolinspection/config/app_config.dart' as config;
import 'package:poolinspection/src/helpers/connectivity.dart';

import 'package:poolinspection/src/repository/user_repository.dart' as userRepo;

class LoginWidget extends StatefulWidget {
  @override
  _LoginWidgetState createState() => _LoginWidgetState();
}

class _LoginWidgetState extends StateMVC<LoginWidget> {

  UserController _con;
  ConnectionStatusSingleton connectionStatus;
  final focus = FocusNode();

  _LoginWidgetState() : super(UserController()) {
    _con = controller;
  }


  @override
  void initState() {
    super.initState();

    connectionStatus = ConnectionStatusSingleton.getInstance();

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _con.scaffoldKey,
        resizeToAvoidBottomPadding: false,
        // body: buildStack(context),
        body: Padding(
          padding: const EdgeInsets.all(40.0),
          child: ListView(children: <Widget>[
            Container(
              height: config.App(context).appHeight(20),
              child: Image.asset("assets/img/logo.png"),
            ),
            Text(
              "Login",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w500,
                fontFamily: "AVENIRLTSTD",
              ).merge(TextStyle(
                  color: Color(0xff222222),
                  fontSize: 30,
                  fontWeight: FontWeight.w700)),
            ),
            Form(
              key: _con.loginFormKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  TextFormField(
                    style: TextStyle(fontSize: 20,
                      color: Color(0xff222222),
                      fontFamily: "AVENIRLTSTD",),
                    onFieldSubmitted: (v) {
                      FocusScope.of(context).requestFocus(focus);
                    },
                    keyboardType: TextInputType.emailAddress,
                    onSaved: (input) => _con.user.email = input,
                    validator: (input) =>
                    !input.contains('@')
                        ? 'Should be a valid email'
                        : null,
                    // validator: (input) => input.length < 3
                    //     ? 'Should be more than 3 characters'
                    //     : null,
                    decoration: InputDecoration(
                      enabledBorder: new UnderlineInputBorder(
                        borderSide: BorderSide(
                            color: Colors.black
                        ),
                      ),
// and:
                      focusedBorder: new UnderlineInputBorder(
                        borderSide: BorderSide(
                            color: Colors.black
                        ),
                      ),
                      labelText: "Email Address",
                      labelStyle: TextStyle(
                        fontSize: 20,
                        color: Color(0xff222222),
                        fontFamily: "AVENIRLTSTD",
                      ),
                      contentPadding: EdgeInsets.all(12),
                      hintText: 'Enter Email Address',
                      hintStyle: TextStyle(
                          color:
                          Theme
                              .of(context)
                              .focusColor
                              .withOpacity(0.7)),
                    ),
                  ),
                  SizedBox(height: 15),
                  TextFormField(
                    style: TextStyle(fontFamily: "AVENIRLTSTD", fontSize: 20,
                      color: Color(0xff222222),
                    ),
                    focusNode: focus,
                    keyboardType: TextInputType.text,
                    onSaved: (input) => _con.user.password = input,
                    validator: (input) =>
                    input.length < 3
                        ? 'Should be more than 3 characters'
                        : null,
                    obscureText: _con.hidePassword,
                    decoration: InputDecoration(
                      enabledBorder: new UnderlineInputBorder(
                        borderSide: BorderSide(
                            color: Colors.black
                        ),
                      ),
// and:
                      focusedBorder: new UnderlineInputBorder(
                        borderSide: BorderSide(
                            color: Colors.black
                        ),
                      ),
                      labelText: "Password",
                      labelStyle: TextStyle(
                        fontSize: 20,
                        color: Color(0xff222222),
                        fontFamily: "AVENIRLTSTD",
                      ),
                      contentPadding: EdgeInsets.all(12),
                      hintText: '••••••••••••',
                      hintStyle: TextStyle(
                          color:
                          Theme
                              .of(context)
                              .focusColor
                              .withOpacity(0.7)),
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            _con.hidePassword = !_con.hidePassword;
                          });
                        },
                        color: Theme
                            .of(context)
                            .focusColor,
                        icon: Icon(_con.hidePassword
                            ? Icons.visibility
                            : Icons.visibility_off),
                      ),
                    ),
                  ),
                  SizedBox(height: 15),
                  _con.loginLoader
                      ? SizedBox(
                      width: 15,
                      child: Center(child: CircularProgressIndicator()))
                      : BlockButtonWidget(
                    text: Text(
                      S.login,
                      style: TextStyle(
                        color: Theme
                            .of(context)
                            .primaryColor,
                        fontFamily: "AVENIRLTSTD",
                        fontSize: 20,
                      ),
                    ),
                    color: Theme
                        .of(context)
                        .accentColor,
                    onPressed: () {
                      _con.login(context);
//                      await connectionStatus.checkConnection()
//                          .then((val) {
//                        val ? :Fluttertoast.showToast(
//                            msg: "No Internet",
//                            toastLength: Toast.LENGTH_SHORT,
//                            gravity: ToastGravity.BOTTOM,
//                            timeInSecForIosWeb: 1,
//                            backgroundColor: Colors.red,
//                            textColor: Colors.white,
//                            fontSize: 16.0
//                        ); //val is false if not connected
//
//                      }
//                      );


                    },
                  ),
                  SizedBox(height: 30),
                  FlatButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/ForgetPassword');
//                      Navigator.of(context)
//                          .pushReplacementNamed('/ForgetPassword');
                    },
                    textColor: Theme
                        .of(context)
                        .hintColor,
                    child: Text(
                      "Forgot Password",
                      style: TextStyle(

                        fontSize: 18,
                        fontFamily: "AVENIRLTSTD",
                      ),
                    ),
                  ),
                  FlatButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/SignUp');
                      //  Navigator.pushNamedAndRemoveUntil(context,'/SignUp',(Route<dynamic> route) => false);

                    },
                    textColor: Theme
                        .of(context)
                        .hintColor,
                    child: Text(S.i_dont_have_an_account,
                        style: TextStyle(
                          fontFamily: "AVENIRLTSTD",
                          fontSize: 18,
                        )),
                  ),
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
