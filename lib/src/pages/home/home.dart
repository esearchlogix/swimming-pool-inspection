import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:wasm';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:poolinspection/src/constants/size.dart';
import 'package:poolinspection/src/controllers/home_controller.dart';
import 'package:poolinspection/src/controllers/user_controller.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:poolinspection/src/elements/BlockButtonWidget.dart';
import 'package:poolinspection/src/elements/drawer.dart';
import 'package:poolinspection/src/helpers/connectivity.dart';
import 'package:poolinspection/src/helpers/sharedpreferences/userpreferences.dart';
import 'package:poolinspection/src/models/getpaymentdetailmodel.dart';
import 'package:poolinspection/src/models/route_argument.dart';
import 'package:poolinspection/src/models/selectCompliantOrNotice.dart';
import 'package:poolinspection/src/pages/booking/prefilbooking.dart';
import 'package:poolinspection/src/pages/inspection/inspectionheadinglist.dart';
import 'package:poolinspection/src/pages/reports/reportdetail.dart';
import 'package:poolinspection/src/repository/user_repository.dart' as userRepo;
import 'package:poolinspection/config/app_config.dart' as config;
import 'package:progress_dialog/progress_dialog.dart';
import 'dart:developer' as developer;


class HomeWidget extends StatefulWidget {

  RouteArgumentHome routeArgument;
  HomeWidget({Key key, this.routeArgument}) : super(key: key);


  @override
  _HomeWidgetState createState() => _HomeWidgetState();
}

class _HomeWidgetState extends StateMVC<HomeWidget> {
  HomeController _con;
  int ax=0;
  var differencedate;
  int UserId;
  bool isOnline=false;
  String getPaymentMessage;
  var offlinelistdata=null;
  bool filter = false;
  StreamSubscription _connectionChangeStream;
  ConnectionStatusSingleton connectionStatus;
  _HomeWidgetState() : super(HomeController()) {
    _con = controller;
  }
  Future checkPaymentDetail() async {
    ProgressDialog pr;
    pr = new ProgressDialog(context);
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
        'https://poolinspection.beedevstaging.com/api/beedev/check_payment_details/$UserId'

      ).timeout(
        const Duration( seconds: 15),

      );
      print("useruseruser2"+response.body.toString());
      SelectNonCompliantOrNotice checkBankOrCardDetail = selectNonCompliantOrNoticeFromJson(response.body);


      if (checkBankOrCardDetail.status=="pass") {


        await pr.hide();
      if(checkBankOrCardDetail.messages=="Card & Bank Details Present")
        {
          Navigator.of(context).pushNamed('/BookingForm');
        }
      else if(checkBankOrCardDetail.messages=="Card detail not found")
        {
          Navigator.of(context).pushNamed('/AddCardDetail');
        }
      else
        {
          Navigator.of(context).pushNamed('/BankDetails');
        }
//        Fluttertoast.showToast(
//            msg: checkBankOrCardDetail.messages.toString(),
//            toastLength: Toast.LENGTH_SHORT,
//            gravity: ToastGravity.BOTTOM,
//            timeInSecForIosWeb: 1,
//            backgroundColor: Colors.red,
//            textColor: Colors.white,
//            fontSize: 16.0
//        );
        getPaymentMessage=checkBankOrCardDetail.messages.toString();


        setState(() {
          // print("${user.userdata.inspector.firstName } controller user id");
          //showCardUpdateButton=true;

        });
      }
      else {
        await pr.hide();
        setState(() {
        //  showCardUpdateButton=false;
        });
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
    }  on TimeoutException catch (_) {
      await pr.hide();
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
    on SocketException catch (_) {
      await pr.hide();
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

    catch(e)
    {
      await pr.hide();
      print(e.toString());
      Fluttertoast.showToast(
          msg: e.toString(),
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0
      );
    }
  }

  Future callSavedHomeListCheckingInternet() async
  {

  //  _connectionChangeStream = await connectionStatus.connectionChange.listen(connectionChanged);
    await connectionStatus.checkConnection().then((val) {
      val ? loadData() :print("not connected in home");
      isOnline = val;
    });


  }
  Future checkConnection() async
  {

   // _connectionChangeStream =   await connectionStatus.connectionChange.listen(connectionChanged);
    await connectionStatus.checkConnection().then((val) {
      val ? loadDataDash() :print("not connected afterlogin");
      isOnline = val;
    });


  }


  @override
  void initState() {
    super.initState();
    connectionStatus = ConnectionStatusSingleton.getInstance();


    userRepo.token="beedev";

    if (widget.routeArgument == null) { //this condition will run just after drawer dashboard button press
      print("afterdrawerrefresh");
      _con.readCounter().then((onValue) {
        setState(() {
          offlinelistdata=json.decode(onValue.toString());
        });
      });
      WidgetsBinding.instance.addPostFrameCallback((_){

        callSavedHomeListCheckingInternet();

      });




    } else {            //this condition will run just after login //here sqlite inspection dashboard data listing will go.
      print("afterlogin");
      WidgetsBinding.instance.addPostFrameCallback((_){

       checkConnection();

      });

    }

    // if(userRepo.currentUser.isPasswordChange ==null || userRepo.currentUser.isPasswordChange == 0) {
    //     Navigator.of(context).pushReplacementNamed('/UpdatePassword');
    //   }
  }
  void connectionChanged(dynamic hasConnection) {   //later use
    setState(() {
      connectionStatus.checkConnection().then((val) {
        val ? loadData() : print("not connected");
        isOnline= val;
      });
      // isOffline = !hasConnection;
    });
  }
  Future<Timer> loadData() async {
    return new Timer(Duration(seconds: 0), onDoneLoading);
  }
  Future<Timer> loadDataDash() async {
    return new Timer(Duration(seconds: 0), callDash);
  }
  onDoneLoading() async {
    // print(currentUser.token2fa);
    refreshId();

  }
  callDash() async {
    // print(currentUser.token2fa);
    _con.dashBoardBloc(widget.routeArgument.id).then((onValue) {
      setState(() {

        print("onValuehome="+onValue.toString());
        _con.listdata = onValue;

        // if (_con.listdata == 1) {
        //   Navigator.of(_con.scaffoldKey.currentContext)
        //       .pushReplacementNamed('/Login');
        // }
      });
    });
   refreshId();
  }
  @override
  Widget build(BuildContext context) {

    return Scaffold(
        drawer: drawerData(
            context,
            widget.routeArgument == null
                ? userRepo.user.rolesManage
                : widget.routeArgument.role),
        key: _con.scaffoldKey,
        backgroundColor: config.Colors().scaffoldColor(1),
        appBar: AppBar(
          title: Text("Dashboard",
              style: TextStyle(
                  fontSize: 20,
                    fontFamily: "AVENIRLTSTD",
                  // fontWeight: FontWeight.bold,
                  color: Color(0xff222222))),
          centerTitle: true,
          leading: Image.asset(
            "assets/img/app-iconwhite.jpg",
            // fit: BoxFit.cover,
            fit: BoxFit.fitWidth,
          ),
          actions: <Widget>[
            IconButton(
                icon: Icon(
                  Icons.menu,
                  color: config.Colors().secondColor(1),
                ),
                onPressed: () => _con.scaffoldKey.currentState.openDrawer()),
          ],
        ),
        body:   _con.listdata == null
              ? Center(
            child: isOnline?
            CircularProgressIndicator()
                :offlinelistdata==null?CircularProgressIndicator(backgroundColor: Colors.redAccent,):RefreshIndicator(
                onRefresh: refreshOfflineId,
                child:  buildColumn(context, offlinelistdata)),

//            SizedBox(
//                width: MediaQuery.of(context).size.width * 2 / 3,
//                child: RaisedButton(
//                    shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(10.0)),
//                    color: Colors.redAccent,
//                    child: Row(
//                      mainAxisAlignment: MainAxisAlignment.center,
//                      children: <Widget>[
//                        Icon(Icons.refresh,color: Colors.white,),
//                        Text(" Checking Internet...", style: TextStyle(
//                            color: Colors.white,
//                            fontFamily: "AVENIRLTSTD",fontSize: 20
//                        ),)
//                      ],
//                    ),
//                    onPressed: () async
//                    {
//                      connectionChanged(
//                          await connectionStatus
//                              .checkConnection()
//                              .then((val) {
//                            val ? loadData():print("not connected");//val is false if not connected
//                            isOnline=val;
//                          }
//                          ));
//                    }
//                ),
//              ),
          )
              : RefreshIndicator(
              onRefresh: refreshId,
              child:  buildColumn(context, _con.listdata)),

    );
    // : Text(_con.listdata.toString() ?? ""));
  }

//             future: dashBoardBloc(),
  Future refreshId() async {
    setState(() {

      _con.fetchData();
    });
  }
  Future refreshOfflineId() async {
    setState(() {

      _con.readCounter().then((onValue) {
        setState(() {
          offlinelistdata=json.decode(onValue.toString());
        });
      });
    });
  }
  Widget buildColumn(BuildContext context, data) {

//    developer.log(
//      'log me',
//      name: 'my.app.category',
//      error: data.toString(),
//    );
   //debugPrint("xmh="+data.toString());
    return data == 1
        ? Container()
        : Column(children: <Widget>[
          SizedBox(height: 20,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[

                buildCardTop(

                    data['newlist'].length / 100,

                    "${data['newlist'].length}",
                    Colors.green,
                    "Inspection",
                    "In-progress",
                    1),
                buildCardTop(
                    data['reinspection_list'].length / 100,
                    "${data['reinspection_list'].length}",
                    Colors.orange[200],
                    "Inspection",
                    "Re-Inspection",
                    2),
              ],
            ),
            false
                ? ListTile(
                    title: Text("Re-Inspection List",
                        style: TextStyle(
                            fontSize: 20,
                              fontFamily: "AVENIRLTSTD",
                            // fontWeight: FontWeight.bold,
                            color: Color(0xff222222))),
                    trailing: IconButton(
                      icon: Icon(Icons.refresh),
                      onPressed: refreshId,
                    ),
                  ):Container(),


            filter
                ? buildContainerInProgress(
                    context, 0, data['reinspection_list']):
            buildContainerInProgress(context, 1, data['newlist']),
            SizedBox(
              height: 10,
            ),


            SizedBox(
              width: config.App(context).appWidth(90),
              child: BlockButtonWidget(
                text: Text(
                  "Book Enquiry",
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                      fontFamily: "AVENIRLTSTD",
                  ),
                ),
                color: Theme.of(context).accentColor,
                onPressed: () async {
                  checkPaymentDetail();


                }
                // Navigator.of(context).pop();
              ),
            ),
        SizedBox(height: 10,)

          ]);

  }

