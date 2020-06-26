import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:http/http.dart' as http;
import 'package:poolinspection/src/helpers/sharedpreferences/userpreferences.dart';
import 'package:poolinspection/src/models/credit_card.dart';
import 'package:poolinspection/src/models/errorclasses/errorsignupcompanymodel.dart';
import 'package:poolinspection/src/models/generic_response.dart';
import 'package:poolinspection/src/models/signupfields.dart';
import 'package:poolinspection/src/models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

UserModel currentUser = new UserModel();
Inspector inspector = new Inspector();
Company company = new Company();
User user = new User();
int userid;
String token;

// Future<UserModel> login(User user) async {
//   final String url =
//       '${GlobalConfiguration().getString('api_base_url')}login_api';
//   final client = new http.Client();
//   final response = await client.post(
//     url,
//     headers: {HttpHeaders.contentTypeHeader: 'application/json'},
//     body: json.encode(user.toJson()),
//   );
//   print(response.body);
//   currentUser = UserModel.fromJSON(json.decode(response.body));
//   UserSharedPreferencesHelper.setUserdetails(response.body);

//   return currentUser;

// }
Future login(User user) async {

  final String url =
      '${GlobalConfiguration().getString('api_base_url')}login_api';
  final client = new http.Client();
  try {

    final response = await client.post(
      url,
      headers: {HttpHeaders.contentTypeHeader: 'application/json'},
      body: json.encode(user.toJson()),
    ).timeout(
      const Duration( seconds: 15),

    );
//
    print(response.body);

    return json.decode(response.body);
  }
  on TimeoutException catch (_) {
    Fluttertoast.showToast(
        msg: "Connection Time Out ",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0
    );
  }
  on SocketException catch (_) {
    Fluttertoast.showToast(
        msg: "No Internet",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0
    );
  }
  on Exception catch (e) {
    Fluttertoast.showToast(
        msg: "Error:"+e.toString(),
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0
    );
  }


}

// Future<User> verifyOtp(User user) async {
// getCurrentUser().then((onValue) async {
//     print(onValue.id);
//   // print(user.token2fa);
//  final postdata={
//     "user_id":onValue.id,
//     // "otp":user.token2fa
//   };
//   final String url = '${GlobalConfiguration().getString('api_base_url')}verify_token';
//   final client = new http.Client();
//   final response = await client.post(
//     url,
//     headers: {HttpHeaders.contentTypeHeader: 'application/json',},
//     body:json.encode(postdata),
//   );
//         print(response.body);

//   // if (response.statusCode == 200) {
//   //   if(json.decode(response.body)['userdata'] !=null){
//   //   currentUser = User.fromJson(json.decode(response.body)['userdata']);
//   //   setCurrentUser(response.body);
//   //   }else{
//   //     print(response.body);
//   //   }
//   // }
// });

//   return currentUser;
// }

// Future<User> resendOtp(User user) async {
// getCurrentUser().then((onValue) async {

//   final String url = '${GlobalConfiguration().getString('api_base_url')}resend_otp';
//   final client = new http.Client();
//   final response = await client.post(
//     url,
//     headers: {HttpHeaders.contentTypeHeader: 'application/json'},
//     // body: json.encode({"user_id":onValue.})
//   );
//   // print(json.decode(response.body)['userdata'][0]);

//   if (response.statusCode == 200) {
//     // setCurrentUser(response.body);
//     // currentUser = User.fromJson(json.decode(response.body)['userdata'][0]);
//   }
// });
//   return currentUser;
// }

// Future<UserModel> register(User user) async {

Future registerInspector(SignUpUser fields) async {
  Dio dio = new Dio();

  final String url =
      '${GlobalConfiguration().getString('api_base_url')}register_inspector_api';
  // BaseOptions options = new BaseOptions(
  //   baseUrl: url,
  //   connectTimeout: 5000,
  //   receiveTimeout: 3000,
  // );
  // Dio dio = new Dio(options);

  // print(url);
  FormData formData = FormData.fromMap({
    "registration_number": fields.registrationNumber,
    "email": fields.email,
    "mobile_no": fields.mobileNo,
    "username": fields.username,
    "password": fields.password,
    "password_confirmation": fields.passwordConfirmation,
    "card_number": fields.cardNumber,
    "card_cvv": fields.cardCvv,
    "card_expiry_month": fields.cardExpiryMonth,
    "card_expiry_year": fields.cardExpiryYear,
    "card_type": 1,
    "Street": fields.street,
    "Postcode": fields.postcode,
    "City": fields.city,
    // "District": fields.district,
    "first_name": fields.firstName,
    "last_name": fields.lastName,
    "inspector_abn": fields.inspectorAbn,
    "tax_applicable":fields.taxApplicable=="Yes"?"1":"0",
    "inspector_address":fields.inspectorAddress,
    // "inspector_signature": await MultipartFile.fromFile(
    //     fields.inspectorSignature.path,
    //     filename: "text1.png"),
    "inspector_image": await MultipartFile.fromFile(fields.inspectorImage.path,
        filename: "Inspectorimage")
  });
  try {
    final response = await dio.post(url,
        data: formData,
        options: Options(headers: {
          "Accept": "application/json",
          // 'Authorization': 'Bearer $authToken',
        })).timeout(
      const Duration( seconds: 15),

    );

    print(response.data);
    return response.data;
  }
  on DioError catch (e) {
    if (e.type == DioErrorType.DEFAULT) {
      Fluttertoast.showToast(
          msg: "No Internet",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0
      );
    }
    if (e.type == DioErrorType.CONNECT_TIMEOUT) {
      Fluttertoast.showToast(
          msg: "No Internet",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0
      );
    }
    if (e.type == DioErrorType.RESPONSE) {
      Fluttertoast.showToast(
          msg: "Wrong Response From Backend",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0
      );
    }
  }

}

