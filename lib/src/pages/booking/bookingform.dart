import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:intl/intl.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:poolinspection/src/constants/validators.dart';
import 'package:poolinspection/src/controllers/bookingform_controller.dart';
import 'package:poolinspection/src/elements/BlockButtonWidget.dart';
import 'package:poolinspection/src/elements/drawer.dart';
import 'package:poolinspection/src/elements/dropdown.dart';
import 'package:poolinspection/src/elements/inputdecoration.dart';
import 'package:poolinspection/src/elements/radiobutton.dart';
import 'package:poolinspection/src/elements/textfield.dart';
import 'package:poolinspection/src/elements/textlabel.dart';
import 'package:poolinspection/src/pages/home/MyWebView.dart';
import 'package:poolinspection/src/repository/user_repository.dart' as userRepo;
import 'package:poolinspection/config/app_config.dart' as config;
import 'package:progress_dialog/progress_dialog.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class BookingFormWidget extends StatefulWidget {
  @override
  _BookingFormWidgetState createState() => _BookingFormWidgetState();
}

class _BookingFormWidgetState extends StateMVC<BookingFormWidget> {
  BookingFormController _con;

  _BookingFormWidgetState() : super(BookingFormController()) {
    _con = controller;
  }
  final GlobalKey<ScaffoldState> _scaffoldKey =
      new GlobalKey<ScaffoldState>(); // ADD THIS LINE

  var data;
  bool autoValidate = false;
  bool readOnly = false;
  bool isChecked = false;
  bool isChecked1 = false;

