import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:global_configuration/global_configuration.dart';

import 'package:poolinspection/src/controllers/inspection_controller.dart';
import 'package:poolinspection/src/models/bookingmodel.dart';
import 'package:poolinspection/src/models/companyinspectormodel.dart';
import 'package:poolinspection/src/models/errorclasses/errorsignupcompanymodel.dart';
import 'package:poolinspection/src/models/generic_response.dart';
import 'package:http/http.dart' as http;
import 'package:poolinspection/src/models/user.dart';
import 'package:progress_dialog/progress_dialog.dart';

Future getAllRegulations() async {
  final String _apiToken = 'beedev';
  final String url =
      '${GlobalConfiguration().getString('api_base_url')}$_apiToken/get_all_regulation';
  final response = await http.get(url);
  if (response.statusCode == 200) {
    return json.decode(response.body);
  } else {
    throw Exception('Failed to load post');
  }
}

Future getCompanyInspectors(int id) async {
  // TODO get dynamic company
  final String _apiToken = 'beedev';
  final String url =
      '${GlobalConfiguration().getString('api_base_url')}$_apiToken/get_company_inspector/$id';
  final response = await http.get(url);
  if (response.statusCode == 200) {
    return json.decode(response.body);
  } else {
    throw Exception('Failed to load post');
  }
}

// Future<Inspector> getCompanyOrInspectorList() async {
//   final String _apiToken = 'beedev';
//   final String url =
//       '${GlobalConfiguration().getString('api_base_url')}$_apiToken/get_logged_in_user_data/1';
//   final response = await http.get(url);
//   if (response.statusCode == 200) {
//     final abc = CompanyInspectorModel.fromJson(json.decode(response.body));
//     return abc;
//   } else {
//     throw Exception('Failed to load post');
//   }
// }

