import 'dart:convert';
import 'dart:io';

import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:poolinspection/src/helpers/sharedpreferences/userpreferences.dart';
import 'package:poolinspection/src/models/route_argument.dart';
import 'package:poolinspection/src/models/signupfields.dart';
import 'package:poolinspection/src/models/user.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:poolinspection/src/repository/user_repository.dart'
    as repository;
import 'package:http/http.dart' as http;

final String apiToken = 'beedev';

class UserController extends ControllerMVC {
  bool loginLoader = false;
  bool forgetPassLoader = false;
  bool autoValidate = false;
  bool signupLoader = false;
  User user;
  int groupValue = 0;
  bool hidePassword = true;
  File logoImage;
  File signatureImage;
  File photoImage;
  GlobalKey<FormState> loginFormKey;
  GlobalKey<FormState> otpFormKey;
  GlobalKey<FormBuilderState> signUpKey;
  GlobalKey<FormBuilderState> forgetPasswordKey;
  GlobalKey<FormState> updatePasswordKey;

  GlobalKey<ScaffoldState> scaffoldKey;

  UserController() {
    updatePasswordKey = new GlobalKey<FormState>();
    loginFormKey = new GlobalKey<FormState>();
    otpFormKey = new GlobalKey<FormState>();
    signUpKey = GlobalKey<FormBuilderState>();
    forgetPasswordKey = GlobalKey<FormBuilderState>();
    this.scaffoldKey = new GlobalKey<ScaffoldState>();
    user = new User();
    // fetchData();
  }

  void login(BuildContext context) async {
    if (loginFormKey.currentState.validate()) {
      loginFormKey.currentState.save();
      setState(() => loginLoader = true);

      repository.login(user).then((value) {

       if(value==null)
         {
           setState(() => loginLoader = false);
           // scaffoldKey.currentState.showSnackBar(SnackBar(
           //   content: Text('Wrong email or password'),
           // ));
//           Fluttertoast.showToast(
//               msg: "No Internet",
//               toastLength: Toast.LENGTH_SHORT,
//               gravity: ToastGravity.BOTTOM,
//               timeInSecForIosWeb: 1,
//               backgroundColor: Colors.red,
//               textColor: Colors.white,
//               fontSize: 16.0
//           );
         }
        // print("$value  erererere");
       else if (value['errors'] == "1") {
          setState(() => loginLoader = false);
          // scaffoldKey.currentState.showSnackBar(SnackBar(
          //   content: Text('Wrong email or password'),
          // ));
          Flushbar(
            title: "Access Denied",
            message: "Wrong email or password",
            duration: Duration(seconds: 3),
          )..show(context);
          //   Navigator.of(scaffoldKey.currentContext)
          //       .pushReplacementNamed('/OtpVerification');
        } else if (value['errors'] == "2") {
          setState(() => loginLoader = false);
          Flushbar(
            title: "Access Denied",
            message: "Activation pending from Administrator",
            duration: Duration(seconds: 3),
          )..show(context);
          // scaffoldKey.currentState.showSnackBar(SnackBar(
          //     content: Text('Activation pending from Administrator ')));
        } else if (value['errors'] == "0" &&
                value['userdata']['user']['roles_manage'] == 2 ||
            value['userdata']['user']['roles_manage'] == 3) {
          setState(() => loginLoader = false);
          Flushbar(
            title: "Access Denied",
            message: "Only Inspectors can login",
            duration: Duration(seconds: 3),
          )..show(context);
          // scaffoldKey.currentState.showSnackBar(
          //     SnackBar(content: Text('Only Inspectors can login')));
        } else {
          repository.currentUser = UserModel.fromJSON(value);
          UserSharedPreferencesHelper.setUserdetails(json.encode(value));
          repository.inspector = repository.currentUser.userdata.inspector;
          repository.company = repository.currentUser.userdata.company;
          repository.user = repository.currentUser.userdata.user;

          // if (value.userdata.company != null) {
          //   if (value.userdata.user.status == 1 &&
          //       value.userdata.user.isPasswordApproved == 1 &&
          //       value.userdata.user.isPasswordChange == 1) {
          //     Navigator.of(scaffoldKey.currentContext).pushReplacementNamed(
          //         '/Home',
          //         arguments: RouteArgumentHome(
          //             id: value.userdata.user.id,
          //             role: value.userdata.user.rolesManage));
          //     flushbar(value, context, "Welcome Company");
          //   } else {
          //     Navigator.of(scaffoldKey.currentContext)
          //         .pushReplacementNamed('/UpdatePassword');
          //   }
          // } else {
          // if (value['userdata']['user']['status'] == 1 &&
          //     value['userdata']['user']['isPasswordApproved'] == 1 &&
          //     value['userdata']['user']['isPasswordChange'] == 1) {

          Navigator.of(scaffoldKey.currentContext).pushReplacementNamed('/Home',
              arguments: RouteArgumentHome(
                  id: value['userdata']['user']['id'],
                  role: value['userdata']['user']['rolesManage']));
          //Navigator.pushNamedAndRemoveUntil(context,'/Home',(Route<dynamic> route) => false);


          flushbar(value, context, "Welcome Inspector");


          // } else {
          //   Navigator.of(scaffoldKey.currentContext)
          //       .pushReplacementNamed('/UpdatePassword');
          //   Flushbar(
          //     title: "Password Reset",
          //     message: "New Password to be Set",
          //     duration: Duration(seconds: 3),
          //   )..show(context);
          // }
        }
        // }
        // print(value.userdata);
      });
    }
  }

