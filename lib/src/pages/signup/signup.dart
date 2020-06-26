import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:poolinspection/res/string.dart';
import 'package:poolinspection/src/constants/validators.dart';
import 'package:poolinspection/src/controllers/user_controller.dart';
import 'package:poolinspection/src/elements/BlockButtonWidget.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:poolinspection/config/app_config.dart' as config;
import 'package:poolinspection/src/elements/inputdecoration.dart';
import 'package:poolinspection/src/elements/maskedtextformater.dart';
import 'package:poolinspection/src/elements/radiobutton.dart';
import 'package:poolinspection/src/elements/textlabel.dart';
import 'package:poolinspection/src/models/company_fields.dart';
import 'package:poolinspection/src/models/route_argument.dart';
import 'package:poolinspection/src/models/signupfields.dart';
import 'package:poolinspection/src/pages/home/MyWebView.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class SignUpWidget extends StatefulWidget {
  @override
  _SignUpWidgetState createState() => _SignUpWidgetState();
}

class _SignUpWidgetState extends StateMVC<SignUpWidget> {
  final uploadTextStyle = TextStyle(color: Colors.blueGrey);
  UserController _con;
  _SignUpWidgetState() : super(UserController()) {
    _con = controller;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
            key: _con.scaffoldKey,
            resizeToAvoidBottomPadding: true,
            body: Padding(
              padding: const EdgeInsets.all(8.0),
              child: buildListInspectorView(context),
            ));
  }

  Row accountFilter(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Radio(
          groupValue: _con.groupValue,
          value: 0,
          onChanged: (index) {
            setState(() => _con.groupValue = index);
            _con.signUpKey.currentState.reset();
          },
          activeColor: Theme.of(context).accentColor,
        ),
        Text(
          "Individual",
          style: TextStyle(fontSize: 18.0,
            fontFamily: "AVENIRLTSTD",),
        ),
        Radio(
          groupValue: _con.groupValue,
          value: 1,
          onChanged: (index) {
            setState(() => _con.groupValue = index);
            _con.signUpKey.currentState.reset();

            //open  individual form
          },
          activeColor: Theme.of(context).accentColor,
        ),
        Text("Company", style: TextStyle(fontSize: 18.0,
          fontFamily: "AVENIRLTSTD",)),
      ],
    );
  }

  FormBuilder buildListInspectorView(BuildContext context) {
    final sizedbox =
        SizedBox(height: config.App(context).appVerticalPadding(2));
    return FormBuilder(
      key: _con.signUpKey,
      // initialValue: {
      // 'inspector_abn': "12312312312",
      // 'inspector_address': "32, b patel shopping centre",
      // 'first_name': "Sumit",
      // 'company_name': "Beedev",
      // 'last_name': "Sumit",
      // 'email': 'royal@gmail.com',
      // "mobile_no": "4182475355",
      // "registration_number": "4182475355",
      // 'username': "sumeet221",
      // 'password': 'Eruasion1!',
      // 'password_confirmation': "Eruasion1!",
      // 'card_number': "8523697412561111",
      // 'card_cvv': '856',
      // 'card_expiry_month': "12",
      // 'card_expiry_year': "2034",
      // "company_abn": "12312312312",
      // "company_address": "32, b patel shopping centre",
      // "company_logo": "34",
      // "card_type": "1",
      // "Street":"street",
      // "Postcode":"1231",
      // "City":"Mumbai",
      // "District":"Thane"
      // },
      autovalidate: _con.autoValidate,
      child: SingleChildScrollView(
        child: Column(
            // physics: NeverScrollableScrollPhysics(),
            children: <Widget>[
              Container(
                height: config.App(context).appHeight(20),
                child: Image.asset("assets/img/logo.png"),
              ),
              Text(
                "Sign Up",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.w500,
                  fontFamily: "AVENIRLTSTD",)
                    .merge(TextStyle(
                        color: Color(0xff222222), fontWeight: FontWeight.w700)),
              ),
              SizedBox(
                height: 10,
              ),
              accountFilter(context),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child:Column(

                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
              _con.groupValue == 1 ? sizedbox : Container(),
              _con.groupValue == 1 ? textLabel("Company Name") : Container(),

              _con.groupValue == 1
                  ? FormBuilderTextField(
                style: TextStyle(color: Color(0xff222222),fontSize: 20,fontFamily: "AVENIRLTSTD",),
                      attribute: "company_name",
                      decoration: buildInputDecoration(
                          context, "Company Name", "Enter Company Name"),
                      keyboardType: TextInputType.text,
                      validators: [
                        CustomFormBuilderValidators.charOnly(),
                        FormBuilderValidators.minLength(3),
                        FormBuilderValidators.maxLength(20),
                        FormBuilderValidators.required()
                      ],
                    )
                  : Container(),
              sizedbox,


              _con.groupValue == 0 ? textLabel("First Name") : Container(),
              _con.groupValue == 0
                  ? FormBuilderTextField(
                style: TextStyle(color: Color(0xff222222),fontSize: 20,
                  fontFamily: "AVENIRLTSTD",),
                      attribute: "first_name",
                      decoration: buildInputDecoration(
                          context, "First Name", "Enter First Name"),
                      keyboardType: TextInputType.text,
                      validators: [
                        FormBuilderValidators.min(3),
                        // FormBuilderValidators.pattern(r'^\D+$'),
                        CustomFormBuilderValidators.charOnly(),
                        FormBuilderValidators.maxLength(20),
                        FormBuilderValidators.required(),
                        FormBuilderValidators.minLength(3),
                      ],
                    )
                  : Container(),
              _con.groupValue == 0 ? sizedbox : Container(),
              _con.groupValue == 0 ? textLabel("Last Name") : Container(),
              _con.groupValue == 0
                  ? FormBuilderTextField(
                style: TextStyle(color: Color(0xff222222),fontSize: 20,
                  fontFamily: "AVENIRLTSTD",),
                      attribute: "last_name",
                      decoration: buildInputDecoration(
                          context, "Last Name", "Enter Last Name"),
                      keyboardType: TextInputType.text,
                      validators: [
                        CustomFormBuilderValidators.charOnly(),
                        FormBuilderValidators.minLength(3),
                        FormBuilderValidators.maxLength(20),
                        FormBuilderValidators.required()
                      ],
                    )
                  : Container(),
              _con.groupValue == 0 ? sizedbox : Container(),
              _con.groupValue == 0 ? textLabel("ABN Number") : Container(),

              _con.groupValue == 0
                  ? FormBuilderTextField(
                style: TextStyle(color: Color(0xff222222),fontSize: 20,
                  fontFamily: "AVENIRLTSTD",),
                      attribute: "inspector_abn",
                      maxLength: 11,
                      inputFormatters: [
                        WhitelistingTextInputFormatter.digitsOnly
                      ],
                      decoration: buildInputDecoration(
                          context, "ABN Number I", "Enter ABN Number"),
                      keyboardType: TextInputType.number,
                      validators: [
                        FormBuilderValidators.maxLength(11),
                        FormBuilderValidators.minLength(11),
                        FormBuilderValidators.numeric(),
                        FormBuilderValidators.required()
                      ],
                    )
                  : Container(),
              _con.groupValue == 0 ? sizedbox : Container(),
              _con.groupValue == 1 ? textLabel("Abn Number ") : Container(),
              _con.groupValue == 1
                  ? FormBuilderTextField(
                style: TextStyle(color: Color(0xff222222),fontSize: 20,
                  fontFamily: "AVENIRLTSTD",),
                      maxLength: 11,
                      inputFormatters: [
                        WhitelistingTextInputFormatter.digitsOnly
                      ],
                      attribute: "company_abn",
                      decoration: buildInputDecoration(
                          context, "ABN Number C", "Enter ABN Number"),
                      keyboardType: TextInputType.number,
                      validators: [
                        FormBuilderValidators.maxLength(11),
                        FormBuilderValidators.minLength(11),
                        FormBuilderValidators.numeric(),
                        FormBuilderValidators.required()
                      ],
                    )
                  : Container(),
              SizedBox(height: 7,),
                        Text("Is the GST Number Applicable or Not?",textAlign: TextAlign.left,  style: TextStyle(
                            fontFamily: "AVENIRLTSTD",
                            fontSize: 19,
                            color: Color(0xff222222),
                            fontWeight: FontWeight.bold),),
              CustomFormBuilderRadio(

                activeColor: Color(0xff222222),

                decoration: buildInputDecoration(context,
                    "Is the GST Number Applicable or Not?", "yes or no",),
                attribute: "tax_applicable",
                validators: [FormBuilderValidators.required()],
                options: ["Yes", "No"]
                    .map((lang) => FormBuilderFieldOption(value: lang))
                    .toList(growable: false),
              ),
              sizedbox,
              _con.groupValue == 1
                  ? _con.photoImage == null
                      ? ListTile(

                          title:
                              Text('No Logo selected.', style: uploadTextStyle),
                          trailing: Container(
                            padding: EdgeInsets.all(5),
                            child: RaisedButton(
                              color: Theme.of(context).accentColor,
                              onPressed: () =>
                                  getImage(_con.photoImage).then((val) {
                                setState(() {
                                  _con.photoImage = val;

                                });
                              }),
                              child: Text("Select File",
                                  style: TextStyle(color: Colors.white)),
                            ),
                          ),
                        )
                      : ListTile(
                          leading: Image.file(_con.photoImage),
                          title: Text(
                            ' Logo selected',
                            style: uploadTextStyle,
                          ),
                          trailing: Container(
                            padding: EdgeInsets.all(5),
                            child: RaisedButton(
                              color: Theme.of(context).accentColor,
                              onPressed: () =>
                                  getImage(_con.photoImage).then((val) {
                                setState(() {
                                  _con.photoImage = val;

                                });
                              }),
                              child: Text("Change File",
                                  style: TextStyle(color: Colors.white)),
                            ),
                          ),
                        )
                  : Container(),
              _con.groupValue == 0
                  ? _con.photoImage == null
                      ? ListTile(
                          title:
                              Text('No Logo selected.', style: uploadTextStyle),
                          trailing: Container(
                            padding: EdgeInsets.all(5),
                            child: RaisedButton(
                              color: Theme.of(context).accentColor,
                              onPressed: () =>
                                  getImage(_con.photoImage).then((val) {
                                setState(() {
                                  _con.photoImage = val;
                                });
                              }),
                              child: Text("Select File",
                                  style: TextStyle(color: Colors.white)),
                            ),
                          ),
                        )
                      : ListTile(
                          leading: Image.file(_con.photoImage),
                          title: Text(
                            '',
                            style: uploadTextStyle,
                          ),
                          trailing: Container(
                            padding: EdgeInsets.all(5),
                            child: RaisedButton(
                              color: Theme.of(context).accentColor,
                              onPressed: () =>
                                  getImage(_con.photoImage).then((val) {
                                setState(() {
                                  _con.photoImage = val;
                                });
                              }),
                              child: Text("Change Photo",
                                  style: TextStyle(color: Colors.white)),
                            ),
                          ),
                        )
                  : Container(),
              Padding(
                padding: EdgeInsets.all(3.0),
                child: Text("Note: Image format jpeg,png & jpg only.Dimension should 150*150",style: TextStyle(color:Color(0xff222222),fontSize: 14, fontFamily: "AVENIRLTSTD"),),
                  
              ),

  ]
    ),
    ),
    ),







              sizedbox,
              // textLabel("Address"),

              // _con.groupValue == 0
              //     ? FormBuilderTextField(
              //         maxLines: 3,
              //         attribute: "inspector_address",
              //         decoration: buildInputDecoration(
              //             context, "Address", "Enter Address"),
              //         keyboardType: TextInputType.text,
              //         validators: [
              //           // FormBuilderValidators.min(3),
              //           FormBuilderValidators.maxLength(200),
              //           FormBuilderValidators.required()
              //         ],
              //       )
              //     : FormBuilderTextField(
              //         maxLines: 3,
              //         attribute: "company_address",
              //         decoration: buildInputDecoration(
              //             context, "Address", "Enter Address"),
              //         keyboardType: TextInputType.text,
              //         validators: [
              //           FormBuilderValidators.maxLength(200),
              //           FormBuilderValidators.required()
              //         ],
              //       ),

    Card(
    child: Padding(
    padding: const EdgeInsets.all(10.0),
    child:Column(

    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
              textLabel("Street"),
              FormBuilderTextField(
                style: TextStyle(color: Color(0xff222222),fontSize: 20,
                  fontFamily: "AVENIRLTSTD",),
                // maxLines: 3,
                attribute: "Street",
                decoration:
                    buildInputDecoration(context, "Address", "Enter Street"),
                keyboardType: TextInputType.text,
                validators: [
                  // CustomFormBuilderValidators.charOnly(),
                  FormBuilderValidators.maxLength(50),
                  FormBuilderValidators.required()
                ],
              ),
              sizedbox,
              textLabel("City"),

              FormBuilderTextField(
                style: TextStyle(color: Color(0xff222222),fontSize: 20,
                  fontFamily: "AVENIRLTSTD",),
                // maxLines: 3,
                attribute: "City",
                decoration:
                    buildInputDecoration(context, "Address", "Enter City"),
                keyboardType: TextInputType.text,
                validators: [
                  CustomFormBuilderValidators.addressOnly(),
                  FormBuilderValidators.maxLength(20),
                  FormBuilderValidators.required()
                ],
              ),
              // sizedbox,
              // textLabel("District"),

              // FormBuilderTextField(
              //   // maxLines: 3,
              //   attribute: "District",
              //   decoration:
              //       buildInputDecoration(context, "Address", "Enter District"),
              //   keyboardType: TextInputType.text,
              //   validators: [
              //     CustomFormBuilderValidators.charOnly(),
              //     FormBuilderValidators.maxLength(20),
              //     FormBuilderValidators.required()
              //   ],
              // ),
              sizedbox,
              textLabel("Postcode"),

              FormBuilderTextField(
                style: TextStyle(color: Color(0xff222222),fontSize: 20,
                  fontFamily: "AVENIRLTSTD",),
                inputFormatters: [WhitelistingTextInputFormatter.digitsOnly],
                maxLength: 4,
                attribute: "Postcode",
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
              textLabel("Phone Number"),
              FormBuilderTextField(
                style: TextStyle(color: Color(0xff222222),
                  fontSize: 20,
                  fontFamily: "AVENIRLTSTD",),
                attribute: "mobile_no",
                maxLength: 10,
                inputFormatters: [WhitelistingTextInputFormatter.digitsOnly],
                decoration: buildInputDecoration(
                    context, "Phone Number", "Enter Phone Number"),
                keyboardType: TextInputType.number,
                validators: [
                  FormBuilderValidators.numeric(),
                  FormBuilderValidators.minLength(10),
                  FormBuilderValidators.required()
                ],
              ),



              ],
    ),
    ),
    ),

        sizedbox,


    Card(
    child: Padding(
    padding: const EdgeInsets.all(10.0),
    child:Column(

    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[


              textLabel("Email Address"),
              FormBuilderTextField(
                style: TextStyle(color: Color(0xff222222),
                  fontSize: 20,
                  fontFamily: "AVENIRLTSTD",),
                attribute: "email",
                decoration: buildInputDecoration(
                    context, "Email Address", "Enter Email Address"),
                keyboardType: TextInputType.emailAddress,
                validators: [
                  FormBuilderValidators.email(),
                  FormBuilderValidators.required()
                ],
              ),

              sizedbox,
              textLabel("Password"),
              FormBuilderTextField(
                style: TextStyle(color: Color(0xff222222),fontSize: 20,
                  fontFamily: "AVENIRLTSTD",),
                attribute: "password",
                decoration:
                buildInputDecoration(context, "Password", "Enter Password"),
                keyboardType: TextInputType.text,
                obscureText: true,
                maxLines: 1,
                validators: [
                  // FormBuilderValidators.minLength(8),
                  FormBuilderValidators.maxLength(12),
                  CustomFormBuilderValidators.strongPassCheck(),
                  FormBuilderValidators.required()
                ],
              ),
              SizedBox(height: 2,),
              Align(
                alignment: Alignment.topLeft,
                child:
                Text("Note: Strong Password is required",style: TextStyle(color:Color(0xff222222),fontSize: 14, fontFamily: "AVENIRLTSTD"),),),

              sizedbox,
              sizedbox,
              textLabel("Confirm Password"),
              FormBuilderTextField(
                style: TextStyle(color: Color(0xff222222),fontSize: 20,
                  fontFamily: "AVENIRLTSTD",),
                attribute: "password_confirmation",
                decoration: buildInputDecoration(
                    context, "Confirm Password", "Enter Confirm Password"),
                keyboardType: TextInputType.text,
                obscureText: true,
                maxLines: 1,
                validators: [
                  CustomFormBuilderValidators.strongPassCheck(),
                  FormBuilderValidators.maxLength(12),
                  FormBuilderValidators.required()
                ],
              ),
              SizedBox(
                height: 10,
              ),
              // _con.groupValue == 0
              //     ? _con.signatureImage == null
              //         ? ListTile(
              //             title: Text('No Signature selected.',
              //                 style: uploadTextStyle),
              //             trailing: Container(
              //               padding: EdgeInsets.all(5),
              //               child: RaisedButton(
              //                 color: Theme.of(context).accentColor,
              //                 onPressed: () =>
              //                     getImage(_con.signatureImage).then((val) {
              //                   setState(() {
              //                     _con.signatureImage = val;
              //                   });
              //                 }),
              //                 child: Text("Select File",
              //                     style: TextStyle(color: Colors.white)),
              //               ),
              //             ),
              //           )
              //         : ListTile(
              //             leading: Image.file(_con.signatureImage),
              //             title: Text(
              //               ' Signature selected',
              //               style: uploadTextStyle,
              //             ),
              //             trailing: Container(
              //               padding: EdgeInsets.all(5),
              //               child: RaisedButton(
              //                 color: Theme.of(context).accentColor,
              //                 onPressed: () =>
              //                     getImage(_con.signatureImage).then((val) {
              //                   setState(() {
              //                     _con.signatureImage = val;
              //                   });
              //                 }),
              //                 child: Text("Change File",
              //                     style: TextStyle(color: Colors.white)),
              //               ),
              //             ),
              //           )
              //     : Container(),
              sizedbox,
              textLabel(" VBA Practitioner Number"),
              FormBuilderTextField(
                style: TextStyle(color: Color(0xff222222),fontSize: 20,
                  fontFamily: "AVENIRLTSTD",),
                maxLength: 10,
                inputFormatters: [WhitelistingTextInputFormatter.digitsOnly],
                attribute: "registration_number",
                decoration: buildInputDecoration(context, "Practitioner Number",
                    "Enter Practitioner Number"),
                keyboardType: TextInputType.number,
                validators: [
                  CustomFormBuilderValidators.regNumber(),
                  FormBuilderValidators.required(),
                  FormBuilderValidators.maxLength(12),
                ],
              ),
              // sizedbox,
              // textLabel("Username"),
              // FormBuilderTextField(
              //   attribute: "username",
              //   decoration:
              //       buildInputDecoration(context, "Username", "Enter Username"),
              //   keyboardType: TextInputType.text,
              //   validators: [
              //     FormBuilderValidators.minLength(3),
              //     FormBuilderValidators.max(20),
              //     FormBuilderValidators.required()
              //   ],
              // ),
      FormBuilderCheckbox(

        attribute: 'accept_terms',
        initialValue: false,
        leadingInput: true,
        label: GestureDetector(
          onTap: (){
            Navigator.of(context).push(MaterialPageRoute(
                builder: (BuildContext context) => MyWebView(
                  title:"Terms And Conditions" ,
                  selectedUrl:"https://poolinspection.beedevstaging.com/terms-condition",
                )));
          },
          child:Text(

          "I have read and agree to the terms & conditions"
              .toUpperCase(),
          style: TextStyle(
              color: Colors.red,
              fontFamily:"AVENIRLTSTD",
              fontWeight: FontWeight.bold,
              fontSize: 13),
        ),
        ),
        validators: [
          FormBuilderValidators.requiredTrue(
            errorText:
            "You must accept terms and conditions to continue",
          ),
        ],
      ),
           ],
    ),),
    ),

              sizedbox,
//              textLabel("Card Number"),
//              FormBuilderTextField(
//                style: TextStyle(color: Color(0xff222222)),
//                attribute: "card_number",
//                // inputFormatters: [
//                //   MaskedTextInputFormatter(
//                //     mask: 'xxxx-xxxx-xxxx-xxxx',
//                //     separator: '-',
//                //   ),
//                // ],
//                // controller: _cardNumberController,
//                inputFormatters: [WhitelistingTextInputFormatter.digitsOnly],
//                maxLength: 16,
//                keyboardType: TextInputType.number,
//                decoration: buildInputDecoration(
//                    context, "Card Number", "852369741256"),
//                validators: [
//                  // FormBuilderValidators.creditCard(),
//                  FormBuilderValidators.maxLength(16),
//                  FormBuilderValidators.numeric(),
//
//                  FormBuilderValidators.required(),
//                  FormBuilderValidators.minLength(16),
//                ],
//              ),
//              sizedbox,
//              textLabel("CVV Number"),
//              FormBuilderTextField(
//                style: TextStyle(color: Color(0xff222222)),
//                attribute: "card_cvv",
//                inputFormatters: [WhitelistingTextInputFormatter.digitsOnly],
//
//                maxLength: 4,
//                // controller: _cvvCodeController,
//                keyboardType: TextInputType.number,
//                decoration: buildInputDecoration(context, "CVV Number", "123"),
//                // inputFormatters: [
//                //   MaskedTextInputFormatter(
//                //     mask: 'xxxx',
//                //     separator: '-',
//                //   ),
//                // ],
//                validators: [
//                  FormBuilderValidators.min(3),
//                  FormBuilderValidators.numeric(),
//
//                  // FormBuilderValidators.minLength(3),
//                  FormBuilderValidators.required()
//                ],
//              ),
//              // Row(
//              //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//              //   children: <Widget>[
//              FormBuilderTextField(
//                style: TextStyle(color: Color(0xff222222)),
//                inputFormatters: [WhitelistingTextInputFormatter.digitsOnly],
//
//                attribute: "card_expiry_month",
//                maxLength: 2,
//                // controller: _expiryDateController,
//                keyboardType: TextInputType.number,
//                decoration: buildInputDecoration(context, "Month", "MM"),
//                validators: [
//                  FormBuilderValidators.min(1),
//                  FormBuilderValidators.max(12),
//                  FormBuilderValidators.minLength(2),
//                  FormBuilderValidators.numeric(),
//                ],
//              ),
//              FormBuilderTextField(
//                style: TextStyle(color: Color(0xff222222)),
//                inputFormatters: [WhitelistingTextInputFormatter.digitsOnly],
//                attribute: "card_expiry_year",
//                maxLength: 4,
//                // controller: _expiryDateController,
//                keyboardType: TextInputType.number,
//                decoration: buildInputDecoration(context, "Year", "YYYY"),
//                validators: [
//                  // FormBuilderValidators.minLength(3),
//                  FormBuilderValidators.min(2020),
//                  FormBuilderValidators.max(2035),
//                  FormBuilderValidators.minLength(4),
//                  FormBuilderValidators.numeric(),
//
//                  // FormBuilderValidators.required()
//                ],
//              ),
//              //   ],
//              // ),


              SizedBox(
                height: 20,
              ),
              _con.signupLoader
                  ? SizedBox(
                      width: 35,
                      child: Center(child: CircularProgressIndicator()))
                  : SizedBox(
                      width: MediaQuery.of(context).size.width * 0.9,
                      child: BlockButtonWidget(
                          text: Text(
                            "Sign Up",
                            style: TextStyle(
                               fontSize: 20,
                                fontFamily:"AVENIRLTSTD",
                                color: Theme.of(context).primaryColor),
                          ),
                          color: Theme.of(context).accentColor,
                          onPressed: ()
                          {
                            print("whether="+_con.groupValue.toString());
                            _con.groupValue.toString()=="0" ?_con.register(context, false):_con.register(context, false);
                          }
                          // onPressed: () {
                          //   if (_con.signUpKey.currentState.saveAndValidate()) {
                          //     print(_con.signUpKey.currentState.value);
                          //   }
                          // }
                          )),
              // _con.logoImage==null?Image.file(fields)
              // MaterialButton(
              //   child: Text(
              //     "Cancel",
              //   ),
              //   onPressed: () {
              //     setState(() {
              //       _con.signUpKey.currentState.reset();
              //       _con.photoImage = null;
              //       _con.logoImage = null;
              //       _con.signatureImage = null;
              //     });

              //     // Navigator.of(context).pop();
              //   },
              // ),
              SizedBox(
                height: 20,
              ),
              FlatButton(
                onPressed: () {
                  Navigator.of(context).pop();
                 // Navigator.pushNamedAndRemoveUntil(context,'/Login',(Route<dynamic> route) => false);
                },
                textColor: Theme.of(context).hintColor,
                child: Text(S.i_have_account_back_to_login,style: TextStyle(    fontSize: 18,
                  fontFamily:"AVENIRLTSTD",),),
              )
            ],
          ),
        ),

    );
  }
  Future getImage(File photoImage) async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    File croppedFile = await ImageCropper.cropImage(
        sourcePath: image.path,
        aspectRatioPresets: [
          CropAspectRatioPreset.square,
          CropAspectRatioPreset.ratio3x2,
          CropAspectRatioPreset.original,
          CropAspectRatioPreset.ratio4x3,
          CropAspectRatioPreset.ratio16x9
        ],
        androidUiSettings: AndroidUiSettings(
            toolbarTitle: 'Cropper',
            toolbarColor: Colors.deepOrange,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.ratio3x2,
            lockAspectRatio: true),
        iosUiSettings: IOSUiSettings(
          minimumAspectRatio: 1.0,
        )
    );

    return croppedFile;
  }
  SignUpUser fields = new SignUpUser();
}


//jaoaxfaaaaawelx@gmail.com
//Abc@123