Future postBooking(value) async {
  final String _apiToken = 'beedev';
  try {
    final String url =
        '${GlobalConfiguration().getString(
        'api_base_url')}$_apiToken/booking_api';
    final client = new http.Client();
    final response = await client.post(url,
        headers: {HttpHeaders.contentTypeHeader: 'application/json'},
        body: json.encode(value)).timeout(
        const Duration(seconds: 20));
    print("responsebody" + response.body.toString());
    return json.decode(response.body);
  }
  on TimeoutException catch (_) {
    Fluttertoast.showToast(
        msg: "Connection Time Out ",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor:Colors.red,
        textColor:Colors.white ,
        fontSize: 16.0
    );
  }
  on SocketException catch (e) {
    Fluttertoast.showToast(
        msg: "No Internet Connection",
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

Future confirmPreliminaryBooking(
    Map<String, dynamic> predata, predataprefilled) async {
  print(predataprefilled['preliminary_data']['inspector_list']);
  final String _apiToken = 'beedev';
  try {
    final String url =
        '${GlobalConfiguration().getString(
        'api_base_url')}$_apiToken/confirm_preliminary_data/${predata['bookingid']}';
    print(url);
    final client = new http.Client();
    var bodydata = {
      'owner_land': predata['owner_land'],
      "phonenumber": predata['phonenumber'],
      "email_owner": predata['email_owner'],
      "address": predata['address'] ?? "null",
      "name_relevant_council": predata['name_relevant_council'],
      // "email_relevant_council": predata['email_relevant_council'],
      "swi_pool_spa": predata['swi_pool_spa'] == "Swimming Pool"
          ? "swimming_pool"
          : "spa",
      "permnt_relocate": predata['permnt_relocate'] == "Permanent"
          ? "permanent"
          : "relocatable",
      "payment_paid": predata['payment_paid'] == "Yes" ? "yes" : "no",
      "inspection_fee": predata['inspection_fee'],
      "send_invoice": predata['send_invoice'],
      "recently_inspected": predata['recently_inspected'] == "Yes"
          ? "yes"
          : "no",
      "notice_registration": predata['notice_registration'].toString(),
      "Council_due_date": predata['Council_due_date'].toString(),
      "booking_date_time": predata['booking_date_time'].toString(),
      "booking_time": predata['booking_time'].toString(),
      "council_regis_date": predata['council_regis_date'].toString(),
      "inspector_list": predataprefilled['preliminary_data']['inspector_list'],
      "notice_regis": predataprefilled['preliminary_data']['notice_regis'],
      "street_road": predata['street_road'],
      "postcode": predata['postcode'],
      "city_suburb": predata['city_suburb'],
      // "municipal_district": predata['municipal_district'] ?? "null",
    };
    // print(bodydata);
    final response = await client.post(url,
        // headers: {HttpHeaders.contentTypeHeader: 'application/json'},
        body: bodydata);
    debugPrint("nice="+bodydata.toString());
    //debugPrint("nice=" + json.decode(response.body).toString());
    return json.decode(response.body);
  }
  on TimeoutException catch (_) {
    Fluttertoast.showToast(
        msg: "No Internet Connection",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0
    );
  }
  on SocketException catch (e) {
    Fluttertoast.showToast(
        msg: "No Internet Connection",
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

Future getHeadersFromBookingId(int bookingid) async {
  final String _apiToken = 'beedev';
  try {
  final String url =
      '${GlobalConfiguration().getString('api_base_url')}$_apiToken/get_heading_with_booking_id/$bookingid';
  final response = await http.get(url).timeout(
      const Duration( seconds: 20));
  print("$url getHeadersFromBookingId");
  if (response.statusCode == 200) {

     print("responseofhead="+response.body.toString());
    return json.decode(response.body);
  } else {
    throw Exception('Failed to load post');
  }
  }
  on TimeoutException catch (_) {
    Fluttertoast.showToast(
        msg: "No Internet Connection",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0
    );
  }
  on SocketException catch (e) {
    Fluttertoast.showToast(
        msg: "No Internet Connection",
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

Future getQuestionsFromHeadingId(int headingId, int booking) async {
  final String _apiToken = 'beedev';
  try {
    final String url =
        '${GlobalConfiguration().getString(
        'api_base_url')}$_apiToken/questions_from_headingID/$booking/$headingId';
    print(url);
    final response = await http.get(url).timeout(
        const Duration(seconds: 20));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load post');
    }
  }
  on TimeoutException catch (_) {
    Fluttertoast.showToast(
        msg: "Connection Time Out ",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor:Colors.red,
        textColor:Colors.white ,
        fontSize: 16.0
    );
  }
  on SocketException catch (e) {
    Fluttertoast.showToast(
        msg: "No Internet Connection",
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

Future preliminaryDataFromJobNo(int jobno) async {
  final String _apiToken = 'beedev';
  try
  {
  final String url =
      '${GlobalConfiguration().getString('api_base_url')}$_apiToken/preliminary_data/$jobno';
  print(url);
  final response = await http.get(url).timeout(
      const Duration( seconds: 20));
  if (response.statusCode == 200) {
    return json.decode(response.body);

    // print(json.decode(response.body));
  } else {
    throw Exception('Failed to load post');
  }

  }
  on TimeoutException catch (_) {
    Fluttertoast.showToast(
        msg: "Connection Time Out ",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor:Colors.red,
        textColor:Colors.white ,
        fontSize: 16.0
    );
  }
  on SocketException catch (e) {
    Fluttertoast.showToast(
        msg: "No Internet Connection",
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

Dio dio = new Dio();
Future postBookingAnswer(QuestionData fields) async {


  final String _apiToken = 'beedev';

  final String url =
      '${GlobalConfiguration().getString('api_base_url')}$_apiToken/booking_ans_post';
  print(url);
//  print("imagepath"+fields.imagepath.toString());
  print("imagepath${fields.imagepath}");
  FormData formData = fields.imagepath == null
      ? FormData.fromMap({
          "bookin_ans_id": fields.bookingAnsId,
          "comment": fields.comment,
          "question_id": fields.questionId,
          "booking_id": fields.bookingID,
          "ans": fields.choice,
          // "images": [
          //   for (var i = 0; i < fields.imagename.length; i++)
          //     await MultipartFile.fromFile(fields.imagepath[i],
          //         filename: fields.imagename[i])
          // ]
          // "images[]": await MultipartFile.fromFile(fields.image.path,
          //     filename: "text121123.png")
        })
      : FormData.fromMap({
          "bookin_ans_id": fields.bookingAnsId,
          "comment": fields.comment,
          "question_id": fields.questionId,
          "booking_id": fields.bookingID,
          "ans": fields.choice,
          "images":  [for(var i = 0; i < fields.imagename.length; i++)
             await MultipartFile.fromFile(fields.imagepath[i],
                  filename: fields.imagename[i])
]
//          [
//            for (var i = 0; i < fields.imagename.length; i++)
//              await MultipartFile.fromFile(fields.imagepath[i],
//                  filename: fields.imagename[i])
//          ]
          // "images[]": await MultipartFile.fromFile(fields.image.path,
          //     filename: "text121123.png")
        });
  // print(formData.toString())
  try {
    final response = await dio.post(url,
        data: formData,
        options: Options(headers: {
          "Accept": "application/json",
          // 'Authorization': 'Bearer $authToken',
        }));
     print("qwertyuiop"+response.data.toString());
    return response.data;
  }   on DioError catch (e) {

    if (e.type == DioErrorType.CONNECT_TIMEOUT) {
      Fluttertoast.showToast(
          msg: "Connection TimeOut",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0
      );
    }
    if (e.type == DioErrorType.DEFAULT) {
      Fluttertoast.showToast(
          msg: "Offline Submitted",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0
      );
      return "No Internet";
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

Future completeMark(int bookingid, int choice) async {
  final String _apiToken = 'beedev';

  final String url =
      '${GlobalConfiguration().getString('api_base_url')}$_apiToken/compliance_post';
  print("tello"+url);
  FormData formData = FormData.fromMap({
    "booking_id": bookingid,
    "is_compliant": choice,
  });
  try {
    final response = await dio.post(url,
        data: formData,
        options: Options(headers: {
          "Accept": "application/json",
          // 'Authorization': 'Bearer $authToken',
        }));
    return response.data;
  } catch (e) {
    return e;
  }
}

Future getAllQuestionsCount(int jobno) async {
  final String _apiToken = 'beedev';
  final String url =
      '${GlobalConfiguration().getString('api_base_url')}$_apiToken/get_all_question_from_job_id/$jobno';
  print(url);
  final response = await http.get(url);
  if (response.statusCode == 200) {
    return json.decode(response.body);

    // print(json.decode(response.body));
  } else {
    throw Exception('Failed to load post');
  }
}

Future getAllQuestionsCountFromHeading(int bookingid, int headingid) async {
  final String _apiToken = 'beedev';
  final String url =
      '${GlobalConfiguration().getString('api_base_url')}$_apiToken/check_all_question_filled_in_heading/$bookingid/$headingid';
  print(url);
  final response = await http.get(url);
  if (response.statusCode == 200) {
    // print(json.decode(response.body)['not_answered']);

    return json.decode(response.body);
  } else {
    throw Exception('Failed to load post');
  }
}


/*

api of all answer send ,
prev , next can be done but tell later.
 */