  Flushbar<Object> flushbar(dynamic value, BuildContext context, String title) {
    return Flushbar(
      title: title,
      message: value['userdata']['company'] != null
          ? "${value['userdata']['company']['companyName']}!"
          : "${value['userdata']['inspector']['first_name']}!",
      duration: Duration(seconds: 3),
    )..show(context);
  }

  void updatePassword(BuildContext context) async {
    if (updatePasswordKey.currentState.validate()) {
      updatePasswordKey.currentState.save();
      print(user.confirmPassword);
      print(user.password);
      print(user.id);
      repository.updatePassword(user).then((val) {
        if (val.error == 0) {
          Navigator.of(context).pushNamedAndRemoveUntil(
              '/Home', (Route<dynamic> route) => false);
          Flushbar(
            title: "Status ${val.status}",
            message: val.messages,
            duration: Duration(seconds: 3),
          )..show(context);
        } else {
          Flushbar(
            title: "Status ${val.status}",
            message: val.messages,
            duration: Duration(seconds: 3),
          )..show(context);
        }
      });
    }
  }

  void forgetPassword(BuildContext context, String text) {
    print(text);
    if (forgetPasswordKey.currentState.saveAndValidate()) {
      setState(() => forgetPassLoader = true);

      repository.forgetPassword(text).then((val) {
        if (val.error == 0) {
          Navigator.of(context).pushNamedAndRemoveUntil(
              '/Login', (Route<dynamic> route) => false);
          Flushbar(
            title: "Password Change request Sent",
            message: "Wait for the Approval from Administrator",
            duration: Duration(seconds: 3),
          )..show(context);
        } else {
          setState(() => forgetPassLoader = false);

          Flushbar(
            title: "Email Address",
            message: "doesn't exist",
            duration: Duration(seconds: 3),
          )..show(context);
        }
      });




    }
  }

