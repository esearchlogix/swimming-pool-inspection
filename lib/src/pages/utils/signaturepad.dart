
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:open_file/open_file.dart';
import 'package:flutter_full_pdf_viewer/full_pdf_viewer_scaffold.dart';
import 'package:path_provider/path_provider.dart';
import 'package:poolinspection/src/elements/drawer.dart';
import 'package:poolinspection/src/elements/inputdecoration.dart';
import 'package:poolinspection/src/elements/radiobutton.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:signature/signature.dart';
import 'package:http/http.dart' as http;
import 'package:poolinspection/src/repository/user_repository.dart' as userRepo;
import 'package:poolinspection/config/app_config.dart' as config;


//final Dio dio = new Dio();
//class WebClient {
//  const WebClient();
//
//  Future<void> download(
//      String url, savePath, ProgressCallback onProgress) async {
//    try {
//      await dio.download(url, savePath, onReceiveProgress: onProgress);
//    } catch (e) {
//      print(e.toString());
//      //throw ('An error occurred');
//    }
//
//  }
//}
//
//final WebClient https = new WebClient();


//void showDownloadProgress(received, total) {
//    if (total != -1) {
//      //calculate %
//      var percentage = (received / total * 100);
//      // update progress state
//      setState(() {
//        if (percentage < 100) {
//          _percentage = percentage;
//        } else {
//          _progressDone = true;
//          progressCircular = false;
//        }
//      });
//    }
//  }
class MyHomePage1 extends StatefulWidget {
  final String id;
  final String category;
  final String bookingDateTime;

  final String bookingtime;
  MyHomePage1(this.id,this.category,this.bookingDateTime,this.bookingtime);
  @override
  _MyHomePage1State createState() => _MyHomePage1State(id,category,bookingDateTime,bookingtime);
}


class _MyHomePage1State extends State<MyHomePage1> {
  bool autoValidate = true;
  bool readOnly = true;
  List regulationdata;
  GlobalKey<FormBuilderState> _formNKey =  GlobalKey<FormBuilderState>();
  String id;
  String category;
  String bookingTime;
  ProgressDialog pr;
  String bookingDateTime;
  double _percentage = 0.0;
  bool _progressDone = false;
  bool progressCircular = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final SignatureController _controller = SignatureController(
    penStrokeWidth: 5,
    penColor: Colors.black,
    exportBackgroundColor: Colors.white,
  );

  _MyHomePage1State(id,category,bookingDateTime,bookingTime)
  {
    this.id=id;
    this.category=category;
    this.bookingDateTime=bookingDateTime;
    this.bookingTime=bookingTime;

  }


  @override
  void initState() {
    super.initState();

    _controller.addListener(() => print("Value changed"));
    pr = ProgressDialog(context,isDismissible: false);
  }

  Future generatePdf(var dataimage,String paymentpaid) async
  {
    await pr.show();
//    category!="notice"?bookingTime=null:null;
//    category!="notice"?bookingDateTime=null:null;
    //final bytes = await .File(dataimage).readAsBytes();
    String base64Image = base64Encode(dataimage);

//    print("zzcategory="+category);
//    print("zzdate="+bookingDateTime.toString());
//    print("zztime="+bookingTime.toString());
    print("checkpaymentpaid="+paymentpaid);
   // final Directory directory = await getApplicationSupportDirectory();
   // final String path = await directory.path;
    //final File file = File('${path}/outputc.pdf');
    try {
      print("imageimage"+dataimage.toString());
      final response = await http.post(
          'https://poolinspection.beedevstaging.com/api/beedev/post_signature',
          body: {'job_id': id, 'signature':"data:image/png;base64,"+base64Image,'payment_paid':paymentpaid}
      );

    //  await file.writeAsBytes(response.bodyBytes);
      print("kkresponse"+response.body.toString());

      if(response.body.toString().contains("<!DOCTYPE html>")) {
        await pr.hide();
        Fluttertoast.showToast(
            msg: "Not returning pdf:-\n"+response.body.toString(),
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0
        );
      }
      else
        {
          await pr.hide();
          Navigator.of(context).pop();
        }
     // print("kkresponse"+file.toString());
    }catch(e)
    {
      await pr.hide();
      print("errorinsignaturebackend"+e.toString());
      Fluttertoast.showToast(
          msg: "Error from backend"+e.toString(),
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0
      );
    }




  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
        key: _scaffoldKey,
        //  drawer: DrawerOnly(),
        backgroundColor: config.Colors().scaffoldColor(1),
        drawer: drawerData(context, userRepo.user.rolesManage),
        appBar: AppBar(
          leading: IconButton(
              icon: Icon(
                Icons.arrow_back_ios,
                color: config.Colors().secondColor(1),
              ),
              onPressed: () => Navigator.pop(context)),
          title: Align(alignment: Alignment.center,
            child:Text("Signature Pad",
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontFamily: "AVENIRLTSTD",
                fontSize: 20,
                color: Color(0xff222222),
              ),
            ),

          ),
          actions: <Widget>[
            IconButton(
                icon: Icon(Icons.menu),
                onPressed: () => _scaffoldKey.currentState.openDrawer())
          ],
        ),