  ValueChanged _onChanged = (val) => print(val);

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey, // ADD THIS LINE
      drawer: drawerData(context, userRepo.user.rolesManage),
      backgroundColor: config.Colors().scaffoldColor(1),
      appBar: AppBar(
        title: Text("Book Inspection",
            style: TextStyle(
                fontFamily: "AVENIRLTSTD",
                // fontSize: 15,
                color: Color(0xff222222),
                fontWeight: FontWeight.normal)),
        centerTitle: true,
        leading: Image.asset(
          "assets/img/app-iconwhite.jpg",
          // fit: BoxFit.cover,
          fit: BoxFit.fitWidth,
        ),
        actions: <Widget>[
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
                     child:_con.bookingLoader ? CircularProgressIndicator()
                         : Container(

                       child: MaterialButton(
                          minWidth: MediaQuery.of(context).size.width/2.5,
                           child:Padding(
                             padding: EdgeInsets.all(10.0),
                             child:  Text(
                               "Submit",
                               style: TextStyle(color: Theme.of(context).primaryColor,fontFamily: "AVENIRLTSTD",fontSize: 18),
                             ),
                           ),
                           color: Theme.of(context).accentColor,
                           onPressed: () {
                             _con.bookingFormKey.currentState.initialValue['send_invoice']="0";
                             print("qwersend_invoice"+_con.bookingFormKey.currentState.value['send_invoice'].toString());

                             _con.sendEnquiry(context);
                           }
                       ),
                     ),
                   ),),
                   Expanded(flex:1,child:Container(

                     alignment: Alignment.bottomCenter,
                     child:_con.bookingLoader1 ?  CircularProgressIndicator()
                         : Container(

                         child: MaterialButton(
                             minWidth: MediaQuery.of(context).size.width/2.5,
                             child: Padding(
                               padding: EdgeInsets.all(10.0),
                               child:Text(
                                 "Send Invoice",
                                 style: TextStyle(color: Theme.of(context).primaryColor,fontFamily: "AVENIRLTSTD",fontSize: 18),
                               ),
                             ),
                             color: Theme.of(context).accentColor,
                             onPressed: () {
                               _con.bookingFormKey.currentState.initialValue['send_invoice']="1";
                               print("qwersend_invoice"+_con.bookingFormKey.currentState.value['send_invoice'].toString());

                               _con.sendEnquiry(context);
                             }
                         )
                     ),
                   ),),
                 ],

               ),
             )
            ],
          ),

        )

    );
  }

  FormBuilder bookingForm(BuildContext context) {
    print(_con.roles);
    return FormBuilder(
      key: _con.bookingFormKey,
      readOnly: readOnly,
      initialValue: {
        "send_invoice":"0",
        "inspector_list": userRepo.inspector.id,
        "notice_regis": "Yes",
//           "owner_land": "kim",
//           "phonenumber": "9000000000",
//           "email_owner": "himanshuesearchlogix2019@gmail.com",
//           "address": "32, B Patel shopping centre",
//           "name_relevant_council": "hello",
//           "email_relevant_council": "councilemail@gmail.com",
//           "swi_pool_spa": "Spa",
//           "permnt_relocate": "Permanent",
//           "certificateofnoncomplianceissued": "No",
//           "poolfoundnoncompliant": "No",
//           "payment_paid": "No",
//           "inspection_fee": "10",
//           // "notice_registration": "",
//           // "company_list": "5",
//           "Council_due_date": DateTime.now(),
//           "booking_date_time": DateTime.now(),
//            "booking_time":DateTime.now(),
//           "council_regis_date": DateTime.now(),
//           "street_road": "543 delhi",
//           "postcode": "1231",
//           "city_suburb": "Mumbai",
//           "municipal_district": "Thane"
      },
      autovalidate: autoValidate,
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
        Text('Notice of Registration Overview',textAlign: TextAlign.left,  style: TextStyle(
            fontFamily: "AVENIRLTSTD",
              fontSize: 16,
            color: Color(0xff222222),
            fontWeight: FontWeight.normal),),
    Card(
    child: Padding(
      padding: const EdgeInsets.all(8.0),
      child:Column(

        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[

          Text(  "Has the Owner registered the pool or spa and with the relevant Council and received a Notice of Registration?",textAlign: TextAlign.left,style: TextStyle(
              fontFamily: "AVENIRLTSTD",
              fontSize: 18,
              color: Color(0xff222222),
              fontWeight: FontWeight.normal),),
          CustomFormBuilderRadio(
            activeColor: Color(0xff222222),
            onChanged: (val) {
              if (val == "No") {
                Alert(
                  context: context,
                  type: AlertType.error,
                  title: "Sorry",
                  desc:
                  "Sorry we cannot proceed as you haven't recieved a Notice of Registration",
                  buttons: [
                    DialogButton(
                      child: Text(
                        "Back",
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                      onPressed: () => Navigator.of(context).pushNamed('/Home'),
                      width: 120,
                    )
                  ],
                ).show();
              }
            },
            attribute: "notice_regis",
            validators: [FormBuilderValidators.required()],
            options: ["Yes", "No"]
                .map((lang) => FormBuilderFieldOption(value: lang))
                .toList(growable: false),
          ),

          sizedbox,
          Text( "The name of the relevant Council that issued the Notice of Registration",textAlign: TextAlign.left,style: TextStyle(
              fontFamily: "AVENIRLTSTD",
              fontSize: 18,
              color: Color(0xff222222),
              fontWeight: FontWeight.normal),),

          CustomFormBuilderTextField(
            style: TextStyle(color: Color(0xff222222),fontSize: 20,fontFamily: "AVENIRLTSTD",),
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

            style: TextStyle(color: Color(0xff222222),fontFamily: "AVENIRLTSTD",fontSize: 20),
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
            hint: Text('Select Regulation',style: TextStyle(color: Color(0xff222222),fontSize: 20),),
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
              fontSize: 16,
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
                    style: TextStyle(color: Color(0xff222222),fontSize: 20,fontFamily: "AVENIRLTSTD",),
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
                  Text('Email of Owner',textAlign: TextAlign.left,  style: TextStyle(
                      fontFamily: "AVENIRLTSTD",
                      fontSize: 18,
                      color: Color(0xff222222),
                      fontWeight: FontWeight.normal),),
                  CustomFormBuilderTextField(
                    style: TextStyle(color: Color(0xff222222),fontSize: 20,fontFamily: "AVENIRLTSTD",),
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
              fontSize: 16,
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
                    style: TextStyle(color:Color(0xff222222),fontFamily: "AVENIRLTSTD",fontSize: 20),
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
                    style: TextStyle(color: Color(0xff222222),fontSize: 20,fontFamily: "AVENIRLTSTD",),
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
                  Text('Postcode',textAlign: TextAlign.left,  style: TextStyle(
                      fontFamily: "AVENIRLTSTD",
                      fontSize: 18,
                      color: Color(0xff222222),
                      fontWeight: FontWeight.normal),),
                  FormBuilderTextField(
                    style: TextStyle(color:Color(0xff222222),fontSize: 20,fontFamily: "AVENIRLTSTD",),
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
                  Text('Is the Pool/Spa permanent or relocatable?',textAlign: TextAlign.left,  style: TextStyle(
                      fontFamily: "AVENIRLTSTD",
                      fontSize: 18,
                      color: Color(0xff222222),
                      fontWeight: FontWeight.normal),),
                  CustomFormBuilderRadio(

                    activeColor: Color(0xff222222),
                    decoration: buildInputDecoration(context,
                        "Is the pool/spa permanent or relocatable?", "yes or no"),
                    attribute: "permnt_relocate",
                    validators: [FormBuilderValidators.required()],
                    options: ["Permanent", "Relocatable"]
                        .map((lang) => FormBuilderFieldOption(value: lang,),)
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
                    style: TextStyle(color: Color(0xff222222),fontSize: 20,fontFamily: "AVENIRLTSTD",),
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

                  Text("What is the requested booking date of the inspection? ",textAlign: TextAlign.left,  style: TextStyle(
                      fontFamily: "AVENIRLTSTD",
                      fontSize: 18,
                      color: Color(0xff222222),
                      fontWeight: FontWeight.normal),),

                  FormBuilderDateTimePicker(
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now().subtract(Duration(days: 0)),
                    lastDate: DateTime(2100),
                    style: TextStyle(color: Color(0xff222222),fontSize: 20,fontFamily: "AVENIRLTSTD",),
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

                  //  initialTime: TimeOfDay(hour: 8, minute: 0),
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
                    style: TextStyle(color: Color(0xff222222),fontSize: 20,fontFamily: "AVENIRLTSTD",),
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

                  sizedbox,
                  FormBuilderCheckbox(

                    attribute: 'accept_terms',
                    initialValue: true,
                    leadingInput: true,

                    label: GestureDetector(
                      onTap: (){
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (BuildContext context) => MyWebView(
                              title:"Inspector Advice" ,
                              selectedUrl:"https://poolinspection.beedevstaging.com/important-advice",
                            )));

                      },
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(2, 14,0, 0),
                        child: Text(

                          "I Hereby Acknowledge & Agree To Important Inspector Advice "
                              .toUpperCase(),
                          style: TextStyle(
                              color: Colors.red,
                              fontFamily:"AVENIRLTSTD",
                              fontWeight: FontWeight.bold,
                              fontSize: 13),
                        ),
                      )
                    ),
                    validators: [
                      FormBuilderValidators.requiredTrue(
                        errorText:
                        "You must accept Important Inspector Advice ",
                      ),
                    ],
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
          style: TextStyle(color:Color(0xff222222), fontFamily: "AVENIRLTSTD",fontSize: 20),
                    attribute: "inspector_list",
                    // initialValue: 'Male',
                    hint: Text('Select Inspectors'),
                    validators: [FormBuilderValidators.required()],
                    items: _con.companyinspectors
                        .map((item) =>
                            DropdownMenuItem(value: item, child: Text("$item")))
                        .toList(),
                  )
            : _con.roles == 1
                ? CustomFormBuilderDropdown(
          style: TextStyle(color:Color(0xff222222), fontFamily: "AVENIRLTSTD",fontSize: 20),
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

      ],
    );
  }

  Container initial() {
    return Container(
      color: Colors.red,
    );
  }

  Container next() {
    return Container(
      color: Colors.blue,
    );
  }
}