  void register(BuildContext context, bool companyInspector) {
    // print(signUpKey.currentState.value);
    SignUpUser fields;
    // print(
    // "$groupValue   $companyInspector"); //company 1, false          //inspector  0,false
    if (signUpKey.currentState.saveAndValidate()) {
      setState(() => signupLoader = true);

      fields = SignUpUser.fromJson(
        signUpKey.currentState.value,
        signatureImage,
        photoImage,
        photoImage,
      );
      if (groupValue == 0) {
        if (
            //   signatureImage != null
            // &&
            photoImage != null &&
                fields.password == fields.passwordConfirmation) {
          //api call and response
          if (companyInspector) {
            //company inspectors
            repository.addCompanyInspector(fields).then((val) {

              if (val == []) {
                setState(() => signupLoader = false);

                Flushbar(
                  title: "Please Verify",
                  message: "Internet Down",
                  duration: Duration(seconds: 3),
                )..show(context);
              }
              if (val['error'] == 1) {
                setState(() => signupLoader = false);

                Flushbar(
                  title: "Please Verify",
                  message: val['messages'].toString(),
                  duration: Duration(seconds: 3),
                )..show(context);
              } else {

                Navigator.of(context).pushNamedAndRemoveUntil(
                    '/Home', (Route<dynamic> route) => false);
                Flushbar(
                  title: "Status ${val.status}",
                  message: val['messages'].toString(),
                  duration: Duration(seconds: 3),
                )..show(context);
              }
            });
          } else {
            //register inspectors
            repository.registerInspector(fields).then((val) {
              print(val);

              setState(() => signupLoader = false);

              if(val==null)
                {
                  setState(() => signupLoader = false);
                }
             else if (val['error'] == 1) {
                Flushbar(
                  title: "Please Verify",
                  message: val['messages'].toString(),
                  duration: Duration(seconds: 3),
                )..show(context);
              } else {

                Navigator.of(context).pushNamedAndRemoveUntil(
                    '/Login', (Route<dynamic> route) => false);
                Flushbar(
                  title: "Registration Successfull",
                  message: "Wait for your approval from the Administrator",
                  duration: Duration(seconds: 3),
                )..show(context);
              }
            });
          }
        } else {
          // if (signatureImage == null) {
          //   setState(() => signupLoader = false);

          //   Flushbar(
          //     title: "Signature Required",
          //     message: "Signature is not selected",
          //     duration: Duration(seconds: 3),
          //   )..show(context);
          // } else
          if (photoImage == null) {
            setState(() => signupLoader = false);

            Flushbar(
              title: "Logo Required",
              message: "Logo is not selected",
              duration: Duration(seconds: 3),
            )..show(context);
          } else if (fields.password != fields.passwordConfirmation) {
            setState(() => signupLoader = false);

            Flushbar(
              title: "Password doesn't match",
              message: "Confirm Password ",
              duration: Duration(seconds: 3),
            )..show(context);
          }
        }
      }


      else {
        if (photoImage != null &&
            fields.password == fields.passwordConfirmation) {
           print("hello"+fields.toJson().toString());                          //register company
          repository.registerCompany(fields).then((val) {
            print(val);
            if (val['error'] == 1) {
              setState(() => signupLoader = false);

              Flushbar(
                title: "Please Verify",
                message: val['messages'].toString(),
                duration: Duration(seconds: 3),
              )..show(context);
            } else {
              Navigator.of(context).pushNamedAndRemoveUntil(
                  '/Login', (Route<dynamic> route) => false);
              Flushbar(
                title: "Registration Successfull",
                message: "Wait for your approval from the Administrator",
                duration: Duration(seconds: 3),
              )..show(context);
            }
          });
        } else {
          if (photoImage == null) {
            setState(() => signupLoader = false);

            Flushbar(
              title: "Logo Required",
              message: "Company Logo is not selected",
              duration: Duration(seconds: 3),
            )..show(context);
          } else if (fields.password != fields.passwordConfirmation) {
            setState(() => signupLoader = false);
            Flushbar(
              title: "Password doesn't match",
              message: "Confirm Password ",
              duration: Duration(seconds: 3),
            )..show(context);
          }
        }
      }
    }
  }
}


