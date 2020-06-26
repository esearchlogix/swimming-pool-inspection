import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_signature_pad/flutter_signature_pad.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:poolinspection/src/elements/drawer.dart';
import 'package:poolinspection/src/elements/inputdecoration.dart';
import 'package:poolinspection/src/models/getcertificatemodel.dart';
import 'package:poolinspection/src/models/selectCompliantOrNotice.dart';
import 'package:poolinspection/src/pages/home/PermissionHandler.dart';
import 'package:poolinspection/src/pages/utils/signaturepad.dart';
import 'package:poolinspection/src/helpers/sharedpreferences/userpreferences.dart';
import 'package:poolinspection/config/app_config.dart' as config;
import 'package:poolinspection/src/models/route_argument.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:poolinspection/src/repository/user_repository.dart' as userRepo;
import 'package:share_extend/share_extend.dart';

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
//


class SelectNoticeOrNonCompliant extends StatefulWidget {
  final String bookingId;
  SelectNoticeOrNonCompliant(this.bookingId);

  @override
  _SelectNoticeOrNonCompliantState createState() => _SelectNoticeOrNonCompliantState(bookingId);

}
class _SelectNoticeOrNonCompliantState extends State<SelectNoticeOrNonCompliant> {


  bool isLoading = false;
  bool _progressDone = false;
  double _percentage = 0.0;
  ProgressDialog pr;
  String bookingId;
  bool progressCircular = false;
  GlobalKey<FormBuilderState> _formNKey =  GlobalKey<FormBuilderState>();
  List<ListElement> certificate =new List<ListElement>();


  bool _firstSearch = true;
  String _query = "";
 int UserId;
  String categor;

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  _SelectNoticeOrNonCompliantState(bookingId)
  {
   this.bookingId=bookingId;

  }


  @mustCallSuper
  @override
  void initState() {

     pr = ProgressDialog(context,isDismissible: false);



    UserSharedPreferencesHelper.getUserDetails().then((user) {
      setState(() {
        // print("${user.userdata.inspector.firstName } controller user id");
        UserId=user.id;
   print("useruser="+bookingId.toString());

      });
    });
  }