Future addCompanyInspector(SignUpUser fields) async {
  Dio dio = new Dio();

  print("${company.id} sdsdsdsds");
  final String url =
      '${GlobalConfiguration().getString('api_base_url')}register_inspector_api';
  print(url);
  FormData formData = FormData.fromMap({
    "first_name": fields.firstName,
    "last_name": fields.lastName,
    "registration_number": fields.registrationNumber,
    "email": fields.email,
    "mobile_no": fields.mobileNo,
    "username": fields.username,
    "password": fields.password,
    "password_confirmation": fields.passwordConfirmation,
    "inspector_abn": fields.inspectorAbn,
    "inspector_address": fields.inspectorAddress,
    // "inspector_signature": await MultipartFile.fromFile(
    //     fields.inspectorSignature.path,
    //     filename: "text1.png"),
      "inspector_image": await MultipartFile.fromFile(fields.inspectorImage.path,
  filename: "Inspectorimage"),   // this can break code
    "company_id": company.id
  });
  try {
    final response = await dio.post(url,
        data: formData,
        options: Options(headers: {
          "Accept": "application/json",
          // 'Authorization': 'Bearer $authToken',
        }));
    print(response.data);
    return response.data;
  } catch (e) {
    return e;
  }
}

Future registerCompany(SignUpUser fields) async {
  Dio dio = new Dio();
  final String url =
      "https://poolinspection.beedevstaging.com/api/register_company_api";
  print("urlofcompanysignup="+url.toString());
  var formData = FormData.fromMap({
    "registration_number": fields.registrationNumber,
    "email": fields.email,
    "mobile_no": fields.mobileNo,
//    "username": fields.username,
    "password": fields.password,
    "password_confirmation": fields.passwordConfirmation,
//    "card_number": fields.cardNumber,
//    "card_cvv": fields.cardCvv,
//    "card_expiry_month": fields.cardExpiryMonth,
//    "card_expiry_year": fields.cardExpiryYear,
//    "card_type": 1,
    "Street": fields.street,
    "Postcode": fields.postcode,
    "City": fields.city,
    "tax_applicable":fields.taxApplicable,
    // "District": fields.district,
    "company_logo": await MultipartFile.fromFile(fields.companyLogo.path,
        filename: "text121123.png"),
    "company_name": fields.companyName,
    "company_abn": fields.companyAbn,
    "company_address": fields.companyAddress,
  });

  try {
    final response = await dio.post(url,
        data: formData,
        options: Options(headers: {
          "Accept": "application/json",
          // 'Authorization': 'Bearer $authToken',
        }));


    print("usersignupinspectorresponse"+response.data.toString());
    return response.data;
  } catch (e) {
    return e;
  }
}

Future<void> logout() async {
  currentUser = new UserModel();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.remove('current_user');
  await prefs.remove('token');
}

Future<User> update(User user) async {
  // final String _apiToken = 'api_token=${currentUser}';
  // final String url = '${GlobalConfiguration().getString('api_base_url')}users/${currentUser.id}?$_apiToken';
  // final client = new http.Client();
  // final response = await client.post(
  //   url,
  //   headers: {HttpHeaders.contentTypeHeader: 'application/json'},
  //   body: json.encode(user.toJson()),
  // );
  // setCurrentUser(response.body);
  // currentUser = User.fromJson(json.decode(response.body)['data']);
  // return currentUser;
}

Future<GenericResponse> forgetPassword(String text) async {
  // final String _apiToken = 'api_token=${currentUser}';
  final String url =
      '${GlobalConfiguration().getString('api_base_url')}reset_password_request_api';
  final client = new http.Client();
  final response = await client.post(
    url,
    headers: {HttpHeaders.contentTypeHeader: 'application/json'},
    body: json.encode({"email": text}),
  );
  Map<String, dynamic> responseJson = json.decode(response.body);
  GenericResponse genericResponse = GenericResponse.fromJson(responseJson);

  print(genericResponse.messages);

  // setCurrentUser(response.body);
  // currentUser = User.fromJson(json.decode(response.body)['data']);
  // return json.decode(response.body);
  return genericResponse;
}

Future<GenericResponse> updatePassword(User user) async {
  // // final String _apiToken = 'api_token=${currentUser}';
  final String url =
      '${GlobalConfiguration().getString('api_base_url')}change_password_api';
  final client = new http.Client();
  final response = await client.post(
    url,
    headers: {HttpHeaders.contentTypeHeader: 'application/json'},
    body: json.encode({
      "new_password": user.password,
      "confirm_password": user.confirmPassword,
      "user_id": 13
    }),
  );
  Map<String, dynamic> responseJson = json.decode(response.body);
  GenericResponse genericResponse = GenericResponse.fromJson(responseJson);
  print(genericResponse.messages);
  // setCurrentUser(response.body);
  // currentUser = User.fromJson(json.decode(response.body)['data']);
  // return json.decode(response.body);
  return genericResponse;
}