  Widget buildContainerInProgress(BuildContext context, int i, data) {

    const _kFontFam = 'MyFlutterApp';
    print("${data.length}   000000000000000000");

    return Expanded( //i removed app height.context and uses expanded in case of some error in future lets do something .
      child: Container(
          padding: EdgeInsets.all(10),

          // color: Colors.red,
          child: data.length == 0 || data == null
              ? Center(
            child: i == 1
                ? Text("No Inspections Found",
                style: TextStyle(
                    fontSize: 18,
                    fontFamily: "AVENIRLTSTD",
                    // fontWeight: FontWeight.bold,
                    color: Color(0xff222222)))
                : Text("No Re-Inspections Found",
                style: TextStyle(
                    fontSize: 18,
                    fontFamily: "AVENIRLTSTD",
                    // fontWeight: FontWeight.bold,
                    color: Color(0xff222222))),
          )
          // data[index]['is_confirm']
              :Padding(
              padding: const EdgeInsets.all(8.0),
              child:
                MediaQuery.of(context).size.width<=600
                      ? SingleChildScrollView(
                      physics: ScrollPhysics(),
                      child: Column(

                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.all(4.0),
                              child:Text("Inspection(s) this week",
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontFamily: "AVENIRLTSD",
                                      fontWeight: FontWeight.w700,
                                      // fontWeight: FontWeight.bold,
                                      color: Color(0xff000000))),
                            ),
                            ListView.builder(

                              physics: NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: data.length,
                              itemBuilder: (context, index) {

                                var dayOfWeek = 1;
                                DateTime date = DateTime.now();
                                DateTime mondaydateofcurrentdate=DateTime.now().subtract(new Duration(days: date.weekday-1));
                                print("logbookdate="+data[index]['booking_date_time'].toString()+data[index]['booking_id'].toString());
                                DateTime bookingDate = DateTime.parse("${data[index]['booking_date_time'].toString().substring(0,10)} "+"00:00:00.000z");
                                DateTime mondayofbookingDate=DateTime.parse("${data[index]['booking_date_time'].toString().substring(0,10)} "+"00:00:00.000z").subtract(new Duration(days: bookingDate.weekday-1));
                                differencedate = mondayofbookingDate.difference(mondaydateofcurrentdate).inDays;

                              //  print("qxcurrentdate=$date");
                              //  print("qxbookingdate=$bookingDate");
                              //  print("qxdifference=$differencedate");
                                // print(data[index]['is_confirm']);

                                return differencedate>=0 && differencedate<6?InkWell(
                                  onTap: () => data[index]['is_compliant'] == 3 ||
                                      data[index]['is_confirm'] == 1
                                      ? Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => InspectionHeadingList(
                                              predata: data[index],
                                              bookingid: data[index]['id'])))
                                      : Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            PreliminaryWidget(data[index]['id'])),
                                  ),

                                  child:  Card(
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(

                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Padding(

                                              child:Text("${data[index]['owner_land']}",
                                                  style: TextStyle(
                                                      fontSize: 20,
                                                      fontFamily: "AVENIRLTSTD",
                                                      // fontWeight: FontWeight.bold,
                                                      color: Color(0xff000000))),
                                              padding: const EdgeInsets.fromLTRB(8, 4, 4, 4),
                                            ) ,
                                            Padding(

                                              child:     Row(

                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                  children: <Widget>[

                                                 //   Icon((IconData(0xe809, fontFamily: _kFontFam)),size: 12,),
                                                       Icon(Icons.home,color: Color(0xff999999),size: 17,),
                                                    SizedBox(width: 5,),
                                                    Flexible(
                                                      child: Text("${data[index]['street_road']} ${data[index]['city_suburb']} ${data[index]['postcode']}", style: TextStyle(
                                                          fontFamily: "AVENIRLTSTD",
                                                          fontSize: 17,
                                                          color: Color(0xff999999),
                                                          fontWeight: FontWeight.normal),),
                                                    )
                                                  ]
                                              ),
                                              padding: const EdgeInsets.all(4.0),
                                            ) ,
                                            Padding(

                                              child: Row(
                                                  mainAxisSize: MainAxisSize.max,
                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                  children: <Widget>[

                                                    Icon(Icons.date_range,color: Color(0xff999999),size: 15,),
                                                    SizedBox(width: 5,),
                                                    Text(DateFormat("dd-MM-yyyy").format(DateTime.parse("${data[index]['booking_date_time'].toString().substring(0,10)} "+"00:00:00.000z")).toString(), style: TextStyle(
                                                        fontFamily: "AVENIRLTSTD",
                                                        fontSize: 16,
                                                        color: Color(0xff999999),
                                                        fontWeight: FontWeight.normal),),
                                                         ]
                                              ),
                                              padding: const EdgeInsets.all(4.0),
                                            ) ,
                                            Padding(

                                              child: Row(
                                                  mainAxisSize: MainAxisSize.max,
                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                  children: <Widget>[

                                                    Icon(Icons.phone,color: Color(0xff999999),size: 16,),
                                                    SizedBox(width: 5,),

                                                    Text("${data[index]['phonenumber']}", style: TextStyle(
                                                        fontFamily: "AVENIRLTSTD",
                                                        fontSize: 16,
                                                        color: Color(0xff999999),
                                                        fontWeight: FontWeight.normal),),
                                                  ]
                                              ),
                                              padding: const EdgeInsets.all(2.0),
                                            ) ,
                                            data[index]['is_compliant'] == 3 || data[index]['is_confirm'] == 1? Padding(
                                              padding: new EdgeInsets.fromLTRB(4,4, 4,4), child:new RaisedButton(
                                              onPressed:() {

                                              },
                                              color:Color(0xff20c67e),
                                              shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(5.0)),
                                              child:Text(
                                                "BOOKING CONFIRMED",
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    color: Color(0xffFFFFFF), fontFamily: "AVENIRLTSTD",fontWeight: FontWeight.normal),
                                              ),


                                            ),
                                            ):Padding(
                                              padding: new EdgeInsets.fromLTRB(4,4, 4,4), child:new RaisedButton(
                                              onPressed:() {

                                              },
                                              color:Colors.redAccent,
                                              shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(5.0)),
                                              child:Text(
                                                "BOOKING NOT CONFIRMED",
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    color: Color(0xffFFFFFF), fontFamily: "AVENIRLTSTD",fontWeight: FontWeight.normal),
                                              ),


                                            ),

                                            ),

                                            data[index]['percentage'] == 0? Padding(
                                              padding: new EdgeInsets.fromLTRB(4,4, 4,4), child:new RaisedButton(
                                              onPressed:() {

                                              },
                                              color:Colors.blueAccent,
                                              shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(5.0)),
                                              child:Text(
                                                "NEW JOB  ",
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    color: Color(0xffFFFFFF), fontFamily: "AVENIRLTSTD",fontWeight: FontWeight.normal),
                                              ),


                                            ),
                                            ):Padding(
                                              padding: new EdgeInsets.fromLTRB(4,4, 4,4), child:new RaisedButton(
                                              onPressed:() {

                                              },
                                              color:Colors.orange,
                                              shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(5.0)),
                                              child:Text(
                                                "ONGOING INSPECTION",
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    color: Color(0xffFFFFFF), fontFamily: "AVENIRLTSTD",fontWeight: FontWeight.normal),
                                              ),


                                            ),

                                            ),

                                          ]
                                      ),
                                    ),

                                  ),
                                ):Container();


                              },

                            ),

                            SizedBox(height: 20,),
                            Padding(
                              padding: const EdgeInsets.all(4.0),
                              child:Text("Inspection(s) next week",
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontFamily: "AVENIRLTSD",
                                      fontWeight: FontWeight.w700,
                                      // fontWeight: FontWeight.bold,
                                      color: Color(0xff000000))),
                            ),
                            ListView.builder(

                              physics: NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: data.length,
                              itemBuilder: (context, index) {

                                var dayOfWeek = 1;
                                DateTime date = DateTime.now();
                                DateTime mondaydateofcurrentdate=DateTime.now().subtract(new Duration(days: date.weekday-1));
                                DateTime bookingDate = DateTime.parse("${data[index]['booking_date_time'].toString().substring(0,10)} "+"00:00:00.000z");
                                DateTime mondayofbookingDate=DateTime.parse("${data[index]['booking_date_time'].toString().substring(0,10)} "+"00:00:00.000z").subtract(new Duration(days: bookingDate.weekday-1));

                                differencedate = mondayofbookingDate.difference(mondaydateofcurrentdate).inDays;

                                // print(data[index]['is_confirm']);
                                return differencedate>=6 &&differencedate<13?InkWell(
                                  onTap: () => data[index]['is_compliant'] == 3 ||
                                      data[index]['is_confirm'] == 1
                                      ? Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => InspectionHeadingList(
                                              predata: data[index],
                                              bookingid: data[index]['id'])))
                                      : Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            PreliminaryWidget(data[index]['id'])),
                                  ),

                                  child:  Card(
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(

                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Padding(

                                              child:Text("${data[index]['owner_land']}",
                                                  style: TextStyle(
                                                      fontSize: 20,
                                                      fontFamily: "AVENIRLTSTD",
                                                      // fontWeight: FontWeight.bold,
                                                      color: Color(0xff000000))),
                                              padding: const EdgeInsets.fromLTRB(8, 4, 4, 4),
                                            ) ,
                                            Padding(

                                              child:     Row(
                                                  mainAxisSize: MainAxisSize.max,
                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                  children: <Widget>[

                                                    Icon(Icons.home,color: Color(0xff999999),size: 16,),
                                                    SizedBox(width: 5,),

                                                   Flexible(child: Text("${data[index]['street_road']} ${data[index]['city_suburb']} ${data[index]['postcode']}", style: TextStyle(
                                                       fontFamily: "AVENIRLTSTD",
                                                       fontSize: 16,
                                                       color: Color(0xff999999),
                                                       fontWeight: FontWeight.normal),),),
                                                  ]
                                              ),
                                              padding: const EdgeInsets.all(4.0),
                                            ) ,
                                            Padding(

                                              child: Row(
                                                  mainAxisSize: MainAxisSize.max,
                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                  children: <Widget>[

                                                    Icon(Icons.date_range,color: Color(0xff999999),size: 15,),
                                                    SizedBox(width: 5,),
                                                    Text(DateFormat("dd-MM-yyyy").format(DateTime.parse("${data[index]['booking_date_time'].toString().substring(0,10)} "+"00:00:00.000z")).toString(), style: TextStyle(
                                                        fontFamily: "AVENIRLTSTD",
                                                        fontSize: 16,
                                                        color: Color(0xff999999),
                                                        fontWeight: FontWeight.normal),),

                                                  ]
                                              ),
                                              padding: const EdgeInsets.all(4.0),
                                            ) ,
                                            Padding(

                                              child: Row(
                                                  mainAxisSize: MainAxisSize.max,
                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                  children: <Widget>[

                                                    Icon(Icons.phone,color: Color(0xff999999),size: 16,),
                                                    SizedBox(width: 5,),

                                                    Text("${data[index]['phonenumber']}", style: TextStyle(
                                                        fontFamily: "AVENIRLTSTD",
                                                        fontSize: 16,
                                                        color: Color(0xff999999),
                                                        fontWeight: FontWeight.normal),),
                                                  ]
                                              ),
                                              padding: const EdgeInsets.all(2.0),
                                            ) ,
                                            data[index]['is_compliant'] == 3 || data[index]['is_confirm'] == 1? Padding(
                                              padding: new EdgeInsets.fromLTRB(4,4, 4,4), child:new RaisedButton(
                                              onPressed:() {

                                              },
                                              color:Color(0xff20c67e),
                                              shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(5.0)),
                                              child:Text(
                                                "BOOKING CONFIRMED",
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    color: Color(0xffFFFFFF), fontFamily: "AVENIRLTSTD",fontWeight: FontWeight.normal),
                                              ),


                                            ),
                                            ):Padding(
                                              padding: new EdgeInsets.fromLTRB(4,4, 4,4), child:new RaisedButton(
                                              onPressed:() {

                                              },
                                              color:Colors.redAccent,
                                              shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(5.0)),
                                              child:Text(
                                                "BOOKING NOT CONFIRMED",
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    color: Color(0xffFFFFFF), fontFamily: "AVENIRLTSTD",fontWeight: FontWeight.normal),
                                              ),


                                            ),

                                            ),

                                            data[index]['percentage'] == 0? Padding(
                                              padding: new EdgeInsets.fromLTRB(4,4, 4,4), child:new RaisedButton(
                                              onPressed:() {

                                              },
                                              color:Colors.blueAccent,
                                              shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(5.0)),
                                              child:Text(
                                                "NEW JOB  ",
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    color: Color(0xffFFFFFF), fontFamily: "AVENIRLTSTD",fontWeight: FontWeight.normal),
                                              ),


                                            ),
                                            ):Padding(
                                              padding: new EdgeInsets.fromLTRB(4,4, 4,4), child:new RaisedButton(
                                              onPressed:() {

                                              },
                                              color:Colors.orange,
                                              shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(5.0)),
                                              child:Text(
                                                "ONGOING INSPECTION",
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    color: Color(0xffFFFFFF), fontFamily: "AVENIRLTSTD",fontWeight: FontWeight.normal),
                                              ),


                                            ),

                                            ),
                                          ]
                                      ),
                                    ),

                                  ),
                                ):Container();


                              },

                            ),

                            SizedBox(height: 20,),
                            Padding(
                              padding: const EdgeInsets.all(4.0),
                              child:Text("Inspection(s) future date",
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontFamily: "AVENIRLTSD",
                                      fontWeight: FontWeight.w700,
                                      // fontWeight: FontWeight.bold,
                                      color: Color(0xff000000))),
                            ),
                            ListView.builder(

                              physics: NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: data.length,
                              itemBuilder: (context, index) {

                                var dayOfWeek = 1;
                                DateTime date = DateTime.now();
                                DateTime mondaydateofcurrentdate=DateTime.now().subtract(new Duration(days: date.weekday-1));
                                DateTime bookingDate = DateTime.parse("${data[index]['booking_date_time'].toString().substring(0,10)} "+"00:00:00.000z");
                                DateTime mondayofbookingDate=DateTime.parse("${data[index]['booking_date_time'].toString().substring(0,10)} "+"00:00:00.000z").subtract(new Duration(days: bookingDate.weekday-1));

                                differencedate = mondayofbookingDate.difference(mondaydateofcurrentdate).inDays;

                                // print(data[index]['is_confirm']);
                                return differencedate>=13?InkWell(
                                  onTap: () => data[index]['is_compliant'] == 3 ||
                                      data[index]['is_confirm'] == 1
                                      ? Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => InspectionHeadingList(
                                              predata: data[index],
                                              bookingid: data[index]['id'])))
                                      : Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            PreliminaryWidget(data[index]['id'])),
                                  ),

                                  child:  Card(
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(

                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Padding(

                                              child:Text("${data[index]['owner_land']}",
                                                  style: TextStyle(
                                                      fontSize: 20,
                                                      fontFamily: "AVENIRLTSTD",
                                                      // fontWeight: FontWeight.bold,
                                                      color: Color(0xff000000))),
                                              padding: const EdgeInsets.fromLTRB(8, 4, 4, 4),
                                            ) ,
                                            Padding(

                                              child:     Row(
                                                  mainAxisSize: MainAxisSize.max,
                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                  children: <Widget>[

                                                    Icon(Icons.home,color: Color(0xff999999),size: 16,),
                                                    SizedBox(width: 5,),

                                                   Flexible(child:  Text("${data[index]['street_road']} ${data[index]['city_suburb']} ${data[index]['postcode']}", style: TextStyle(
                                                       fontFamily: "AVENIRLTSTD",
                                                       fontSize: 16,
                                                       color: Color(0xff999999),
                                                       fontWeight: FontWeight.normal),),),
                                                  ]
                                              ),
                                              padding: const EdgeInsets.all(4.0),
                                            ) ,
                                            Padding(

                                              child: Row(
                                                  mainAxisSize: MainAxisSize.max,
                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                  children: <Widget>[

                                                    Icon(Icons.date_range,color: Color(0xff999999),size: 15,),
                                                    SizedBox(width: 5,),

                                                    Text(DateFormat("dd-MM-yyyy").format(DateTime.parse("${data[index]['booking_date_time'].toString().substring(0,10)} "+"00:00:00.000z")).toString(), style: TextStyle(
                                                        fontFamily: "AVENIRLTSTD",
                                                        fontSize: 16,
                                                        color: Color(0xff999999),
                                                        fontWeight: FontWeight.normal),),

                                                  ]
                                              ),
                                              padding: const EdgeInsets.all(4.0),
                                            ) ,
                                            Padding(

                                              child: Row(
                                                  mainAxisSize: MainAxisSize.max,
                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                  children: <Widget>[

                                                    Icon(Icons.phone,color: Color(0xff999999),size: 16,),
                                                    SizedBox(width: 5,),

                                                    Text("${data[index]['phonenumber']}", style: TextStyle(
                                                        fontFamily: "AVENIRLTSTD",
                                                        fontSize: 16,
                                                        color: Color(0xff999999),
                                                        fontWeight: FontWeight.normal),),
                                                  ]
                                              ),
                                              padding: const EdgeInsets.all(2.0),
                                            ),

                                            data[index]['is_compliant'] == 3 || data[index]['is_confirm'] == 1? Padding(
                                              padding: new EdgeInsets.fromLTRB(4,4, 4,4), child:new RaisedButton(
                                              onPressed:() {

                                              },
                                              color:Color(0xff20c67e),
                                              shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(5.0)),
                                              child:Text(
                                                "BOOKING CONFIRMED",
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    color: Color(0xffFFFFFF), fontFamily: "AVENIRLTSTD",fontWeight: FontWeight.normal),
                                              ),


                                            ),
                                            ):Padding(
                                              padding: new EdgeInsets.fromLTRB(4,4, 4,4), child:new RaisedButton(
                                              onPressed:() {

                                              },
                                              color:Colors.redAccent,
                                              shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(5.0)),
                                              child:Text(
                                                "BOOKING NOT CONFIRMED",
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    color: Color(0xffFFFFFF), fontFamily: "AVENIRLTSTD",fontWeight: FontWeight.normal),
                                              ),


                                            ),

                                            ),

                                            data[index]['percentage'] == 0? Padding(
                                              padding: new EdgeInsets.fromLTRB(4,4, 4,4), child:new RaisedButton(
                                              onPressed:() {

                                              },
                                              color:Colors.blueAccent,
                                              shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(5.0)),
                                              child:Text(
                                                "NEW JOB  ",
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    color: Color(0xffFFFFFF), fontFamily: "AVENIRLTSTD",fontWeight: FontWeight.normal),
                                              ),


                                            ),
                                            ):Padding(
                                              padding: new EdgeInsets.fromLTRB(4,4, 4,4), child:new RaisedButton(
                                              onPressed:() {

                                              },
                                              color:Colors.orange,
                                              shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(5.0)),
                                              child:Text(
                                                "ONGOING INSPECTION",
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    color: Color(0xffFFFFFF), fontFamily: "AVENIRLTSTD",fontWeight: FontWeight.normal),
                                              ),


                                            ),

                                            ),

                                          ]
                                      ),
                                    ),

                                  ),
                                ):Container();


                              },

                            ),

                          ]

                      )
                  )
                      :SingleChildScrollView(
                      physics: ScrollPhysics(),
                      child: Column(

                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.all(4.0),
                              child:Text("Inspection(s) this week",
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontFamily: "AVENIRLTSD",
                                      fontWeight: FontWeight.w600,
                                      // fontWeight: FontWeight.bold,
                                      color: Color(0xff000000))),
                            ),
                            callAX(),
                            Card(
                  child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child:Column(

                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                           Padding(
                             padding: EdgeInsets.all(12.0),
                             child:  Row(
                                 mainAxisSize: MainAxisSize.max,
                                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                 children: <Widget>[
                                Expanded(
                                  flex: 1,
                                  child:Text("#", style: TextStyle(
                                      fontFamily: "AVENIRLTSTD",
                                      fontSize: 20,
                                      color: Color(0xff000000),
                                      fontWeight: FontWeight.w800),),
                                ),

                       Expanded(child:Text("Owner's Name & Address", style: TextStyle(
                           fontFamily: "AVENIRLTSTD",
                           fontSize: 20,
                           color: Color(0xff000000),
                           fontWeight: FontWeight.w800),) ,flex: 2,),

                       Expanded(
                         child:  Align(child: Text("Date/Time", style: TextStyle(
                             fontFamily: "AVENIRLTSTD",
                             fontSize: 20,
                             color: Color(0xff000000),
                             fontWeight: FontWeight.w800),),alignment: Alignment.center,),flex: 2,
                       ),

                       Expanded(child:Align(child: Text("Contact", style: TextStyle(
                           fontFamily: "AVENIRLTSTD",
                           fontSize: 20,
                           color: Color(0xff000000),
                           fontWeight: FontWeight.w800),),alignment: Alignment.center,),flex: 1,),


                                 ]
                             ),
                           ),
                             Padding(
                    padding: EdgeInsets.fromLTRB(5,0,5,10),
                  child: Divider(color: Colors.grey,thickness: 1,),
                ),
                            ListView.builder(

                              physics: NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: data.length,
                              itemBuilder: (context, index) {


                                var dayOfWeek = 1;
                                DateTime date = DateTime.now();
                                DateTime mondaydateofcurrentdate=DateTime.now().subtract(new Duration(days: date.weekday-1));
                                DateTime bookingDate = DateTime.parse("${data[index]['booking_date_time'].toString().substring(0,10)} "+"00:00:00.000z");
                                DateTime mondayofbookingDate=DateTime.parse("${data[index]['booking_date_time'].toString().substring(0,10)} "+"00:00:00.000z").subtract(new Duration(days: bookingDate.weekday-1));
                                print("errorinbookingdate="+bookingDate.toString());

                                differencedate = mondayofbookingDate.difference(mondaydateofcurrentdate).inDays;

//                                print("qxcurrentday=${date.weekday}");
//                                print("qxmondayofcurrentdate="+mondaydateofcurrentdate.toString());
//                                print("qxmondayofbookingdate="+mondayofbookingDate.toString());
//                                print("qxbookingday=${bookingDate.weekday}");
//                                print("qxcurrentdate=$date");
//                                print("qxbookingdate=$bookingDate");
//                                print("lqxdifference=$differencedate");
                                // print(data[index]['is_confirm']);
                                return differencedate>=0 && differencedate<6?InkWell(
                                  onTap: () {
                                    print("goku"+data[index]['booking_time']);
                                    data[index]['is_compliant'] == 3 ||
                                        data[index]['is_confirm'] == 1
                                        ? Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                InspectionHeadingList(
                                                    predata: data[index],
                                                    bookingid: data[index]['id'])))
                                        : Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              PreliminaryWidget(
                                                  data[index]['id'])),
                                    );
                                  },

                                  child: Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Column(
                                      children: <Widget>[

                                        Row(
                                            mainAxisSize: MainAxisSize.max,
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: <Widget>[

                                              Expanded(child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: <Widget>[

                                                    Text((++ax).toString(), style: TextStyle(
                                                        fontFamily: "AVENIRLTSTD",
                                                        fontSize: 21,
                                                        color: Color(0xff000000),
                                                        fontWeight: FontWeight.normal),),

                                                    Text("",maxLines: 2, style: TextStyle(
                                                        fontFamily: "AVENIRLTSTD",
                                                        fontSize: 18,
                                                        color: Color(0xffffffff),
                                                        fontWeight: FontWeight.w800),),

                                                    Text("", style: TextStyle(
                                                        fontFamily: "AVENIRLTSTD",
                                                        fontSize: 18,
                                                        color: Color(0xffffffff),
                                                        fontWeight: FontWeight.w800),),

                                                    Text("", style: TextStyle(
                                                        fontFamily: "AVENIRLTSTD",
                                                        fontSize: 18,
                                                        color: Color(0xffffffff),
                                                        fontWeight: FontWeight.w800),),
                                                    Text("", style: TextStyle(
                                                        fontFamily: "AVENIRLTSTD",
                                                        fontSize: 18,
                                                        color: Color(0xffffffff),
                                                        fontWeight: FontWeight.w800),),
                                                    SizedBox(height: 15,),


                                                  ]
                                              ) ,flex: 1,),
                                              Expanded(child:Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: <Widget>[

                                                    Text("${data[index]['owner_land']}", style: TextStyle(
                                                        fontFamily: "AVENIRLTSTD",
                                                        fontSize: 20,
                                                        color: Color(0xff000000),
                                                        fontWeight: FontWeight.w800),),

                                                    SizedBox(height: 10,),
                                                    Text("${data[index]['street_road']} ${data[index]['city_suburb']} ${data[index]['postcode']}", style: TextStyle(
                                                        fontFamily: "AVENIRLTSTD",
                                                        fontSize: 20,
                                                        color: Color(0xff000000),
                                                        fontWeight: FontWeight.normal),),

                                                    SizedBox(height: 10,),
                                                    data[index]['is_compliant'] == 3 || data[index]['is_confirm'] == 1? Padding(
                                                      padding: new EdgeInsets.fromLTRB(4,4, 4,4), child:new RaisedButton(
                                                      onPressed:() {

                                                      },
                                                      color:Color(0xff20c67e),
                                                      shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(5.0)),
                                                      child:Text(
                                                        "BOOKING CONFIRMED",
                                                        style: TextStyle(
                                                            fontSize: 12,
                                                            color: Color(0xffFFFFFF), fontFamily: "AVENIRLTSTD",fontWeight: FontWeight.normal),
                                                      ),


                                                    ),
                                                    ):Padding(
                                                      padding: new EdgeInsets.fromLTRB(4,4, 4,4), child:new RaisedButton(
                                                      onPressed:() {

                                                      },
                                                      color:Colors.redAccent,
                                                      shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(5.0)),
                                                      child:Text(
                                                        "BOOKING NOT CONFIRMED",
                                                        style: TextStyle(
                                                            fontSize: 12,
                                                            color: Color(0xffFFFFFF), fontFamily: "AVENIRLTSTD",fontWeight: FontWeight.normal),
                                                      ),


                                                    ),

                                                    ),

                                                    SizedBox(height: 10,),


                                                  ]
                                              ),flex: 2,) ,
                                              Expanded(child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                  children: <Widget>[
//data[index]['booking_date_time'].toString().substring(8,10)+":"+data[index]['booking_date_time'].toString().substring(5,7)+":"+
//                                                    Text(DateFormat.yMMMMd('en_US').format(DateTime.parse("${data[index]['booking_date_time']} ".substring(0,10))).toString(), style: TextStyle(
                                                    Align(

                                                      child: Text(DateFormat("dd-MM-yyyy").format(DateTime.parse("${data[index]['booking_date_time'].toString().substring(0,10)} "+"00:00:00.000z")).toString(), style: TextStyle(
                                                          fontFamily: "AVENIRLTSTD",
                                                          fontSize: 20,
                                                          color: Color(0xff000000),
                                                          fontWeight: FontWeight.normal),),
                                                    ),

                                                    SizedBox(height: 8,),
                                                    Text(DateFormat.jm().format(DateTime.parse("2012-07-07 "+"${data[index]['booking_time']}"))+"   ",style: TextStyle(
                                                        fontFamily: "AVENIRLTSTD",
                                                        fontSize: 20,
                                                        color: Color(0xff000000),
                                                        fontWeight: FontWeight.normal),),

                                                    SizedBox(height: 10,),
                                                    data[index]['percentage'] == 0? Padding(
                                                      padding: new EdgeInsets.fromLTRB(4,4, 4,4), child:new RaisedButton(
                                                      onPressed:() {

                                                      },
                                                      color:Colors.blueAccent,
                                                      shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(5.0)),
                                                      child:Text(
                                                        "NEW JOB  ",
                                                        style: TextStyle(
                                                            fontSize: 12,
                                                            color: Color(0xffFFFFFF), fontFamily: "AVENIRLTSTD",fontWeight: FontWeight.normal),
                                                      ),


                                                    ),
                                                    ):Padding(
                                                      padding: new EdgeInsets.fromLTRB(4,4, 4,4), child:new RaisedButton(
                                                      onPressed:() {

                                                      },
                                                      color:Colors.orange,
                                                      shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(5.0)),
                                                      child:Text(
                                                        "ONGOING INSPECTION",
                                                        style: TextStyle(
                                                            fontSize: 12,
                                                            color: Color(0xffFFFFFF), fontFamily: "AVENIRLTSTD",fontWeight: FontWeight.normal),
                                                      ),


                                                    ),

                                                    ),
                                                    SizedBox(height: 6,),
                                                  ]
                                              ),flex: 2,),
                                              Expanded(child:Column(
                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                  children: <Widget>[

                                                    Text("${data[index]['phonenumber']}", style: TextStyle(
                                                        fontFamily: "AVENIRLTSTD",
                                                        fontSize: 20,
                                                        color: Color(0xff000000),
                                                        fontWeight: FontWeight.normal),),

                                                    Text("", style: TextStyle(
                                                        fontFamily: "AVENIRLTSTD",
                                                        fontSize: 20,
                                                        color: Color(0xffffffff),
                                                        fontWeight: FontWeight.normal),),

                                                    SizedBox(height: 80,),
                                                  ]
                                              ),flex: 1,),


