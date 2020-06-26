import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:poolinspection/src/elements/drawer.dart';
import 'package:poolinspection/src/models/getpaymentdetailmodel.dart';
import 'package:poolinspection/src/models/selectCompliantOrNotice.dart';
import 'package:poolinspection/src/pages/home/SelectNoticeOrNonCompliant.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:image_picker/image_picker.dart';
import 'package:poolinspection/src/helpers/sharedpreferences/userpreferences.dart';
import 'package:poolinspection/src/elements/radiobutton.dart';
import 'package:poolinspection/res/string.dart';
import 'package:poolinspection/src/constants/validators.dart';
import 'package:poolinspection/src/controllers/user_controller.dart';
import 'package:poolinspection/src/elements/BlockButtonWidget.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:poolinspection/config/app_config.dart' as config;
import 'package:poolinspection/src/elements/inputdecoration.dart';
import 'package:poolinspection/src/elements/maskedtextformater.dart';
import 'package:poolinspection/src/elements/textlabel.dart';
import 'package:poolinspection/src/models/company_fields.dart';
import 'package:poolinspection/src/models/paymentmethodmodel.dart';
import 'package:poolinspection/src/models/route_argument.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:poolinspection/src/repository/user_repository.dart' as userRepo;
import 'package:poolinspection/src/models/signupfields.dart';

class AddCardDetailWidget extends StatefulWidget {
  @override
  _AddCardDetailState createState() => _AddCardDetailState();

}

class _AddCardDetailState extends StateMVC<AddCardDetailWidget> {
  final uploadTextStyle = TextStyle(color: Colors.blueGrey);
  UserController _con;
   String CardNumber;
  bool showCard=false;
  bool showCardUpdateButton=false;
  int UserId;

  GlobalKey<FormBuilderState> _addcreditcardKey =  GlobalKey<FormBuilderState>();
  final GlobalKey<ScaffoldState> _scaffoldKey =
  new GlobalKey<ScaffoldState>();
  GlobalKey<FormBuilderState> signUpKey = GlobalKey<FormBuilderState>();
  _AddCardDetailState() : super(UserController()) {
    _con = controller;
  }
  Future getCardNumber() async {
    ProgressDialog pr;
    pr = ProgressDialog(context,isDismissible: false);
    try {

      await pr.show();

     await UserSharedPreferencesHelper.getUserDetails().then((user) {
        setState(() {
          // print("${user.userdata.inspector.firstName } controller user id");
          UserId=user.id;

        });
      });
    print("useruseruser"+UserId.toString());
      final response = await http.get(
        'https://poolinspection.beedevstaging.com/api/beedev/payment-detail/$UserId',

      ).timeout(
          const Duration(seconds: 20));

      PaymentDetailGetApiModel getcardnumber = paymentDetailGetApiModelFromJson(response.body);


      if (getcardnumber.status=="pass" && getcardnumber.paymentDetail.cardNo!=null) {


        await pr.hide();
//        Fluttertoast.showToast(
//            msg: "Successfully fetched cardNo"+getcardnumber.paymentDetail.cardNo.toString(),
//            toastLength: Toast.LENGTH_SHORT,
//            gravity: ToastGravity.BOTTOM,
//            timeInSecForIosWeb: 1,
//            backgroundColor: Colors.red,
//            textColor: Colors.white,
//            fontSize: 16.0
//        );
        CardNumber=getcardnumber.paymentDetail.cardNo.toString();


        setState(() {
          // print("${user.userdata.inspector.firstName } controller user id");
          showCardUpdateButton=true;

        });
      }
      else {

        await pr.hide();
        setState(() {

          showCardUpdateButton=false;

        });
//        Fluttertoast.showToast(
//            msg: "Update Card Details",
//            toastLength: Toast.LENGTH_SHORT,
//            gravity: ToastGravity.BOTTOM,
//            timeInSecForIosWeb: 1,
//            backgroundColor: Colors.red,
//            textColor: Colors.white,
//            fontSize: 16.0
//        );
      }
    }on TimeoutException catch (_) {
      await pr.hide();
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
      await pr.hide();
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
      await pr.hide();
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
  @override
  void initState() {
    String i=UserSharedPreferencesHelper.userid;

    // TODO: implement initState
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_){

      getCardNumber();
    });
    UserSharedPreferencesHelper.getUserDetails().then((user) {
      setState(() {
        // print("${user.userdata.inspector.firstName } controller user id");
        UserId=user.id;

      });
    });
    setState(() {
      // print("${user.userdata.inspector.firstName } controller user id");


    });

  }

