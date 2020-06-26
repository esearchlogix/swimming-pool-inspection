import 'dart:async';

import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:poolinspection/src/helpers/sharedpreferences/userpreferences.dart';
import 'package:poolinspection/src/models/bookingmodel.dart';
import 'package:poolinspection/src/models/errorclasses/errorsignupcompanymodel.dart';

import 'package:poolinspection/src/repository/booking_repository.dart'
    as repository;
import 'package:poolinspection/src/repository/user_repository.dart' as userRepo;
import 'package:poolinspection/src/repository/booking_repository.dart';

class BookingFormController extends ControllerMVC {
  // List<BookingGetModel> bookingRegulation;
  // StreamController<List<Userdata>> streamController;
  GlobalKey<FormBuilderState> bookingFormKey;
  bool bookingLoader = false;
  bool bookingLoader1 = false;
  bool prefilLoader1 = false;
  bool prefilLoader2 = false;
  bool prefilLoader3 = false;
  BookingPrefil preliminaryData;
  List regulationdata;
  List<String> companyinspectors;
  final council_due_date = TextEditingController();
  final booking_date_time = TextEditingController();
  final booking_time = TextEditingController();
  final council_regis_date = TextEditingController();
  int roles;
  BookingFormController() {
    regulationdata = List();
    preliminaryData = BookingPrefil();
    companyinspectors = List<String>();
    bookingFormKey = GlobalKey<FormBuilderState>();

    // streamController = new StreamController<List<Userdata>>.broadcast();
    decideView();
    getRegulations();
    // getinspectorList();
    // decideView();
  }
  var predata;
  getRegulations() async {
    repository.getAllRegulations().then((onValue) {
      setState(() {
        // print(onValue['get_all_regulation']);
        for (var i = 0; i < onValue['get_all_regulation'].length; i++) {
          // regulation.add(onValue['get_all_regulation'][i]['category_name']);
          // regulationid.add(onValue['get_all_regulation'][i]['id']);
          regulationdata.add(onValue['get_all_regulation'][i]);
        }
      });
    });
  }

  getPreliminaryData(int jobid) async {
    repository.preliminaryDataFromJobNo(jobid).then((onValue) {
      // print(onValue);
      setState(() {
        // for (var i = 0; i < onValue['get_all_regulation'].length; i++) {
        //   // regulation.add(onValue['get_all_regulation'][i]['category_name']);
        //   // regulationid.add(onValue['get_all_regulation'][i]['id']);
        //   regulationdata.add(onValue['get_all_regulation'][i]);
        // }
        predata = onValue;
        preliminaryData = BookingPrefil.fromJson(onValue);
      });
    });
  }

  getinspectorList() async {
    // userRepo.company.id=1;
    userRepo.company != null
        ? repository.getCompanyInspectors(3).then((onValue) {
            // print(onValue);
            setState(() {
              for (var i = 0;
                  i < onValue['get_company_inspector'].length;
                  i++) {
                companyinspectors
                    .add(onValue['get_company_inspector'][i]['first_name']);
              }
              print(companyinspectors.length);
            });
          })
        : print('Company id null');
  }

  Future decideView() async {
    UserSharedPreferencesHelper.getRoles().then((onValue) {
      print(onValue);
      setState(() {
        roles = onValue;
      });
    });
  }

  sendEnquiry(BuildContext context) {
    if(bookingLoader==false && bookingLoader1==false)
      {
        if (bookingFormKey.currentState.validate()) {
          bookingFormKey.currentState.save();
          // print(
          // "${council_due_date.text}  ${booking_date_time.text} ${council_regis_date.text}");
          // print(bookingFormKey.currentState.value);
          // _con.bookingFormKey.currentState.value;
          setState(() {

            bookingFormKey.currentState.value["send_invoice"]=="1"?bookingLoader1=true:bookingLoader = true;

          }
          );

          print("responseofbookform"+bookingFormKey.currentState.value.toString());
          repository.postBooking(BookingModel.fromJson(bookingFormKey.currentState.value))
              .then((onValue) {
               print("checkinbook="+onValue.toString());
            // if (onValue['error'] == null) {
            // } else {}
            // bookingFormKey.currentState.value["send_invoice"]=="1"?bookingLoader1=false:bookingLoader = false;

               if(onValue!=null) {
                 Navigator.of(context).pushReplacementNamed('/Home');
                 Flushbar(
                   title: "Done Booking",
                   message: onValue['messages'],
                   duration: Duration(seconds: 3),
                 )
                   ..show(context);
               }
               else
                 {
                   setState(() {
                     bookingLoader1=false;
                     bookingLoader=false;
                   });
                 }

          });
        }

      }
    else
    {
      Fluttertoast.showToast(
          msg: "Please Wait",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.blue,
          textColor: Colors.white,
          fontSize: 16.0
      );
    }
  }

  confirmToQuestions(Map<String, dynamic> value, BuildContext context) {
    setState(() {
      value["send_invoice"]=="1"?prefilLoader1=true:value["send_invoice"]=="2"?prefilLoader2 = true:prefilLoader3=true;
    }
    );

    confirmPreliminaryBooking(value, predata).then((onValue) {
    //   debugPrint("helloinvoice"+onValue.toString());

       if(onValue!=null) {
         Navigator.pushReplacementNamed(context, "/Home");
         Flushbar(
           title: "Details Confirmed",
           message: "Inspection needs to be Initiated",
           duration: Duration(seconds: 3),
         )
           ..show(context);
         //done


       }
       else
         {
           setState(() {
             prefilLoader1=false;
             prefilLoader2=false;
             prefilLoader3=false;
           });
         }


    });
    // print(preliminaryData.preliminaryData.id);

    //TODO confirmation to next page
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //       builder: (context) => InspectionHeadingList(
    //           predata: value, bookingid: preliminaryData.preliminaryData.id)),
    // );
  }
}