  Future selectnoncompliantornotice(String selection,String bookingDate,String bookingTime) async{

   var response;
    await pr.show();
    print("bookbook"+bookingDate.toString());
    print("bookbooktime"+bookingTime.substring(11,16).toString());
    try
    {
      response = await http.post(
          'https://poolinspection.beedevstaging.com/api/beedev/confirm_non_compliant',
          body: {'booking_id': bookingId.toString(), 'booking_date_time': bookingDate.substring(0,10).toString(),'booking_time':bookingTime.substring(11,16).toString(),'compliant_btn':selection}
      );
      print("helohelo"+response.body.toString());
      SelectNonCompliantOrNotice selectNonCompliantOrNotice= selectNonCompliantOrNoticeFromJson(response.body);


      if(selectNonCompliantOrNotice.error.toString()=="0")
      {

        await pr.hide();
        if(selectNonCompliantOrNotice.status.toString()=="notice") {
          Navigator.pushNamedAndRemoveUntil(context,'/Home',(Route<dynamic> route) => false);
          Navigator.of(context).pushNamed("/Certificate",
           arguments: RouteArgumentCertificate(
               id: 4, heroTag:"Notice of Improvement"));
        }
        else
        {
          Navigator.pushNamedAndRemoveUntil(
              context, '/Home', (Route<dynamic> route) => false);
          Navigator.of(context).pushNamed("/Certificate",
              arguments: RouteArgumentCertificate(
                  id: 3, heroTag: "Non Compliant"));
        }
      }
      else
      {
        await pr.hide();
        Fluttertoast.showToast(
            msg: response.body.toString(),
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0
        );
      }
    }
  catch(e)
    {
      await pr.hide();
      print("errorinselectfrombackend"+e.toString());
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

    // TODO: implement build
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
            child:Text("Select Option",
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontFamily: "AVENIRLTSTD",
                fontSize: 20,
                color: Color(0xff222222),
              ),
            ),

          ),
          actions: <Widget>[


              //   IconButton(
              //       icon: Icon(Icons.menu),
              //         onPressed: () => _con.scaffoldKey.currentState.openDrawer()),

            IconButton(
                icon: Icon(Icons.menu),
                onPressed: () => _scaffoldKey.currentState.openDrawer())
          ],
        ),

        body: Padding(
          padding: EdgeInsets.all(10),
          child: Stack(
            children: <Widget>[
              SingleChildScrollView(
                child: bookingForm(context),
              ),
              Align(
                alignment: Alignment.center,
                child:  Row(

                  children: <Widget>[
                    Expanded(flex:1,child:Container(

                      alignment: Alignment.bottomCenter,
                      child: Container(

                        child: MaterialButton(
                             
                            minWidth: MediaQuery.of(context).size.width/2.5,
                            child:Padding(
                              padding: EdgeInsets.all(10.0),
                              child:  Text(
                                "Non-Compliant",
                                style: TextStyle(color: Theme.of(context).primaryColor,fontFamily: "AVENIRLTSTD",fontSize: 18),
                              ),
                            ),
                            color: Theme.of(context).accentColor,
                            onPressed: () {



                                  selectnoncompliantornotice("non-compliant","2020-06-27 00:00:00.000","0001-01-01 17:24:00.000");

                            }
                        ),
                      ),
                    ),),
                    Expanded(flex:1,child:Container(

                      alignment: Alignment.bottomCenter,
                      child:Container(

                          child: MaterialButton(
                              minWidth: MediaQuery.of(context).size.width/2.5,
                              child: Padding(
                                padding: EdgeInsets.all(10.0),
                                child:Text(
                                  "Notice of Improvement",
                                  style: TextStyle(color: Theme.of(context).primaryColor,fontFamily: "AVENIRLTSTD",fontSize: 18),
                                ),
                              ),
                              color: Theme.of(context).accentColor,
                              onPressed: () {
                                if(_formNKey.currentState.saveAndValidate())

                                {
                                  print("selectbookdate"+_formNKey.currentState.value['booking_date_time'].toString());
                                  print("selectbooktime"+_formNKey.currentState.value['booking_time'].toString());
                                  selectnoncompliantornotice("notice",_formNKey.currentState.value['booking_date_time'].toString(),_formNKey.currentState.value['booking_time'].toString());
                                }


                              }
                          )
                      ),
                    ),),
                  ],

                ),
              )
            ],
          ),

        ),
    );


  }

  FormBuilder bookingForm(BuildContext context) {

    return FormBuilder(
        key: _formNKey,

        initialValue: {

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


                  Text("What is the requested booking date of Re-inspection? ",textAlign: TextAlign.left,  style: TextStyle(
                      fontFamily: "AVENIRLTSTD",
                      fontSize: 18,
                      color: Color(0xff222222),
                      fontWeight: FontWeight.normal),),

                  FormBuilderDateTimePicker(
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now().subtract(Duration(days: 0)),
                    lastDate: DateTime.now().add(Duration(days: 60)),
                    style: TextStyle(color: Color(0xff222222),fontSize: 20,fontFamily: "AVENIRLTSTD",),

                    attribute: "booking_date_time",
                    validators: [FormBuilderValidators.required()],
                    inputType: InputType.date,
                    format:new DateFormat("dd-MM-yyyy"),
                    decoration: buildInputDecoration(
                        context,
                        "What is the requested booking date and time \nof the inspection? ",
                        "Select Date"),
                  ),

                  sizedbox,
                  Text("What is the requested booking time of the Re-inspection? ",textAlign: TextAlign.left,  style: TextStyle(
                      fontFamily: "AVENIRLTSTD",
                      fontSize: 18,
                      color: Color(0xff222222),
                      fontWeight: FontWeight.normal),),
                  FormBuilderDateTimePicker(

                    style: TextStyle(color: Color(0xff222222),fontSize: 20,fontFamily: "AVENIRLTSTD",),
                    attribute: "booking_time",
                    validators: [FormBuilderValidators.required()],
                    inputType: InputType.time,
                    format: new DateFormat.jm(),
                    decoration: buildInputDecoration(
                        context,
                        "What is the requested booking time of the inspection? ",
                        "Select Time"),


                    //  initialTime: TimeOfDay(hour: 8, minute: 0),
                    // initialValue: DateTime.now(),
                    // readonly: true,
                  ),


                  sizedbox,


                  SizedBox(height: 20,),

                ],
              ),
            )

        ),

        sizedbox,

      ],
    );
  }



//Create the Filtered ListView


}