  @override
  Widget build(BuildContext context) {

    return WillPopScope(
        onWillPop: () {
          Navigator.of(context).pop();
        },
        child: Scaffold(
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
              child:Text("Your Card Details",
              style: TextStyle(
                fontWeight: FontWeight.w500,
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

            // actions: <Widget>[
            //   IconButton(icon: Icon(Icons.dns), onPressed: () => print(''))
            // ],
            key: _scaffoldKey,
            resizeToAvoidBottomPadding: true,
            body: Padding(
              padding: const EdgeInsets.all(8.0),
              child: buildListInspectorView(context),
            )));
  }



  FormBuilder buildListInspectorView(BuildContext context) {

    ProgressDialog pr;


    Future<AddPAymentModel> addPaymentMethod(userid,cardname,cardnumber,cardcvv,cardexpirymonth,cardexpiryyear) async {
      pr = ProgressDialog(context,isDismissible: false);
      await pr.show();
      
      print("check="+cardname.toString()+cardnumber.toString()+cardcvv.toString()+cardexpirymonth.toString()+cardexpiryyear.toString());
     try {
       
       final response = await http.post(
           'https://poolinspection.beedevstaging.com/api/beedev/add-payment-method',
           body: {
             'user_id': userid,
             'payment_method':'card',
             'card_name': cardname,
             'card_number': cardnumber,
             'card_cvv': cardcvv,
             'card_expiry_month': cardexpirymonth,
             'card_expiry_year': cardexpiryyear
           }
       ).timeout(
           const Duration(seconds: 20));
     print("responseofcard"+response.body.toString());
       //logic is not acceptable but leaving it fior now
       SelectNonCompliantOrNotice loginrespdata = selectNonCompliantOrNoticeFromJson(response.body);
//      https://poolinspection.beedevstaging.com/login

       if (loginrespdata.status == "pass") {
         print("inisdesucess=" + userid);
      await pr.hide();
         Fluttertoast.showToast(
             msg: "Card Details Updated ",
             //response code is 400
             toastLength: Toast.LENGTH_SHORT,
             gravity: ToastGravity.BOTTOM,

             backgroundColor: Colors.blueAccent,
             textColor: Colors.white,
             fontSize: 16.0
         );
         Navigator.pushNamedAndRemoveUntil(context,'/Home',(Route<dynamic> route) => false);
       }

       else {

         await pr.hide();
         Fluttertoast.showToast(
             msg: loginrespdata.messages.toString(),
             //response code is 400
             toastLength: Toast.LENGTH_SHORT,
             gravity: ToastGravity.BOTTOM,

             backgroundColor: Colors.blueAccent,
             textColor: Colors.white,
             fontSize: 16.0
         );
       }
     }on TimeoutException catch (_) {
       await pr.hide();
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
       await pr.hide();
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
       await pr.hide();
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



    final sizedbox =
    SizedBox(height: config.App(context).appVerticalPadding(2));
    return FormBuilder(
      key:_addcreditcardKey,
       initialValue: {

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
       },
      autovalidate: _con.autoValidate,
      child: SingleChildScrollView(

        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child:Column(children: <Widget>[
            Row(
                children: <Widget>[
                 Padding(
                   padding: EdgeInsets.all(5.0),
                   child: SizedBox(

                     child: new GestureDetector(
                       onTap:() {
                         setState(() {

                         });
                       },
                       child:    new Container(
                           color:Color(0xff0ba1d9),

                           padding: new EdgeInsets.all(10.0),
                           child: Text("Card Details" ,textAlign: TextAlign.center, style: TextStyle(
                               fontWeight: FontWeight.bold, fontSize:15,fontFamily: "AVENIRLTSTD",color:Color(0xffffffff)))
                       ),
                     ),),
                 ),

                ]
            ),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child:Column(
                  // physics: NeverScrollableScrollPhysics(),
                  children: <Widget>[


                  showCardUpdateButton?Column(
                    // physics: NeverScrollableScrollPhysics(),
                      children: <Widget>[
                        textLabel("Your Card Number"),
                        FormBuilderTextField(

                          style: TextStyle(color: Color(0xff222222), fontFamily: "AVENIRLTSTD",fontSize: 17),
                          attribute: "card_number",
                          // inputFormatters: [
                          //   MaskedTextInputFormatter(
                          //     mask: 'xxxx-xxxx-xxxx-xxxx',
                          //     separator: '-',
                          //   ),
                          // ],
                          // controller: _cardNumberController,
                          inputFormatters: [WhitelistingTextInputFormatter.digitsOnly],
                          maxLength: 16,
                          readOnly: true,


                          keyboardType: TextInputType.number,
                          decoration: buildInputDecoration(
                              context, "Your Card Number", CardNumber),
                          validators: [
                            // FormBuilderValidators.creditCard(),
                            FormBuilderValidators.maxLength(16),
                            FormBuilderValidators.numeric(),

                            FormBuilderValidators.required(),
                            FormBuilderValidators.minLength(16),
                          ],
                        ),
                        RaisedButton(
                            shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(10.0)),
                            color:Color(0xff0ba1d9),
                            child:Text(

                              "Update Card",
                              style: TextStyle(
                                  fontSize: 17,

                                  color: Colors.white, fontFamily: "AVENIRLTSTD",fontWeight: FontWeight.w900),
                            ),


                            onPressed: () {

                              setState(() {
                                showCardUpdateButton=false;

                              });
                            }

                        ),



                        sizedbox,

                      ]
                  ):  Column(
                // physics: NeverScrollableScrollPhysics(),
                children: <Widget>[
                sizedbox,
                textLabel("Name on Card"),
                FormBuilderTextField(
                  style: TextStyle(color: Color(0xff222222), fontFamily: "AVENIRLTSTD",fontSize: 17,),
                  attribute: "card_holder_name",
                  decoration: buildInputDecoration(
                      context, "Enter Name", "Name on Card"),
                  keyboardType: TextInputType.text,
                  validators: [
                    FormBuilderValidators.min(4),
                    // FormBuilderValidators.pattern(r'^\D+$'),
                    CustomFormBuilderValidators.charOnly(),
                    FormBuilderValidators.maxLength(20),
                    FormBuilderValidators.required(),
                    FormBuilderValidators.minLength(4),
                  ],
                ),
                sizedbox,
                textLabel("Card Number"),
                FormBuilderTextField(

                  style: TextStyle(color: Color(0xff222222), fontFamily: "AVENIRLTSTD",fontSize: 17),
                  attribute: "card_number",
                  // inputFormatters: [
                  //   MaskedTextInputFormatter(
                  //     mask: 'xxxx-xxxx-xxxx-xxxx',
                  //     separator: '-',
                  //   ),
                  // ],
                  // controller: _cardNumberController,
                  inputFormatters: [WhitelistingTextInputFormatter.digitsOnly],
                  maxLength: 16,
                  keyboardType: TextInputType.number,
                  decoration: buildInputDecoration(
                      context, "Card Number", "0000 0000 0000 0000"),
                  validators: [
                    // FormBuilderValidators.creditCard(),
                    FormBuilderValidators.maxLength(16),
                    FormBuilderValidators.numeric(),

                    FormBuilderValidators.required(),
                    FormBuilderValidators.minLength(16),
                  ],
                ),
                sizedbox,

                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    Expanded(
                      flex: 7,
                      child:Column(
                          children: <Widget>[
                            textLabel("Valid Through"),
                            Row(
                              children: <Widget>[


                                // Row(
                                //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                //   children: <Widget>[


                                Expanded(child:Padding(
                                  padding: EdgeInsets.all(6.0),
                                  child:FormBuilderTextField(

                                    style: TextStyle(color: Color(0xff222222), fontFamily: "AVENIRLTSTD",fontSize: 17),
                                    inputFormatters: [WhitelistingTextInputFormatter.digitsOnly],

                                    attribute: "card_expiry_month",
                                    maxLength: 2,
                                    // controller: _expiryDateController,
                                    keyboardType: TextInputType.number,

                                    decoration: buildInputDecoration(context, "Month", "Month"),
                                    validators: [
                                      FormBuilderValidators.min(1),
                                      FormBuilderValidators.max(12),
                                      FormBuilderValidators.minLength(2),
                                      FormBuilderValidators.numeric(),
                                    ],
                                  ),),),
                                sizedbox,

                                Expanded(child:Padding(
                                  padding: EdgeInsets.all(6.0),
                                  child:FormBuilderTextField(
                                    style: TextStyle(color: Color(0xff222222), fontFamily: "AVENIRLTSTD",fontSize: 17),
                                    inputFormatters: [WhitelistingTextInputFormatter.digitsOnly],
                                    attribute: "card_expiry_year",
                                    maxLength: 4,
                                    // controller: _expiryDateController,
                                    keyboardType: TextInputType.number,
                                    decoration: buildInputDecoration(context, "Year", "Year"),
                                    validators: [
                                      // FormBuilderValidators.minLength(3),
                                      FormBuilderValidators.min(2020),
                                      FormBuilderValidators.max(2035),
                                      FormBuilderValidators.minLength(4),
                                      FormBuilderValidators.numeric(),

                                      // FormBuilderValidators.required()
                                    ],
                                  ),),),

                                sizedbox,


                              ],
                            ),


                          ]
                      ),),

                    Expanded(
                      flex: 3,
                      child:Column(
                          children: <Widget>[

                            Padding(
                              child:textLabel("CVV"),
                              padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                            ),
                            Row(
                              children: <Widget>[
                                Expanded(child:Padding(
                                  padding: EdgeInsets.all(6.0),
                                  child:FormBuilderTextField(
                                    style: TextStyle(color: Color(0xff222222), fontFamily: "AVENIRLTSTD",fontSize: 17),
                                    attribute: "card_cvv",
                                    inputFormatters: [WhitelistingTextInputFormatter.digitsOnly],

                                    maxLength: 3,
                                    // controller: _cvvCodeController,
                                    keyboardType: TextInputType.number,
                                    decoration: buildInputDecoration(context, "CVV Number", "000"),
                                    // inputFormatters: [
                                    //   MaskedTextInputFormatter(
                                    //     mask: 'xxxx',
                                    //     separator: '-',
                                    //   ),
                                    // ],
                                    validators: [
                                      FormBuilderValidators.min(3),
                                      FormBuilderValidators.numeric(),

                                      // FormBuilderValidators.minLength(3),
                                      FormBuilderValidators.required()
                                    ],
                                  ),
                                ),)
                              ],
                            ),


                          ]
                      ),),
                  ],
                ),




                sizedbox,

                ]
            ),



                    showCardUpdateButton
//              _con.signupLoader
                        ? Container()
                        : Align(
                  alignment: Alignment.topLeft,
                  child:Padding(
                    padding: EdgeInsets.fromLTRB(10, 0, 10, 10),
                    child: SizedBox(

                      width:100,
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: RaisedButton(
                            shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(10.0)),
                            color:Color(0xff0ba1d9),
                            child:Text(

                              "Update",
                              style: TextStyle(
                                  fontSize: 17,

                                  color: Colors.white, fontFamily: "AVENIRLTSTD",fontWeight: FontWeight.w900),
                            ),


                            onPressed: () {
                              if (_addcreditcardKey.currentState.saveAndValidate()) {
//    Future<AddPAymentModel> addPaymentMethod(userid,paymentmethod,cardname,cardnumber,cardcvv,cardexpirymonth,cardexpiryyear,accountname,accountnumber,bsbnumber) async {//    Future<AddPAymentModel> addPaymentMethod(userid,paymentmethod,cardname,cardnumber,cardcvv,cardexpirymonth,cardexpiryyear,accountname,accountnumber,bsbnumber) async {

                                addPaymentMethod(UserId.toString(),_addcreditcardKey.currentState.value["card_holder_name"].toString(),_addcreditcardKey.currentState.value["card_number"].toString(),_addcreditcardKey.currentState.value["card_cvv"].toString(),_addcreditcardKey.currentState.value["card_expiry_month"].toString(),_addcreditcardKey.currentState.value["card_expiry_year"].toString());

//      print("furmdata="+_addcreditcardKey.currentState.value["select_cardorbank"].toString());
                              };


                            }
                          // onPressed: () {
                          //   if (_con.signUpKey.currentState.saveAndValidate()) {
                          //     print(_con.signUpKey.currentState.value);
                          //   }
                          // }
                        ),
                      ),
                    ),
                  ),
                    ),
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

                  ],
                ),
              ),
            ),
          ],)
        ),
      ),
    );
  }

  SignUpUser fields = new SignUpUser();


}
