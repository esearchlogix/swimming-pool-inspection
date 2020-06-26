import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:poolinspection/src/constants/validators.dart';
import 'package:poolinspection/src/controllers/bookingform_controller.dart';
import 'package:poolinspection/src/elements/BlockButtonWidget.dart';
import 'package:poolinspection/src/elements/dropdown.dart';
import 'package:poolinspection/src/elements/inputdecoration.dart';
import 'package:poolinspection/src/elements/radiobutton.dart';
import 'package:poolinspection/src/elements/textfield.dart';
import 'package:poolinspection/src/elements/textlabel.dart';
import 'package:poolinspection/config/app_config.dart' as config;
import 'package:poolinspection/src/helpers/connectivity.dart';
import 'package:poolinspection/src/models/errorclasses/errorsignupcompanymodel.dart';

class PreliminaryWidget extends StatefulWidget {
  int jobno = 0;
  PreliminaryWidget(this.jobno);

  @override
  _PreliminaryWidgetState createState() => _PreliminaryWidgetState();
}

class _PreliminaryWidgetState extends StateMVC<PreliminaryWidget> {
  BookingFormController _con;
  _PreliminaryWidgetState() : super(BookingFormController()) {
    _con = controller;
  }
  final GlobalKey<FormBuilderState> _fbKey = GlobalKey<FormBuilderState>();

  var data;

  bool autoValidate = true;

  bool readOnly = false;

  ValueChanged _onChanged = (val) => print(val);

  final council_due_date = TextEditingController();
  final booking_date_time = TextEditingController();
  final booking_time = TextEditingController();
  final council_regis_date = TextEditingController();
  bool isOnline=false;
  StreamSubscription _connectionChangeStream;
  ConnectionStatusSingleton connectionStatus;
   DateTime picked;
  @override
  void initState() {
    // TODO: implement initState
    connectionStatus = ConnectionStatusSingleton.getInstance();


    WidgetsBinding.instance.addPostFrameCallback((_){

      CheckingInternet();

    });
    _con.getPreliminaryData(widget.jobno);
    super.initState();

   // getDate();
  }
  Future CheckingInternet() async
  {

    //  _connectionChangeStream = await connectionStatus.connectionChange.listen(connectionChanged);
    await connectionStatus.checkConnection().then((val) {
      isOnline = val;
    });


  }
// Future<void> getDate() async
// {
//
//   picked = await showDatePicker(
//     context: context,
//     initialDate: DateTime.now(),
//     firstDate: DateTime.now().subtract(Duration(days: 1)),
//     lastDate: DateTime(2100),
//   );
// }

  void connectionChanged(dynamic hasConnection) {   //later use
    setState(() {
      connectionStatus.checkConnection().then((val) {

        isOnline= val;
      });
      // isOffline = !hasConnection;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: config.Colors().scaffoldColor(1),
      appBar: AppBar(
        title: Text("Confirm Preliminary Information",
            style: TextStyle(
                fontFamily: "AVENIRLTSTD",
                 fontSize: 20,
                color: Color(0xff222222),
                fontWeight: FontWeight.normal)),
        leading: IconButton(
            icon: Icon(Icons.backspace),
            onPressed: () => Navigator.pop(context)),
      ),
      body: _con.preliminaryData.preliminaryData == null
          ? Center(child:isOnline?CircularProgressIndicator():
                    SizedBox(
                width: MediaQuery.of(context).size.width * 2 / 3,
                child: RaisedButton(
                    shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(10.0)),
                    color: Colors.redAccent,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(Icons.refresh,color: Colors.white,),
                        Text(" Checking Internet...", style: TextStyle(
                            color: Colors.white,
                            fontFamily: "AVENIRLTSTD",fontSize: 20
                        ),)
                      ],
                    ),
                    onPressed: () async
                    {
                      connectionChanged(
                          await connectionStatus
                              .checkConnection()
                              .then((val) {
                            isOnline=val;
                          }
                          ));
                    }
                ),
              ),
      )
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child:  widget.jobno == 0
                      ? CircularProgressIndicator()
                      // : FutureBuilder(
                      //     future: preliminaryDataFromJobNo(widget.jobno),
                      //     builder: (context, projectSnap) {
                      //       if (projectSnap.connectionState == ConnectionState.none &&
                      //           projectSnap.hasData == null) {
                      //         return CircularProgressIndicator();
                      //       }
                      //       // else if (projectSnap.hasData) {
                      //       BookingPrefil model =
                      //           BookingPrefil.fromJson(projectSnap.data);
                      //       print(model);