        body:Builder(
            builder: (context) => Scaffold(
              body: ListView(

                children: <Widget>[

                  //SIGNATURE CANVAS
                  Signature(
                    controller: _controller,
                    height: 300,
                    backgroundColor: Color(0xffdedede),
                  ),
                  Container(
                    child: bookingForm(context),
                  ),
                  //OK AND CLEAR BUTTONS

                  Padding(
                    padding: EdgeInsets.all(10.0),

                    child: Container(
                      decoration: const BoxDecoration(color: Colors.blue),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        mainAxisSize: MainAxisSize.max,
                        children: <Widget>[
                          //SHOW EXPORTED IMAGE IN NEW ROUTE
                          IconButton(
                            icon: const Icon(Icons.check,),
                            color: Colors.white,
                            onPressed: () async  {

                              if (_controller.isNotEmpty) {

                                 _formNKey.currentState.saveAndValidate();
                                var data = await _controller.toPngBytes();

                                generatePdf(data,_formNKey.currentState.value["payment_paid"].toString());

                              }
                              else
                                {
                                  Fluttertoast.showToast(
                                      msg: "Please do the signature",
                                      toastLength: Toast.LENGTH_SHORT,
                                      gravity: ToastGravity.CENTER,
                                      timeInSecForIosWeb: 1,
                                      backgroundColor: Colors.red,
                                      textColor: Colors.white,
                                      fontSize: 16.0
                                  );
                                }
                            },
                          ),
                          //CLEAR CANVAS
                          IconButton(
                            icon: const Icon(Icons.clear),
                            color: Colors.white,
                            onPressed: () {
                              setState(() => _controller.clear());
                            },
                          ),
                        ],
                      ),
                    ),
                  )

                ],
              ),
            ),
          ),



    );

  }
  FormBuilder bookingForm(BuildContext context) {

    return FormBuilder(
        key: _formNKey,

        initialValue: {
          "payment_paid": "No",
        },

        child:Padding(

          padding: const EdgeInsets.all(8.0),
          child: listView(context),
        ));

  }
  Column listView(BuildContext context) {
    final sizedbox =
    SizedBox(height: config.App(context).appVerticalPadding(2));
    return Column(

      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[

        Card(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child:Column(

                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[

                  Text("Has the inspection fee payment been made?",textAlign: TextAlign.left,  style: TextStyle(
                      fontFamily: "AVENIRLTSTD",
                      fontSize: 18,
                      color: Color(0xff222222),
                      fontWeight: FontWeight.normal),),

                  CustomFormBuilderRadio(
                    activeColor: Color(0xff222222),
                    decoration: buildInputDecoration(context,
                        "Has the inspection fee payment been made?", "yes or no"),
                    attribute: "payment_paid",
                    validators: [FormBuilderValidators.required()],
                    options: ["Yes", "No"]
                        .map((lang) => FormBuilderFieldOption(value: lang))
                        .toList(growable: false),
                  ),


                  sizedbox,



                ],
              ),
            )

        ),

        sizedbox,

      ],
    );
  }
}



