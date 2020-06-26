import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:poolinspection/src/elements/drawer.dart';
import 'package:poolinspection/src/models/getpaymentdetailmodel.dart';
import 'package:poolinspection/src/models/selectCompliantOrNotice.dart';
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
import 'package:shared_preferences/shared_preferences.dart';

class AddBankDetailWidget extends StatefulWidget {
  @override
  _AddBankDetailState createState() => _AddBankDetailState();

}

class _AddBankDetailState extends StateMVC<AddBankDetailWidget> {
  final uploadTextStyle = TextStyle(color: Colors.blueGrey);
  UserController _con;
  String AccountNumber="";
  String AccountName="";
  String BSBNumber="";
 // bool fetchedbankdetail=false;
  int UserId;

  GlobalKey<FormBuilderState> _addcreditcardKey =  GlobalKey<FormBuilderState>();
  final GlobalKey<ScaffoldState> _scaffoldKey =
  new GlobalKey<ScaffoldState>();
  GlobalKey<FormBuilderState> signUpKey = GlobalKey<FormBuilderState>();
  _AddBankDetailState() : super(UserController()) {
    _con = controller;
  }
  Future<PaymentDetailGetApiModel> getBankDetail() async {

    try {



      await UserSharedPreferencesHelper.getUserDetails().then((user) {

          // print("${user.userdata.inspector.firstName } controller user id");
          UserId=user.id;


      });
      print("useruseruser"+UserId.toString());
      final response = await http.get(
        'https://poolinspection.beedevstaging.com/api/beedev/payment-detail/$UserId',

      ).timeout(
          const Duration(seconds: 20));

      PaymentDetailGetApiModel getbankdetail = paymentDetailGetApiModelFromJson(response.body);

     return getbankdetail;
    }on TimeoutException catch (_) {

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






  Future<AddPAymentModel> addBankDetail(userid,accountname,accountnumber,bsbnumber) async {
    ProgressDialog pr;
    pr = ProgressDialog(context,isDismissible: false);
    await pr.show();

    try
    {
      print("ssss"+userid.toString()+accountnumber.toString()+accountname.toString()+bsbnumber.toString());
      final response = await http.post(
          'https://poolinspection.beedevstaging.com/api/beedev/add_bank_details',
          body: {'user_id':userid,'account_name':accountname,'account_no':accountnumber,'bsb_no':bsbnumber}
      ).timeout(
          const Duration(seconds: 20));
      print("bankdetailrespnse"+response.body.toString());
      //logic is not acceptable but leaving it fior now
      SelectNonCompliantOrNotice loginrespdata = selectNonCompliantOrNoticeFromJson(response.body);
//      https://poolinspection.beedevstaging.com/login

      if (loginrespdata.status== "pass") {
        print("inisdesucess="+userid);
        await pr.hide();
        Fluttertoast.showToast(
            msg: "Bank Detail Updated",
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
        print("inisdefail");
        await  pr.hide();
        Fluttertoast.showToast(
            msg: "Payment Updation Fail Error:"+loginrespdata.error.toString(),
            //response code is 400
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,

            backgroundColor: Colors.blueAccent,
            textColor: Colors.white,
            fontSize: 16.0
        );
      }
    }
    on TimeoutException catch (_) {
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

      getBankDetail();
    });

    print("AccountNumber"+AccountNumber.toString());
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
              child:Text("Your Bank Details",
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
            body: FutureBuilder<PaymentDetailGetApiModel>(
              future: getBankDetail(),
              builder: (context, snapshot) {

                if (snapshot.hasData) {
                  //     spacecrafts.add(snapshot.data.data.elementAt(0).categoryname);
                  if(snapshot.data.paymentDetail.accountName!=null)
                  {




                  AccountName=snapshot.data.paymentDetail.accountName;
                  AccountNumber=snapshot.data.paymentDetail.accountNumber;
                  BSBNumber=snapshot.data.paymentDetail.bsbNumber;



                  return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: buildListInspectorView(context),
                  );
                    }

                  else
                    {
                    return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: buildListInspectorView(context),);

                    }
                  }
                  else
                  {
                    return Align(
                      alignment: Alignment.center,
                      child: CircularProgressIndicator(),

                    );
                  }


              },

            ),
    )
    );

  }



  FormBuilder buildListInspectorView(BuildContext context) {


    final sizedbox =
    SizedBox(height: config.App(context).appVerticalPadding(2));
    return FormBuilder(

      key:_addcreditcardKey,
       initialValue: {
//         "account_name":"Hello",
//         "account_no":AccountNumber,
//         "bsb_no":BSBNumber

       },
      autovalidate: _con.autoValidate,
      child:SingleChildScrollView(

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

                       },
                       child:    new Container(
                           color:Color(0xff0ba1d9),

                           padding: new EdgeInsets.all(10.0),
                           child: Text("Bank Details" ,textAlign: TextAlign.center, style: TextStyle(
                               fontWeight: FontWeight.bold, fontSize:15,fontFamily: "AVENIRLTSTD",color:Colors.white))
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


                    Column(
                      // physics: NeverScrollableScrollPhysics(),
                        children: <Widget>[
                           sizedbox,
                          textLabel("Account Name"),
                          FormBuilderTextField(
                            style: TextStyle(color: Color(0xff222222), fontFamily: "AVENIRLTSTD",fontSize: 17),
                            attribute: "account_name",
                            initialValue: AccountName,

                            decoration: buildInputDecoration(
                                context, "Enter Account Name", "Enter Account Name"),
                            keyboardType: TextInputType.text,

                            validators: [
                              FormBuilderValidators.min(4),
                              // FormBuilderValidators.pattern(r'^\D+$'),
                              CustomFormBuilderValidators.charOnly(),
                              FormBuilderValidators.maxLength(25),
                              FormBuilderValidators.required(),
                              FormBuilderValidators.minLength(4),
                            ],
                          ),
                          sizedbox,

                          textLabel("Account Number"),
                          FormBuilderTextField(
                            initialValue: AccountNumber,
                            style: TextStyle(color: Color(0xff222222), fontFamily: "AVENIRLTSTD",fontSize: 17),
                            attribute: "account_no",
                            // inputFormatters: [
                            //   MaskedTextInputFormatter(
                            //     mask: 'xxxx-xxxx-xxxx-xxxx',
                            //     separator: '-',
                            //   ),
                            // ],
                            // controller: _cardNumberController,
                            inputFormatters: [WhitelistingTextInputFormatter.digitsOnly],
                            maxLength: 18,

                            keyboardType: TextInputType.number,
                            decoration: buildInputDecoration(

                                context, "Account Number", "Enter Account Number"),
                            validators: [
                              // FormBuilderValidators.creditCard(),
                              FormBuilderValidators.maxLength(18),
                              FormBuilderValidators.numeric(),

                              FormBuilderValidators.required(),
                              FormBuilderValidators.minLength(9),
                            ],
                          ),
                          sizedbox,
                          textLabel("BSB Number"),
                          FormBuilderTextField(
                            initialValue: BSBNumber,
                            style: TextStyle(color: Color(0xff222222), fontFamily: "AVENIRLTSTD",fontSize: 17),
                            attribute: "bsb_no",
                            // inputFormatters: [
                            //   MaskedTextInputFormatter(
                            //     mask: 'xxxx-xxxx-xxxx-xxxx',
                            //     separator: '-',
                            //   ),
                            // ],
                            // controller: _cardNumberController,
                            inputFormatters: [WhitelistingTextInputFormatter.digitsOnly],
                            maxLength: 6,
                            keyboardType: TextInputType.number,
                            decoration: buildInputDecoration(
                                context, "BSB Number", "Enter BSB Number"),
                            validators: [
                              // FormBuilderValidators.creditCard(),
                              FormBuilderValidators.maxLength(6),
                              FormBuilderValidators.numeric(),

                              FormBuilderValidators.required(),
                              FormBuilderValidators.minLength(6),
                            ],
                          ),
                          sizedbox,
                        ]
                    ),

                    false
//              _con.signupLoader
                        ? SizedBox(
                        width: 35,
                        child: Center(child: CircularProgressIndicator()))
                        : Align(
                  alignment: Alignment.topLeft,
                  child:Padding(
                    padding: EdgeInsets.fromLTRB(10, 0, 10, 10),
                    child: SizedBox(

                      width:100,
                      child: Align(
                        alignment: Alignment.topLeft,
                        child:
//                        fetchedbankdetail?RaisedButton(
//                            shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(10.0)),
//                            color:Color(0xff0ba1d9),
//                            child:Text(
//
//                              "Edit",
//                              style: TextStyle(
//                                  fontSize: 17,
//
//                                  color: Colors.white, fontFamily: "AVENIRLTSTD",fontWeight: FontWeight.w900),
//                            ),
//
//
//                            onPressed: () {
//
//                              setState(() {
//                                //   _addcreditcardKey.currentState.reset();
//                                fetchedbankdetail=false;
//                              });
//                            }
//                          // onPressed: () {
//                          //   if (_con.signUpKey.currentState.saveAndValidate()) {
//                          //     print(_con.signUpKey.currentState.value);
//                          //   }
//                          // }
//                        ):
                        RaisedButton(
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

                                addBankDetail(UserId.toString(),_addcreditcardKey.currentState.value["account_name"].toString(),_addcreditcardKey.currentState.value["account_no"].toString(),_addcreditcardKey.currentState.value["bsb_no"].toString());

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