//                                        Padding(
//
//                                          child: Row(
//                                              mainAxisSize: MainAxisSize.max,
//                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                              children: <Widget>[
//
//
//
//                                                Text("", style: TextStyle(
//                                                    fontFamily: "AVENIRLTSTD",
//                                                    fontSize: 16,
//                                                    color: Color(0xffffffff),
//                                                    fontWeight: FontWeight.normal),),
//
//
//
//                                              Text("${data[index]['street_road']} ${data[index]['city_suburb']} ${data[index]['postcode']}"+"dddddddddddddddddddddddddddddddddddd",maxLines: 2, style: TextStyle(
//                                                    fontFamily: "AVENIRLTSTD",
//                                                    fontSize: 18,
//
//                                                    color: Color(0xff999999),
//                                                    fontWeight: FontWeight.w800),),
//
//                                                Text(DateFormat.yMMMMd('en_US').format(DateTime.parse("${data[index]['booking_date_time']} ".substring(0,10))).toString(), style: TextStyle(
//                                                    fontFamily: "AVENIRLTSTD",
//                                                    fontSize: 18,
//                                                    color: Color(0xff000000),
//                                                    fontWeight: FontWeight.w700),),
//                                                Text("Dummy", style: TextStyle(
//                                                    fontFamily: "AVENIRLTSTD",
//                                                    fontSize: 18,
//                                                    color: Color(0xffffffff),
//                                                    fontWeight: FontWeight.w800),),
//                                              ]
//                                          ),
//                                          padding: const EdgeInsets.all(4.0),
//                                        ) ,
//                                        Padding(
//
//                                          child: Row(
//                                              mainAxisSize: MainAxisSize.max,
//                                              mainAxisAlignment: MainAxisAlignment.start,
//                                              children: <Widget>[
//
//                                                Icon((IconData(0xe800, fontFamily: _kFontFam)),size: 7,),
//
//                                                Text(DateFormat.yMMMMd('en_US').format(DateTime.parse("${data[index]['booking_date_time']} ".substring(0,10))).toString(), style: TextStyle(
//                                                    fontFamily: "AVENIRLTSTD",
//                                                    fontSize: 16,
//                                                    color: Color(0xff999999),
//                                                    fontWeight: FontWeight.normal),),
//                                              ]
//                                          ),
//                                          padding: const EdgeInsets.all(4.0),
//                                        ) ,
//                                        Padding(
//
//                                          child: Row(
//                                              mainAxisSize: MainAxisSize.max,
//                                              mainAxisAlignment: MainAxisAlignment.start,
//                                              children: <Widget>[
//
//                                                Icon((IconData(0xe300, fontFamily: _kFontFam)),size: 7,),
//
//                                                Text("${data[index]['phonenumber']}", style: TextStyle(
//                                                    fontFamily: "AVENIRLTSTD",
//                                                    fontSize: 16,
//                                                    color: Color(0xff999999),
//                                                    fontWeight: FontWeight.normal),),
//                                              ]
//                                          ),
//                                          padding: const EdgeInsets.all(2.0),
//                                        ) ,

                                            ]
                                        ),
                                        Divider(color: Colors.grey,thickness: 1,)
                                      ],
                                    ),
                                  )



                                ):Container();


                              },

                            ),
                            ]
                      ),
                      ),
                            ),
                            SizedBox(height: 20,),

                            Padding(
                              padding: const EdgeInsets.all(4.0),
                              child:Text("Inspection(s) next week",
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontFamily: "AVENIRLTSD",
                                      fontWeight: FontWeight.w600,
                                      // fontWeight: FontWeight.bold,
                                      color: Color(0xff000000))),
                            ),
                            callAX(),
                            Card(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child:Column(

                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Padding(
                                        padding: EdgeInsets.all(12.0),
                                        child:  Row(
                                            mainAxisSize: MainAxisSize.max,
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: <Widget>[
                                              Expanded(
                                                flex: 1,
                                                child:Text("#", style: TextStyle(
                                                    fontFamily: "AVENIRLTSTD",
                                                    fontSize: 20,
                                                    color: Color(0xff000000),
                                                    fontWeight: FontWeight.w800),),
                                              ),

                                              Expanded(child:Text("Owner's Name & Address", style: TextStyle(
                                                  fontFamily: "AVENIRLTSTD",
                                                  fontSize: 20,
                                                  color: Color(0xff000000),
                                                  fontWeight: FontWeight.w800),) ,flex: 2,),

                                              Expanded(
                                                child:  Align(child: Text("Date/Time", style: TextStyle(
                                                    fontFamily: "AVENIRLTSTD",
                                                    fontSize: 20,
                                                    color: Color(0xff000000),
                                                    fontWeight: FontWeight.w800),),alignment: Alignment.center,),flex: 2,
                                              ),

                                              Expanded(child:Align(child: Text("Contact", style: TextStyle(
                                                  fontFamily: "AVENIRLTSTD",
                                                  fontSize: 20,
                                                  color: Color(0xff000000),
                                                  fontWeight: FontWeight.w800),),alignment: Alignment.center,),flex: 1,),



                                            ]
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.fromLTRB(5,0,5,10),
                                        child: Divider(color: Colors.grey,thickness: 1,),
                                      ),

                                      ListView.builder(

                                        physics: NeverScrollableScrollPhysics(),
                                        shrinkWrap: true,
                                        itemCount: data.length,
                                        itemBuilder: (context, index) {

                                          var dayOfWeek = 1;
                                          DateTime date = DateTime.now();
                                          DateTime mondaydateofcurrentdate=DateTime.now().subtract(new Duration(days: date.weekday-1));
                                          DateTime bookingDate = DateTime.parse("${data[index]['booking_date_time'].toString().substring(0,10)} "+"00:00:00.000z");
                                          DateTime mondayofbookingDate=DateTime.parse("${data[index]['booking_date_time'].toString().substring(0,10)} "+"00:00:00.000z").subtract(new Duration(days: bookingDate.weekday-1));
                                          print("errorinbookingdate="+bookingDate.toString());

                                          differencedate = mondayofbookingDate.difference(mondaydateofcurrentdate).inDays;
                                          // print(data[index]['is_confirm']);
                                          return differencedate>=6 && differencedate<13?InkWell(
                                              onTap: () => data[index]['is_compliant'] == 3 ||
                                                  data[index]['is_confirm'] == 1
                                                  ? Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) => InspectionHeadingList(
                                                          predata: data[index],
                                                          bookingid: data[index]['id'])))
                                                  : Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        PreliminaryWidget(data[index]['id'])),
                                              ),

                                              child: Padding(
                                                padding: const EdgeInsets.all(12.0),
                                                child: Column(
                                                  children: <Widget>[

                                                    Row(
                                                        mainAxisSize: MainAxisSize.max,
                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                        children: <Widget>[

                                                          Expanded(child: Column(
                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                              children: <Widget>[

                                                                Text((++ax).toString(), style: TextStyle(
                                                                    fontFamily: "AVENIRLTSTD",
                                                                    fontSize: 21,
                                                                    color: Color(0xff000000),
                                                                    fontWeight: FontWeight.normal),),

                                                                Text("",maxLines: 2, style: TextStyle(
                                                                    fontFamily: "AVENIRLTSTD",
                                                                    fontSize: 18,
                                                                    color: Color(0xffffffff),
                                                                    fontWeight: FontWeight.w800),),

                                                                Text("", style: TextStyle(
                                                                    fontFamily: "AVENIRLTSTD",
                                                                    fontSize: 18,
                                                                    color: Color(0xffffffff),
                                                                    fontWeight: FontWeight.w800),),

                                                                Text("", style: TextStyle(
                                                                    fontFamily: "AVENIRLTSTD",
                                                                    fontSize: 18,
                                                                    color: Color(0xffffffff),
                                                                    fontWeight: FontWeight.w800),),
                                                                Text("", style: TextStyle(
                                                                    fontFamily: "AVENIRLTSTD",
                                                                    fontSize: 18,
                                                                    color: Color(0xffffffff),
                                                                    fontWeight: FontWeight.w800),),
                                                                SizedBox(height: 15,),


                                                              ]
                                                          ) ,flex: 1,),
                                                          Expanded(child:Column(
                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                              children: <Widget>[

                                                                Text("${data[index]['owner_land']}", style: TextStyle(
                                                                    fontFamily: "AVENIRLTSTD",
                                                                    fontSize: 20,
                                                                    color: Color(0xff000000),
                                                                    fontWeight: FontWeight.w800),),

                                                                SizedBox(height: 10,),
                                                                Text("${data[index]['street_road']} ${data[index]['city_suburb']} ${data[index]['postcode']}", style: TextStyle(
                                                                    fontFamily: "AVENIRLTSTD",
                                                                    fontSize: 20,
                                                                    color: Color(0xff000000),
                                                                    fontWeight: FontWeight.normal),),

                                                                SizedBox(height: 10,),
                                                                data[index]['is_compliant'] == 3 || data[index]['is_confirm'] == 1? Padding(
                                                                  padding: new EdgeInsets.fromLTRB(4,4, 4,4), child:new RaisedButton(
                                                                  onPressed:() {

                                                                  },
                                                                  color:Color(0xff20c67e),
                                                                  shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(5.0)),
                                                                  child:Text(
                                                                    "BOOKING CONFIRMED",
                                                                    style: TextStyle(
                                                                        fontSize: 12,
                                                                        color: Color(0xffFFFFFF), fontFamily: "AVENIRLTSTD",fontWeight: FontWeight.normal),
                                                                  ),


                                                                ),
                                                                ):Padding(
                                                                  padding: new EdgeInsets.fromLTRB(4,4, 4,4), child:new RaisedButton(
                                                                  onPressed:() {

                                                                  },
                                                                  color:Colors.redAccent,
                                                                  shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(5.0)),
                                                                  child:Text(
                                                                    "BOOKING NOT CONFIRMED",
                                                                    style: TextStyle(
                                                                        fontSize: 12,
                                                                        color: Color(0xffFFFFFF), fontFamily: "AVENIRLTSTD",fontWeight: FontWeight.normal),
                                                                  ),


                                                                ),

                                                                ),

                                                                SizedBox(height: 10,),


                                                              ]
                                                          ),flex: 2,) ,
                                                          Expanded(child: Column(
                                                              crossAxisAlignment: CrossAxisAlignment.center,
                                                              children: <Widget>[
//data[index]['booking_date_time'].toString().substring(8,10)+":"+data[index]['booking_date_time'].toString().substring(5,7)+":"+
//                                                    Text(DateFormat.yMMMMd('en_US').format(DateTime.parse("${data[index]['booking_date_time']} ".substring(0,10))).toString(), style: TextStyle(
                                                                Align(

                                                                  child: Text(DateFormat("dd-MM-yyyy").format(DateTime.parse("${data[index]['booking_date_time'].toString().substring(0,10)} "+"00:00:00.000z")).toString(), style: TextStyle(
                                                                      fontFamily: "AVENIRLTSTD",
                                                                      fontSize: 20,
                                                                      color: Color(0xff000000),
                                                                      fontWeight: FontWeight.normal),),
                                                                ),

                                                                SizedBox(height: 8,),
                                                                Text(DateFormat.jm().format(DateTime.parse("2012-07-07 "+"${data[index]['booking_time']}"))+"   ",style: TextStyle(
                                                                    fontFamily: "AVENIRLTSTD",
                                                                    fontSize: 20,
                                                                    color: Color(0xff000000),
                                                                    fontWeight: FontWeight.normal),),

                                                                SizedBox(height: 10,),
                                                                data[index]['percentage'] == 0? Padding(
                                                                  padding: new EdgeInsets.fromLTRB(4,4, 4,4), child:new RaisedButton(
                                                                  onPressed:() {

                                                                  },
                                                                  color:Colors.blueAccent,
                                                                  shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(5.0)),
                                                                  child:Text(
                                                                    "NEW JOB  ",
                                                                    style: TextStyle(
                                                                        fontSize: 12,
                                                                        color: Color(0xffFFFFFF), fontFamily: "AVENIRLTSTD",fontWeight: FontWeight.normal),
                                                                  ),


                                                                ),
                                                                ):Padding(
                                                                  padding: new EdgeInsets.fromLTRB(4,4, 4,4), child:new RaisedButton(
                                                                  onPressed:() {

                                                                  },
                                                                  color:Colors.orange,
                                                                  shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(5.0)),
                                                                  child:Text(
                                                                    "ONGOING INSPECTION",
                                                                    style: TextStyle(
                                                                        fontSize: 12,
                                                                        color: Color(0xffFFFFFF), fontFamily: "AVENIRLTSTD",fontWeight: FontWeight.normal),
                                                                  ),


                                                                ),

                                                                ),
                                                                SizedBox(height: 6,),
                                                              ]
                                                          ),flex: 2,),
                                                          Expanded(child:Column(
                                                              crossAxisAlignment: CrossAxisAlignment.center,
                                                              children: <Widget>[

                                                                Text("${data[index]['phonenumber']}", style: TextStyle(
                                                                    fontFamily: "AVENIRLTSTD",
                                                                    fontSize: 20,
                                                                    color: Color(0xff000000),
                                                                    fontWeight: FontWeight.normal),),

                                                                Text("", style: TextStyle(
                                                                    fontFamily: "AVENIRLTSTD",
                                                                    fontSize: 20,
                                                                    color: Color(0xffffffff),
                                                                    fontWeight: FontWeight.normal),),

                                                                SizedBox(height: 80,),
                                                              ]
                                                          ),flex: 1,),


//                                        Padding(
//
//                                          child: Row(
//                                              mainAxisSize: MainAxisSize.max,
//                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                              children: <Widget>[
//
//
//
//                                                Text("", style: TextStyle(
//                                                    fontFamily: "AVENIRLTSTD",
//                                                    fontSize: 16,
//                                                    color: Color(0xffffffff),
//                                                    fontWeight: FontWeight.normal),),
//
//
//
//                                              Text("${data[index]['street_road']} ${data[index]['city_suburb']} ${data[index]['postcode']}"+"dddddddddddddddddddddddddddddddddddd",maxLines: 2, style: TextStyle(
//                                                    fontFamily: "AVENIRLTSTD",
//                                                    fontSize: 18,
//
//                                                    color: Color(0xff999999),
//                                                    fontWeight: FontWeight.w800),),
//
//                                                Text(DateFormat.yMMMMd('en_US').format(DateTime.parse("${data[index]['booking_date_time']} ".substring(0,10))).toString(), style: TextStyle(
//                                                    fontFamily: "AVENIRLTSTD",
//                                                    fontSize: 18,
//                                                    color: Color(0xff000000),
//                                                    fontWeight: FontWeight.w700),),
//                                                Text("Dummy", style: TextStyle(
//                                                    fontFamily: "AVENIRLTSTD",
//                                                    fontSize: 18,
//                                                    color: Color(0xffffffff),
//                                                    fontWeight: FontWeight.w800),),
//                                              ]
//                                          ),
//                                          padding: const EdgeInsets.all(4.0),
//                                        ) ,
//                                        Padding(
//
//                                          child: Row(
//                                              mainAxisSize: MainAxisSize.max,
//                                              mainAxisAlignment: MainAxisAlignment.start,
//                                              children: <Widget>[
//
//                                                Icon((IconData(0xe800, fontFamily: _kFontFam)),size: 7,),
//
//                                                Text(DateFormat.yMMMMd('en_US').format(DateTime.parse("${data[index]['booking_date_time']} ".substring(0,10))).toString(), style: TextStyle(
//                                                    fontFamily: "AVENIRLTSTD",
//                                                    fontSize: 16,
//                                                    color: Color(0xff999999),
//                                                    fontWeight: FontWeight.normal),),
//                                              ]
//                                          ),
//                                          padding: const EdgeInsets.all(4.0),
//                                        ) ,
//                                        Padding(
//
//                                          child: Row(
//                                              mainAxisSize: MainAxisSize.max,
//                                              mainAxisAlignment: MainAxisAlignment.start,
//                                              children: <Widget>[
//
//                                                Icon((IconData(0xe300, fontFamily: _kFontFam)),size: 7,),
//
//                                                Text("${data[index]['phonenumber']}", style: TextStyle(
//                                                    fontFamily: "AVENIRLTSTD",
//                                                    fontSize: 16,
//                                                    color: Color(0xff999999),
//                                                    fontWeight: FontWeight.normal),),
//                                              ]
//                                          ),
//                                          padding: const EdgeInsets.all(2.0),
//                                        ) ,

                                                        ]
                                                    ),
                                                    Divider(color: Colors.grey,thickness: 1,)
                                                  ],
                                                )
                                              )



                                          ):Container();


                                        },

                                      ),
                                    ]
                                ),
                              ),





                            ),
                            SizedBox(height: 20,),

                            Padding(
                              padding: const EdgeInsets.all(4.0),
                              child:Text("Inspection(s) future date",
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontFamily: "AVENIRLTSD",
                                      fontWeight: FontWeight.w600,
                                      // fontWeight: FontWeight.bold,
                                      color: Color(0xff000000))),
                            ),
                            callAX(),
                            Card(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child:Column(

                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Padding(
                                        padding: EdgeInsets.all(12.0),
                                        child:  Row(
                                            mainAxisSize: MainAxisSize.max,
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: <Widget>[
                                              Expanded(
                                                flex: 1,
                                                child:Text("#", style: TextStyle(
                                                    fontFamily: "AVENIRLTSTD",
                                                    fontSize: 20,
                                                    color: Color(0xff000000),
                                                    fontWeight: FontWeight.w800),),
                                              ),

                                              Expanded(child:Text("Owner's Name & Address", style: TextStyle(
                                                  fontFamily: "AVENIRLTSTD",
                                                  fontSize: 20,
                                                  color: Color(0xff000000),
                                                  fontWeight: FontWeight.w800),) ,flex: 2,),

                                              Expanded(
                                                child:  Align(child: Text("Date/Time", style: TextStyle(
                                                    fontFamily: "AVENIRLTSTD",
                                                    fontSize: 20,
                                                    color: Color(0xff000000),
                                                    fontWeight: FontWeight.w800),),alignment: Alignment.center,),flex: 2,
                                              ),

                                              Expanded(child:Align(child: Text("Contact", style: TextStyle(
                                                  fontFamily: "AVENIRLTSTD",
                                                  fontSize: 20,
                                                  color: Color(0xff000000),
                                                  fontWeight: FontWeight.w800),),alignment: Alignment.center,),flex: 1,),



                                            ]
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.fromLTRB(5,0,5,10),
                                        child: Divider(color: Colors.grey,thickness: 1,),
                                      ),
                                      ListView.builder(

                                        physics: NeverScrollableScrollPhysics(),
                                        shrinkWrap: true,
                                        itemCount: data.length,
                                        itemBuilder: (context, index) {

                                          var dayOfWeek = 1;
                                          DateTime date = DateTime.now();
                                          DateTime mondaydateofcurrentdate=DateTime.now().subtract(new Duration(days: date.weekday-1));
                                          DateTime bookingDate = DateTime.parse("${data[index]['booking_date_time'].toString().substring(0,10)} "+"00:00:00.000z");
                                          DateTime mondayofbookingDate=DateTime.parse("${data[index]['booking_date_time'].toString().substring(0,10)} "+"00:00:00.000z").subtract(new Duration(days: bookingDate.weekday-1));
                                          print("errorinbookingdate="+bookingDate.toString());

                                          differencedate = mondayofbookingDate.difference(mondaydateofcurrentdate).inDays;
                                          // print(data[index]['is_confirm']);
                                          return differencedate>=13?InkWell(
                                              onTap: () => data[index]['is_compliant'] == 3 ||
                                                  data[index]['is_confirm'] == 1
                                                  ? Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) => InspectionHeadingList(
                                                          predata: data[index],
                                                          bookingid: data[index]['id'])))
                                                  : Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        PreliminaryWidget(data[index]['id'])),
                                              ),

                                              child: Padding(
                                                padding: const EdgeInsets.all(12.0),
                                                child:Column(
                                                  children: <Widget>[

                                                    Row(
                                                        mainAxisSize: MainAxisSize.max,
                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                        children: <Widget>[

                                                          Expanded(child: Column(
                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                              children: <Widget>[

                                                                Text((++ax).toString(), style: TextStyle(
                                                                    fontFamily: "AVENIRLTSTD",
                                                                    fontSize: 21,
                                                                    color: Color(0xff000000),
                                                                    fontWeight: FontWeight.normal),),

                                                                Text("",maxLines: 2, style: TextStyle(
                                                                    fontFamily: "AVENIRLTSTD",
                                                                    fontSize: 18,
                                                                    color: Color(0xffffffff),
                                                                    fontWeight: FontWeight.w800),),

                                                                Text("", style: TextStyle(
                                                                    fontFamily: "AVENIRLTSTD",
                                                                    fontSize: 18,
                                                                    color: Color(0xffffffff),
                                                                    fontWeight: FontWeight.w800),),

                                                                Text("", style: TextStyle(
                                                                    fontFamily: "AVENIRLTSTD",
                                                                    fontSize: 18,
                                                                    color: Color(0xffffffff),
                                                                    fontWeight: FontWeight.w800),),
                                                                Text("", style: TextStyle(
                                                                    fontFamily: "AVENIRLTSTD",
                                                                    fontSize: 18,
                                                                    color: Color(0xffffffff),
                                                                    fontWeight: FontWeight.w800),),
                                                                SizedBox(height: 15,),


                                                              ]
                                                          ) ,flex: 1,),
                                                          Expanded(child:Column(
                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                              children: <Widget>[

                                                                Text("${data[index]['owner_land']}", style: TextStyle(
                                                                    fontFamily: "AVENIRLTSTD",
                                                                    fontSize: 20,
                                                                    color: Color(0xff000000),
                                                                    fontWeight: FontWeight.w800),),

                                                                SizedBox(height: 10,),
                                                                Text("${data[index]['street_road']} ${data[index]['city_suburb']} ${data[index]['postcode']}", style: TextStyle(
                                                                    fontFamily: "AVENIRLTSTD",
                                                                    fontSize: 20,
                                                                    color: Color(0xff000000),
                                                                    fontWeight: FontWeight.normal),),

                                                                SizedBox(height: 10,),
                                                                data[index]['is_compliant'] == 3 || data[index]['is_confirm'] == 1? Padding(
                                                                  padding: new EdgeInsets.fromLTRB(4,4, 4,4), child:new RaisedButton(
                                                                  onPressed:() {

                                                                  },
                                                                  color:Color(0xff20c67e),
                                                                  shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(5.0)),
                                                                  child:Text(
                                                                    "BOOKING CONFIRMED",
                                                                    style: TextStyle(
                                                                        fontSize: 12,
                                                                        color: Color(0xffFFFFFF), fontFamily: "AVENIRLTSTD",fontWeight: FontWeight.normal),
                                                                  ),


                                                                ),
                                                                ):Padding(
                                                                  padding: new EdgeInsets.fromLTRB(4,4, 4,4), child:new RaisedButton(
                                                                  onPressed:() {

                                                                  },
                                                                  color:Colors.redAccent,
                                                                  shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(5.0)),
                                                                  child:Text(
                                                                    "BOOKING NOT CONFIRMED",
                                                                    style: TextStyle(
                                                                        fontSize: 12,
                                                                        color: Color(0xffFFFFFF), fontFamily: "AVENIRLTSTD",fontWeight: FontWeight.normal),
                                                                  ),


                                                                ),

                                                                ),

                                                                SizedBox(height: 10,),


                                                              ]
                                                          ),flex: 2,) ,
                                                          Expanded(child: Column(
                                                              crossAxisAlignment: CrossAxisAlignment.center,
                                                              children: <Widget>[
//data[index]['booking_date_time'].toString().substring(8,10)+":"+data[index]['booking_date_time'].toString().substring(5,7)+":"+
//                                                    Text(DateFormat.yMMMMd('en_US').format(DateTime.parse("${data[index]['booking_date_time']} ".substring(0,10))).toString(), style: TextStyle(
                                                                Align(

                                                                  child: Text(DateFormat("dd-MM-yyyy").format(DateTime.parse("${data[index]['booking_date_time'].toString().substring(0,10)} "+"00:00:00.000z")).toString(), style: TextStyle(
                                                                      fontFamily: "AVENIRLTSTD",
                                                                      fontSize: 20,
                                                                      color: Color(0xff000000),
                                                                      fontWeight: FontWeight.normal),),
                                                                ),

                                                                SizedBox(height: 8,),
                                                                Text(DateFormat.jm().format(DateTime.parse("2012-07-07 "+"${data[index]['booking_time']}"))+"   ",style: TextStyle(
                                                                    fontFamily: "AVENIRLTSTD",
                                                                    fontSize: 20,
                                                                    color: Color(0xff000000),
                                                                    fontWeight: FontWeight.normal),),

                                                                SizedBox(height: 10,),
                                                                data[index]['percentage'] == 0? Padding(
                                                                  padding: new EdgeInsets.fromLTRB(4,4, 4,4), child:new RaisedButton(
                                                                  onPressed:() {

                                                                  },
                                                                  color:Colors.blueAccent,
                                                                  shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(5.0)),
                                                                  child:Text(
                                                                    "NEW JOB  ",
                                                                    style: TextStyle(
                                                                        fontSize: 12,
                                                                        color: Color(0xffFFFFFF), fontFamily: "AVENIRLTSTD",fontWeight: FontWeight.normal),
                                                                  ),


                                                                ),
                                                                ):Padding(
                                                                  padding: new EdgeInsets.fromLTRB(4,4, 4,4), child:new RaisedButton(
                                                                  onPressed:() {

                                                                  },
                                                                  color:Colors.orange,
                                                                  shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(5.0)),
                                                                  child:Text(
                                                                    "ONGOING INSPECTION",
                                                                    style: TextStyle(
                                                                        fontSize: 12,
                                                                        color: Color(0xffFFFFFF), fontFamily: "AVENIRLTSTD",fontWeight: FontWeight.normal),
                                                                  ),


                                                                ),

                                                                ),
                                                                SizedBox(height: 6,),
                                                              ]
                                                          ),flex: 2,),
                                                          Expanded(child:Column(
                                                              crossAxisAlignment: CrossAxisAlignment.center,
                                                              children: <Widget>[

                                                                Text("${data[index]['phonenumber']}", style: TextStyle(
                                                                    fontFamily: "AVENIRLTSTD",
                                                                    fontSize: 20,
                                                                    color: Color(0xff000000),
                                                                    fontWeight: FontWeight.normal),),

                                                                Text("", style: TextStyle(
                                                                    fontFamily: "AVENIRLTSTD",
                                                                    fontSize: 20,
                                                                    color: Color(0xffffffff),
                                                                    fontWeight: FontWeight.normal),),

                                                                SizedBox(height: 80,),
                                                              ]
                                                          ),flex: 1,),


//                                        Padding(
//
//                                          child: Row(
//                                              mainAxisSize: MainAxisSize.max,
//                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                              children: <Widget>[
//
//
//
//                                                Text("", style: TextStyle(
//                                                    fontFamily: "AVENIRLTSTD",
//                                                    fontSize: 16,
//                                                    color: Color(0xffffffff),
//                                                    fontWeight: FontWeight.normal),),
//
//
//
//                                              Text("${data[index]['street_road']} ${data[index]['city_suburb']} ${data[index]['postcode']}"+"dddddddddddddddddddddddddddddddddddd",maxLines: 2, style: TextStyle(
//                                                    fontFamily: "AVENIRLTSTD",
//                                                    fontSize: 18,
//
//                                                    color: Color(0xff999999),
//                                                    fontWeight: FontWeight.w800),),
//
//                                                Text(DateFormat.yMMMMd('en_US').format(DateTime.parse("${data[index]['booking_date_time']} ".substring(0,10))).toString(), style: TextStyle(
//                                                    fontFamily: "AVENIRLTSTD",
//                                                    fontSize: 18,
//                                                    color: Color(0xff000000),
//                                                    fontWeight: FontWeight.w700),),
//                                                Text("Dummy", style: TextStyle(
//                                                    fontFamily: "AVENIRLTSTD",
//                                                    fontSize: 18,
//                                                    color: Color(0xffffffff),
//                                                    fontWeight: FontWeight.w800),),
//                                              ]
//                                          ),
//                                          padding: const EdgeInsets.all(4.0),
//                                        ) ,
//                                        Padding(
//
//                                          child: Row(
//                                              mainAxisSize: MainAxisSize.max,
//                                              mainAxisAlignment: MainAxisAlignment.start,
//                                              children: <Widget>[
//
//                                                Icon((IconData(0xe800, fontFamily: _kFontFam)),size: 7,),
//
//                                                Text(DateFormat.yMMMMd('en_US').format(DateTime.parse("${data[index]['booking_date_time']} ".substring(0,10))).toString(), style: TextStyle(
//                                                    fontFamily: "AVENIRLTSTD",
//                                                    fontSize: 16,
//                                                    color: Color(0xff999999),
//                                                    fontWeight: FontWeight.normal),),
//                                              ]
//                                          ),
//                                          padding: const EdgeInsets.all(4.0),
//                                        ) ,
//                                        Padding(
//
//                                          child: Row(
//                                              mainAxisSize: MainAxisSize.max,
//                                              mainAxisAlignment: MainAxisAlignment.start,
//                                              children: <Widget>[
//
//                                                Icon((IconData(0xe300, fontFamily: _kFontFam)),size: 7,),
//
//                                                Text("${data[index]['phonenumber']}", style: TextStyle(
//                                                    fontFamily: "AVENIRLTSTD",
//                                                    fontSize: 16,
//                                                    color: Color(0xff999999),
//                                                    fontWeight: FontWeight.normal),),
//                                              ]
//                                          ),
//                                          padding: const EdgeInsets.all(2.0),
//                                        ) ,

                                                        ]
                                                    ),
                                                    Divider(color: Colors.grey,thickness: 1,)
                                                  ],
                                                )
                                              )



                                          ):Container();


                                        },

                                      ),
                                    ]
                                ),
                              ),





                            ),
                            SizedBox(height: 20,),
                          ]

                      )



)
          )
      ),
    );
  }

  InkWell buildCardTop(double percent, String text, Color color, String string,
      String stringcolored, int index) {
    return InkWell(
      onTap: () {
        index == 1
            ? setState(() {
                filter = false;
              })
            : setState(() {
                filter = true;
              });
      },
      child: Card(
        elevation: 1.0,
        // margin: EdgeInsets.all(10),
        color: Colors.white,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.95 / 2,
          height: 100,
          child: Padding(
            padding: const EdgeInsets.all(2.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              // crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[

                RichText(
                    text: TextSpan(children: [
                      TextSpan(
                          text: '$string\n',

                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueGrey,
                            fontFamily: "AVENIRLTSTD",
                          )),
                      TextSpan(
                          text: stringcolored,
                          style: TextStyle(
                            fontSize: 18,
                            color: color,
                            fontWeight: FontWeight.bold,
                            fontFamily: "AVENIRLTSTD",
                          )),
                    ])),
                SizedBox(width: 4.0),
                CircularPercentIndicator(
                  animation: true,
                  animationDuration: 2000,
                  radius: 60.0,
                  lineWidth: 5.0,
                  percent: percent,
                  center: new Text(text,
                      style: TextStyle(
                          fontSize: 20,
                            fontFamily: "AVENIRLTSTD",
                          // fontWeight: FontWeight.bold,
                          color: Color(0xff222222))),
                  progressColor: color,
                ),

              ],
            ),
          ),
        ),
      ),
    );
  }
  Widget callAX()
  {
    ax=0;
    return Container();
  }
}