                      //       // return Center(child: Text(model.preliminaryData.ownerLand));
                      : Stack(
                children: <Widget>[
                  SingleChildScrollView(
                      child: bookingForm(
                          context, _con.preliminaryData.preliminaryData)),
                 Align(
                   alignment: Alignment.center,
                   child:  Row(
                     mainAxisAlignment: MainAxisAlignment.center,
                     children: <Widget>[
                       Expanded(child: Container(
                         alignment: Alignment.bottomCenter,
                         child: _con.prefilLoader1
                             ?  CircularProgressIndicator()
                             : Container(

                             child: MaterialButton(
                                 minWidth: MediaQuery.of(context).size.width/3.5,
                                 child: Text(
                                   "Save",
                                   style: TextStyle(color: Theme.of(context).primaryColor,fontFamily: "AVENIRLTSTD",
                                     fontSize: 16,),

                                 ),
                                 color: Theme.of(context).accentColor,
                                 onPressed: () {
                                   if(_con.prefilLoader1==false && _con.prefilLoader2==false &&_con.prefilLoader3==false ) {
                                     //    print("vegeta"+_fbKey.currentState.value['booking_time'].toString());
                                     if (_fbKey.currentState.validate()) {
                                       print("Bookingtimegoku" +
                                           _fbKey.currentState
                                               .value['booking_time']
                                               .toString());
                                       //    _fbKey.currentState.value['booking_time'] =_fbKey.currentState.value['booking_time';
                                       _fbKey.currentState
                                           .initialValue['send_invoice'] = "1";
                                       //   print("qwersend_invoice"+_con.bookingFormKey.currentState.value['send_invoice'].toString());
                                       _fbKey.currentState.save();
                                       print("${_fbKey.currentState
                                           .value}  formm");
// print("${pre.toJson()}    preliminary");
// MyApps
                                       _con.confirmToQuestions(
                                           _fbKey.currentState.value, context);
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
                                 })),
                       ),
                       )
                       ,
                       Expanded(child:Container(
                         alignment: Alignment.bottomCenter,
                         child: _con.prefilLoader2
                             ? CircularProgressIndicator()
                             : Container(

                             child:MaterialButton(
                                 minWidth: MediaQuery.of(context).size.width/3.5,
                                 child: Text(
                                   "Send Invoice",
                                   style: TextStyle(color: Theme.of(context).primaryColor,fontFamily: "AVENIRLTSTD",
                                     fontSize: 16,),

                                 ),
                                 color: Theme.of(context).accentColor,
                                 onPressed: () {

    if(_con.prefilLoader1==false && _con.prefilLoader2==false &&_con.prefilLoader3==false ) {
      if (_fbKey.currentState.validate()) {
        _fbKey.currentState.initialValue['send_invoice'] = "2";
        _fbKey.currentState.save();
        print("${_fbKey.currentState.value}  formm");
// print("${pre.toJson()}    preliminary");
// MyApps
        _con.confirmToQuestions(
            _fbKey.currentState.value, context);
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
                                 })),
                       ),),
                       Expanded(child: Container(
                         alignment: Alignment.bottomCenter,
                         child: _con.prefilLoader3
                             ? CircularProgressIndicator()
                             : Container(

                             child: MaterialButton(
                                 minWidth: MediaQuery.of(context).size.width/3.5,
                                 child: Text(
                                   "Confirm",
                                   style: TextStyle(color: Theme.of(context).primaryColor,fontFamily: "AVENIRLTSTD",
                                     fontSize: 16,),

                                 ),
                                 color: Theme.of(context).accentColor,
                                 onPressed: () {

    if(_con.prefilLoader1==false && _con.prefilLoader2==false &&_con.prefilLoader3==false ) {
      if (_fbKey.currentState.validate()) {
        _fbKey.currentState.initialValue['send_invoice'] = "3";
        _fbKey.currentState.save();
        print("${_fbKey.currentState.value}  formm");
// print("${pre.toJson()}    preliminary");
// MyApps
        _con.confirmToQuestions(
            _fbKey.currentState.value, context);
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
                                 })),
                       ),),
                     ],

                   ),
                 )


                ],
              ),


                  // }
                  //     }),

            ),
    );
  }

  FormBuilder bookingForm(BuildContext context, PreliminaryData pre) {
    print("errordateinpreebooking"+pre.councilDueDate.toString());
    return FormBuilder(
      key: _fbKey,
      readOnly: readOnly,
      initialValue: {
        "send_invoice":"1",
        'bookingid': pre.id,
        "owner_land": pre.ownerLand,
        "phonenumber": pre.phonenumber,
        "email_owner": pre.emailOwner,
        "address": pre.address,
        "name_relevant_council": pre.nameRelevantCouncil,
        // "email_relevant_council": pre.emailRelevantCouncil,
        "swi_pool_spa": pre.swiPoolSpa,
        "permnt_relocate": pre.permntRelocate,
        // "certificateofnoncomplianceissued": pre.certificateNonCompliance,
        // "poolfoundnoncompliant": pre.,
        "payment_paid": pre.paymentPaid,
        "inspection_fee": pre.inspectionFee,
        "notice_registration": int.parse(pre.noticeRegistration),
        // "company_list": "5",
        // "Council_due_date": DateTime.now(),
        // "booking_date_time": DateTime.now(),
        // "council_regis_date": DateTime.now(),
        "Council_due_date": DateTime.parse(pre.councilDueDate),
        "booking_date_time": DateTime.parse(pre.bookingDateTime),
        "booking_time":DateTime.parse("2012-02-27 "+pre.bookingTime),
        "council_regis_date": DateTime.parse(pre.councilRegisDate),
        "street_road": pre.street,
        "postcode": pre.postcode,
        "city_suburb": pre.city,
        "recently_inspected":pre.recentlyInspected,
        "municipal_district": pre.district
      },
      autovalidate: autoValidate,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: listView(context, pre),
      ),
    );
  }

  Column listView(BuildContext context, PreliminaryData pre) {
    final sizedbox =
        SizedBox(height: config.App(context).appVerticalPadding(2));
    return Column(

      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('Notice of Registration Overview',textAlign: TextAlign.left,  style: TextStyle(
            fontFamily: "AVENIRLTSTD",
              fontSize: 18,
            color: Color(0xff222222),
            fontWeight: FontWeight.normal),),
        Card(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child:Column(

                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[

                  Text( "The name of the relevant Council that issued the Notice of Registration",textAlign: TextAlign.left,style: TextStyle(
                      fontFamily: "AVENIRLTSTD",
                      fontSize: 18,
                      color: Color(0xff222222),
                      fontWeight: FontWeight.normal),),

                  CustomFormBuilderTextField(
                    textInputAction: TextInputAction.done,
                    attribute: "name_relevant_council",
                    decoration: buildInputDecoration(
                        context,
                        "The name of the relevant Council that issued \nthe Notice of Registration",
                        "Enter Council's Name"),
                    keyboardType: TextInputType.text,
                    validators: [
                      // FormBuilderValidators.min(3),
                      FormBuilderValidators.max(20),
                      CustomFormBuilderValidators.charOnly(),
                      FormBuilderValidators.required()
                    ],
                  ),


                  sizedbox,
                  Text( "What is the date of construction of the pool in the Council Registration",textAlign: TextAlign.left,style: TextStyle(
                      fontFamily: "AVENIRLTSTD",
                      fontSize: 18,
                      color: Color(0xff222222),
                      fontWeight: FontWeight.normal),),

                  FormBuilderDateTimePicker(
                    style: TextStyle(color:Color(0xff222222),     fontFamily: "AVENIRLTSTD",
                      fontSize: 20,),

                    controller: _con.council_regis_date,
                    attribute: "council_regis_date",
                    inputType: InputType.date,
                    validators: [FormBuilderValidators.required()],
                    format:new DateFormat("dd-MM-yyyy"),
                    decoration: buildInputDecoration(
                        context,
                        "What is the date of construction of the pool \nin the Council Registration",
                        "Select Date"),
                  ),


                  sizedbox,
                  Text( "Select compliance Standard specified by council",textAlign: TextAlign.left,style: TextStyle(
                      fontFamily: "AVENIRLTSTD",
                      fontSize: 18,
                      color: Color(0xff222222),
                      fontWeight: FontWeight.normal),),
                  CustomFormBuilderDropdown(
                    style: TextStyle(     fontFamily: "AVENIRLTSTD",
                      fontSize: 20,),
                    attribute: "notice_registration",
                    // initialValue: 'Male',
                    hint: Text('Select Regulation',style: TextStyle(color: Color(0xff222222)),),
                    validators: [FormBuilderValidators.required()],
                    items: _con.regulationdata
                        .map((item) => DropdownMenuItem(

                        value: item['regulation_id'],
                        child: Text("${item['regulation_name']}",style: TextStyle(fontFamily: "AVENIRLTSTD",  fontSize: 18,color: Color(0xff222222)),)))
                        .toList(),
                  ),
                  SizedBox(height: 20,),
                ],
              ),
            )

        ),
        SizedBox(height: 20,),
        Text('Owner Details',textAlign: TextAlign.left,  style: TextStyle(
            fontFamily: "AVENIRLTSTD",
              fontSize: 18,
            color: Color(0xff222222),
            fontWeight: FontWeight.normal),),
        Card(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child:Column(

                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('Name of Owner of land',textAlign: TextAlign.left,  style: TextStyle(
                      fontFamily: "AVENIRLTSTD",
                      fontSize: 18,
                      color: Color(0xff222222),
                      fontWeight: FontWeight.normal),),
                  CustomFormBuilderTextField(
                    textInputAction: TextInputAction.done,
                    attribute: "owner_land",
                    decoration: buildInputDecoration(context, "", "Enter Name"),
                    validators: [
                      FormBuilderValidators.required(),
                      FormBuilderValidators.maxLength(20),
                      CustomFormBuilderValidators.charOnly(),
                    ],
                  ),
                  sizedbox,
                  Text('Contact phone number',textAlign: TextAlign.left,  style: TextStyle(
                      fontFamily: "AVENIRLTSTD",
                      fontSize: 18,
                      color: Color(0xff222222),
                      fontWeight: FontWeight.normal),),
                  CustomFormBuilderTextField(
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.done,
                    attribute: "phonenumber",
                    inputFormatters: [WhitelistingTextInputFormatter.digitsOnly],
                    maxLength: 10,
                    decoration: buildInputDecoration(
                        context, "Contact phone number", "Enter Phone Number"),
                    validators: [
                      FormBuilderValidators.required(),
                      FormBuilderValidators.minLength(10),
                      FormBuilderValidators.numeric(),
                    ],
                  ),
                  sizedbox,
                  Text("Email of Owner",textAlign: TextAlign.left,  style: TextStyle(
                      fontFamily: "AVENIRLTSTD",
                      fontSize: 18,
                      color: Color(0xff222222),
                      fontWeight: FontWeight.normal),),
                  CustomFormBuilderTextField(
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.done,
                    attribute: "email_owner",
                    decoration: buildInputDecoration(
                        context, "Email of Owner", "Enter Owner Email Address"),
                    validators: [
                      FormBuilderValidators.required(),
                      FormBuilderValidators.email(),
                    ],
                  ),
                  sizedbox,

                ],
              ),
            )

        ),

        SizedBox(height: 20,),
        Text('Pool/Spa Details',textAlign: TextAlign.left,  style: TextStyle(
            fontFamily: "AVENIRLTSTD",
              fontSize: 18,
            color: Color(0xff222222),
            fontWeight: FontWeight.normal),),
        Card(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child:Column(

                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('Street/Road',textAlign: TextAlign.left,  style: TextStyle(
                      fontFamily: "AVENIRLTSTD",
                      fontSize: 18,
                      color: Color(0xff222222),
                      fontWeight: FontWeight.normal),),
                  FormBuilderTextField(
                    style: TextStyle(color:Color(0xff222222),  fontFamily: "AVENIRLTSTD",
                      fontSize: 20,),
                    // maxLines: 3,
                    attribute: "street_road",
                    decoration:
                    buildInputDecoration(context, "Address", "Enter Street/Road"),
                    keyboardType: TextInputType.text,
                    validators: [
                      CustomFormBuilderValidators.addressOnly(),
                      FormBuilderValidators.maxLength(50),
                      FormBuilderValidators.required()
                    ],
                  ),


                  sizedbox,
                  Text('City/Suburb',textAlign: TextAlign.left,  style: TextStyle(
                      fontFamily: "AVENIRLTSTD",
                      fontSize: 18,
                      color: Color(0xff222222),
                      fontWeight: FontWeight.normal),),
                  FormBuilderTextField(
                    style: TextStyle(color:Color(0xff222222),fontSize: 20,    fontFamily: "AVENIRLTSTD",),
                    // maxLines: 3,
                    attribute: "city_suburb",
                    decoration:
                    buildInputDecoration(context, "Address", "Enter City/Suburb"),
                    keyboardType: TextInputType.text,
                    validators: [
                      CustomFormBuilderValidators.charOnly(),
                      FormBuilderValidators.maxLength(20),
                      FormBuilderValidators.required()
                    ],
                  ),


                  sizedbox,
                  Text('Post Code',textAlign: TextAlign.left,  style: TextStyle(
                      fontFamily: "AVENIRLTSTD",
                      fontSize: 18,
                      color: Color(0xff222222),
                      fontWeight: FontWeight.normal),),
                  FormBuilderTextField(
                    style: TextStyle(color:Color(0xff222222),    fontFamily: "AVENIRLTSTD",fontSize: 20),
                    inputFormatters: [WhitelistingTextInputFormatter.digitsOnly],
                    maxLength: 4,
                    attribute: "postcode",
                    decoration:
                    buildInputDecoration(context, "Address", "Enter Postcode"),
                    keyboardType: TextInputType.number,
                    validators: [
                      FormBuilderValidators.numeric(),
                      FormBuilderValidators.maxLength(4),
                      FormBuilderValidators.minLength(4),
                      FormBuilderValidators.required()
                    ],
                  ),


                  sizedbox,
                  Text('Site Details',textAlign: TextAlign.left,  style: TextStyle(
                      fontFamily: "AVENIRLTSTD",
                      fontSize: 18,
                      color: Color(0xff222222),
                      fontWeight: FontWeight.normal),),
                  CustomFormBuilderRadio(

                    activeColor: Color(0xff222222),
                    decoration: buildInputDecoration(

                        context, "Is it a swimming pool or spa?", "yes or no"),
                    attribute: "swi_pool_spa",
                    validators: [FormBuilderValidators.required()],
                    options: ["Swimming Pool", "Spa"]
                        .map((lang) => FormBuilderFieldOption(value: lang))
                        .toList(growable: false),
                  ),



                  sizedbox,
                  Text('Is the Pool/Spa permanent or relocatable',textAlign: TextAlign.left,  style: TextStyle(
                      fontFamily: "AVENIRLTSTD",
                      fontSize: 18,
                      color: Color(0xff222222),
                      fontWeight: FontWeight.normal),),
                  CustomFormBuilderRadio(

                    activeColor: Color(0xff222222),
                    decoration: buildInputDecoration(context,
                        "Is the pool/spa permanent or relocatable?", "yes or no",),
                    attribute: "permnt_relocate",
                    validators: [FormBuilderValidators.required()],
                    options: ["Permanent", "Relocatable"]
                        .map((lang) => FormBuilderFieldOption(value: lang))
                        .toList(growable: false),
                  ),
                  sizedbox,
                  Text('Has the Swimming Pool/Spa Recently Been Inspected?',textAlign: TextAlign.left,  style: TextStyle(
                      fontFamily: "AVENIRLTSTD",
                      fontSize: 18,
                      color: Color(0xff222222),
                      fontWeight: FontWeight.normal),),
                  CustomFormBuilderRadio(

                    activeColor: Color(0xff222222),
                    decoration: buildInputDecoration(context,
                        "Has the Swimming Pool/Spa Recently Been Inspected?", "yes or no"),
                    attribute: "recently_inspected",
                    validators: [FormBuilderValidators.required()],
                    options: ["Yes", "No"]
                        .map((lang) => FormBuilderFieldOption(value: lang,),)
                        .toList(growable: false),
                  ),

                  sizedbox,

                  Text("When is the Compliance Certificate required by Council due?",textAlign: TextAlign.left,  style: TextStyle(
                      fontFamily: "AVENIRLTSTD",
                      fontSize: 18,
                      color: Color(0xff222222),
                      fontWeight: FontWeight.normal),),

                  FormBuilderDateTimePicker(
                    style: TextStyle(color:Color(0xff222222),    fontFamily: "AVENIRLTSTD",fontSize: 20),
                    textInputAction: TextInputAction.done,
                    controller: _con.council_due_date,
                    attribute: "Council_due_date",
                    inputType: InputType.date,
                    format:new DateFormat("dd-MM-yyyy"),
                    validators: [FormBuilderValidators.required()],
                    decoration: buildInputDecoration(
                        context,
                        "When is the Compliance Certificate required \nby Council due?",
                        "Select Date"),
                  ),



                  sizedbox,
                  // textLabel("Was a the Pool recently found to be \nnon-Compliant?"),
                  // CustomFormBuilderRadio(
                  //   decoration: buildInputDecoration(context,
                  //       "Was a the Pool recently found to be non-Compliant", "yes or no"),
                  //   attribute: "certificateofnoncomplianceissued",
                  //   validators: [FormBuilderValidators.required()],
                  //   options: ["Yes", "No"]
                  //       .map((lang) => FormBuilderFieldOption(value: lang))
                  //       .toList(growable: false),
                  // ),
                  // sizedbox,

                  Text("What is the requested booking date  of the inspection? ",textAlign: TextAlign.left,  style: TextStyle(
                      fontFamily: "AVENIRLTSTD",
                      fontSize: 18,
                      color: Color(0xff222222),
                      fontWeight: FontWeight.normal),),

                  FormBuilderDateTimePicker(
                    style: TextStyle(color:Color(0xff222222), fontFamily: "AVENIRLTSTD",
                      fontSize: 20,),
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now().subtract(Duration(days: 0)),
                    lastDate: DateTime(2100),
                    controller: _con.booking_date_time,
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

                  Text("What is the requested booking time of the inspection? ",textAlign: TextAlign.left,  style: TextStyle(
                      fontFamily: "AVENIRLTSTD",
                      fontSize: 18,
                      color: Color(0xff222222),
                      fontWeight: FontWeight.normal),),

                  FormBuilderDateTimePicker(

                    style: TextStyle(color: Color(0xff222222),fontSize: 20,fontFamily: "AVENIRLTSTD",),
                    controller: _con.booking_time,
                    attribute: "booking_time",
                    validators: [FormBuilderValidators.required()],
                    inputType: InputType.time,
                    format: new DateFormat.jm(),
                    decoration: buildInputDecoration(
                        context,
                        "What is the requested booking time of the inspection? ",
                        "Select Time"),
                    onChanged: _onChanged,

                  //  initialTime: TimeOfDay(hour: int.parse(pre.bookingTime.toString().substring(0,1)), minute: int.parse(pre.bookingTime.toString().substring(3,4))),
                    // initialValue: DateTime.now(),
                    // readonly: true,
                  ),


                  sizedbox,
                  Text("What is the Fee for this inspection?",textAlign: TextAlign.left,  style: TextStyle(
                      fontFamily: "AVENIRLTSTD",
                      fontSize: 18,
                      color: Color(0xff222222),

                      fontWeight: FontWeight.normal),),

                  CustomFormBuilderTextField(
                    style: TextStyle(color:Color(0xff222222), fontFamily: "AVENIRLTSTD",
                      fontSize: 20,),
                    inputFormatters: [WhitelistingTextInputFormatter.digitsOnly],
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.done,
                    attribute: "inspection_fee",
                    decoration: buildInputDecoration(context,
                        "What is the Fee for this inspection?", "Enter fee Amount"),
                    validators: [
                      FormBuilderValidators.required(),
                      FormBuilderValidators.numeric(),
                    ],
                  ),


                  sizedbox,
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

                  Visibility(
                    visible: false,
                    child:FormBuilderTextField(
                      attribute: "send_invoice",
                    ),
                  ),
                  SizedBox(height: 20,),

                ],
              ),
            )

        ),





        _con.roles == 2
            ? _con.companyinspectors.length == 0
            ? Text("No Inspectors to assign task")
            : CustomFormBuilderDropdown(
          style: TextStyle(color:Color(0xff222222)),
          attribute: "inspector_list",
          // initialValue: 'Male',
          hint: Text('Select Inspectors'),
          validators: [FormBuilderValidators.required()],
          items: _con.companyinspectors
              .map((item) =>
              DropdownMenuItem(value: item, child: Text("$item",style: TextStyle(color: Color(0xff222222)),)))
              .toList(),
        )
            : _con.roles == 1
            ? CustomFormBuilderDropdown(
          attribute: "inspector_list",
          // initialValue: 'Male',
          hint: Text('Select Inspectors'),
          validators: [FormBuilderValidators.required()],
          items: _con.companyinspectors
              .map((item) =>
              DropdownMenuItem(value: item, child: Text("$item")))
              .toList(),
        )
            : Container(),
        sizedbox,
        sizedbox,

      ],
    );
  }
}


