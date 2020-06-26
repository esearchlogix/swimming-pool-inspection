import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:poolinspection/config/app_config.dart' as config;
import 'package:poolinspection/src/controllers/inspection_controller.dart';
import 'package:poolinspection/src/helpers/connectivity.dart';
import 'package:poolinspection/src/models/getpaymentdetailmodel.dart';
import 'package:poolinspection/src/models/questionmodel.dart';
import 'package:poolinspection/src/models/selectCompliantOrNotice.dart';
import 'package:poolinspection/src/pages/reports/reportdetail.dart';
import 'package:poolinspection/src/pages/utils/radiobutton.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'inspectionquestionslist.dart';
import 'dart:developer';



class InspectionHeadingList extends StatefulWidget {
  var predata;
  int bookingid;


  InspectionHeadingList({this.predata, this.bookingid});
  @override
  _InspectionHeadingListState createState() => _InspectionHeadingListState();
}

class _InspectionHeadingListState extends StateMVC<InspectionHeadingList> {
  InspectionController _con;
  bool filter = false;
  int headingcompleted = 0;
  String ownerland;
  bool syncdata=false;
 // List<String> offlineheadinglist=new List();
  bool isOnline=false;
  StreamSubscription _connectionChangeStream;
  ConnectionStatusSingleton connectionStatus;

  _InspectionHeadingListState() : super(InspectionController()) {
    _con = controller;
  }

  Future sendQuestionAnswerOfflineData(String data) async {
    debugPrint("dataofserver"+data.toString());

    ProgressDialog pr;

    pr = new ProgressDialog(context);
    try {

      if(data!=null&& data!='{"answers":[]}'.toString()) {
        pr.show();
        final response = await http.post(
            'https://poolinspection.beedevstaging.com/api/beedev/local-storage-send-ans',
            body: data
        );
          print("qwertyuiop"+response.body.toString());
        SelectNonCompliantOrNotice selectNonCompliantOrNotice = selectNonCompliantOrNoticeFromJson(
            response.body);
        print("responseofflinesend" +
            selectNonCompliantOrNotice.status.toString());

        if (selectNonCompliantOrNotice.status.toString() == "success") {
          await pr.hide();
          //after sync empty
          Fluttertoast.showToast(
              msg: "Successfully Saved",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.red,
              textColor: Colors.white,
              fontSize: 16.0
          );
          setState(() {
            syncdata=true;
          });
       await _con.StoreQuestionAnswerInLocal("", "questionanswer");
        }
        else {
          await pr.hide();
          Fluttertoast.showToast(
              msg: "Connection Time Out ",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.red,
              textColor: Colors.white,
              fontSize: 16.0
          );
        }
      }
      else
        {
          Fluttertoast.showToast(
              msg: "All Data Synced",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.blue,
              textColor: Colors.white,
              fontSize: 16.0
          );

          setState(() {
            syncdata=true;
          });
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

  Future CheckingInternet() async
  {

    //  _connectionChangeStream = await connectionStatus.connectionChange.listen(connectionChanged);
    await connectionStatus.checkConnection().then((val) {
      val ? loadData() :refreshOfflineId();
      isOnline = val;
    });


  }

  QuestionModel model;
  @override
  void initState() {
    //print("cancan"+widget.predata.toString());
    connectionStatus = ConnectionStatusSingleton.getInstance();


    WidgetsBinding.instance.addPostFrameCallback((_){

      CheckingInternet();

    });
//    _con.getQuestionsFilled(widget.bookingid);
//    _con.getheadings(widget.bookingid);


    super.initState();
  }
  void connectionChanged(dynamic hasConnection) {   //later use
    setState(() {
      connectionStatus.checkConnection().then((val) {
        val ? loadData() : refreshOfflineId();
        isOnline= val;
      });
      // isOffline = !hasConnection;
    });
  }
  Future<Timer> loadData() async {
    return new Timer(Duration(seconds: 0), onDoneLoading);
  }
  onDoneLoading() async {
    // print(currentUser.token2fa);

    refreshId();

  }
  Future refreshId() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString("ownerland",widget.predata['owner_land'].toString());
    _con.headingslist = [];
      setState(() {

        _con.questionpendingcount = 0;
        _con.questionpending = false;
        _con.getQuestionsFilled(widget.bookingid);

        _con.getheadings(widget.bookingid);
      });


  }
  Future refreshOfflineId() async {
    final prefs = await SharedPreferences.getInstance();
    ownerland=prefs.get("ownerland");
    print("ownerland="+ownerland.toString());
    _con.headingslist = [];
    setState(() {

      _con.readCounter(widget.bookingid.toString()).then((onValue) {
       var onOfflineValue=json.decode(onValue.toString());

        setState(() {
          print("insideoffline");

          for (var i = 0;
          i < onOfflineValue['get_heading_from_regulationid'].length;
          i++) {
            // repository
            //   .getAllQuestionsCountFromHeading(bookingid,
            //       onValue['get_heading_from_regulationid'][i]['heading_id'])
            //   .then((val) {
            // onValue['get_heading_from_regulationid'][i]['remaining'] =
            //     val['not_answered'];
            // print(onValue);

            _con.headingslist.add(onOfflineValue['get_heading_from_regulationid'][i]);

            print("offlineheadinglistinfo" + _con.headingslist.toString());

            //  print("headingdescr="+headingslist[i]['heading_description'].toString());
            // });
          }
        });
      });

      _con.readQuestionCounter(widget.bookingid.toString()).then((onValue) {
        var onOfflineValue=json.decode(onValue.toString());
        _con.questionpendingcount = 0;
        _con.questionpending = false;
        _con.allquestionscount=0;
        _con.percent=0.0;
        setState(() {


          for (var i = 0; i < onOfflineValue['questions_from_headingId'].length; i++) {
            // questionsCount.add(onValue['questions_from_headingId'][i]);
            if (onOfflineValue['questions_from_headingId'][i]['ans'] == null) {
              _con.questionpending = true;
              _con.questionpendingcount++;
            }
           _con.allquestionscount++;
          }
          // print("${head.length} heading questions list ");


          _con.percent = ((_con.allquestionscount - _con.questionpendingcount) *
              100 /
              _con.allquestionscount)
              .roundToDouble();
          // print((allquestionscount - questionpendingcount) *
          //     100 /
          //     allquestionscount.round());

          // onValue();
        });
      });


    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _con.scaffoldKey,
      backgroundColor: config.Colors().scaffoldColor(1),
      appBar: AppBar(
        leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
              color: config.Colors().secondColor(1),
            ),
            onPressed: () => Navigator.pop(context)), //doubt here
        title:  Text(
          "Inspection: ${widget.predata['owner_land']}",
          style: TextStyle(fontFamily: "AVENIRLTSTD", fontWeight: FontWeight.bold),
        ),
        actions: <Widget>[
         isOnline?IconButton(
            icon: Icon(Icons.sync,color: syncdata?Colors.green:Colors.redAccent,),
            onPressed:()async {
            String onOfflineValue;
           await _con.readQuestionAnswerCounter().then((onValue) {
             {
                onOfflineValue= "{"+ '"answers"'+":"+"["+onValue.toString()+"]"+"}";
             }

                setState(() {
                  print("insideapi reading");
                  print("insideapiofflinevalue="+onOfflineValue.toString());


                });
              });
           await sendQuestionAnswerOfflineData(onOfflineValue);
             //sync data api will go here
            },
          ):Container(),
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed:()async { isOnline?refreshId:refreshOfflineId(); //working
          },
          )
          // IconButton(
          //     icon: Icon(Icons.menu),
          //       onPressed: () => _con.scaffoldKey.currentState.openDrawer()),
        ],
      ),

      // drawer: drawerData(context, userRepo.user.rolesManage),

      body:_con.headingslist.length == 0?Center(child: isOnline?CircularProgressIndicator():
      _con.headingslist.length == 0?CircularProgressIndicator(backgroundColor: Colors.redAccent,):RefreshIndicator(
        onRefresh: refreshOfflineId,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child:InpsectionHeadingColumnList(),
        ),
      ),)

          :
      RefreshIndicator(
        onRefresh: refreshId,
        child: Padding(
            padding: const EdgeInsets.all(8.0),
            child:InpsectionHeadingColumnList(),
        ),
      ),
    );
  }

  Widget InpsectionHeadingColumnList()
  {
    return Column(
      children: <Widget>[
        Container(

            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Card(
                  color: Colors.grey[300],
                  child: Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Container(
                      color: Colors.grey[300],
                      child: ListTile(
                        trailing: _con.percent == null
                            ? CircularProgressIndicator()
                            : Text("${_con.percent.round()}%",
                            style: TextStyle(
                                fontSize: 20,
                                fontFamily: "AVENIRLTSTD",
                                // fontWeight: FontWeight.bold,
                                color: Color(0xff222222))),
                        title: Text(
                          _con.headingslist[0]
                          ['regulation_name'],
                          style: TextStyle(
                              fontSize: 18,
                              fontFamily: "AVENIRLTSTD",
                              color: Color(0xff222222)),
                        ),
                        subtitle:  GestureDetector(
                            onTap: ()
                            {

                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  // return object of type Dialog
                                  return StatefulBuilder(
                                      builder: (context, setState) {
                                        return  SingleChildScrollView(
                                            child:AlertDialog(

                                              content: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: <Widget>[
                                                  Align(

                                                    child: GestureDetector(

                                                      onTap: ()
                                                      {
                                                        Navigator.of(context).pop();
                                                      },
                                                      child: Icon(Icons.clear,color: Colors.grey,),
                                                    ),
                                                    alignment: Alignment.topRight,
                                                  ),
                                                  SizedBox(height: 10,),
                                                  Flexible(child:
                                                  SingleChildScrollView(
                                                      child: Text(
                                                        _con.headingslist[0]
                                                        ['regulation_description'].toString(),
                                                        style: TextStyle(
                                                            fontFamily: "AVENIRLTSTD",
                                                            color: Colors.black,
                                                            fontSize: 18),


                                                      )
                                                  )
                                                  ),



                                                ],
                                              ),
                                            )
                                        );
                                      }
                                  );

                                },
                              );





                            },
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(0, 2, 0, 0),
                              child: Text(

                                "More Info.",

                                // demo,
                                textAlign: TextAlign.left,
                                style: TextStyle(

                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    // fontWeight: FontWeight.w500,
                                    fontFamily: "AVENIRLTSTD",
                                    color: Color(0xff0ba1d9)),

                              ),
                            )
                        ),

                      ),
                    ),
                  )),
            )),
        Expanded(flex: 12,
          //    height: MediaQuery.of(context).size.height * 0.8,
          child: ListView.builder(
              itemCount: _con.headingslist.length,
              itemBuilder: (context, i) {
                // setState(() {
                // headingcompleted++;
                // });

                return Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Card(
                    child: Padding(
                      padding: EdgeInsets.all(10.0),
                      child: Container(

                        child: ListTile(
                            trailing: _con.headingslist[i]
                            ['is_completed'] ==
                                0
                                ? Text("")
                                : Icon(
                              Icons.check,
                              color: Theme.of(context)
                                  .accentColor,
                            ),

                            title: Padding(
                              padding:
                              const EdgeInsets.only(top: 4.0),
                              child: Text(
                                _con.headingslist[i]
                                ['regulation_name'],
                                style: TextStyle(
                                    fontSize: 15,
                                    fontFamily: "AVENIRLTSTD",
                                    color: Color(0xffaeaeae)),
                              ),
                            ),
                            subtitle:  Padding(
                                padding:
                                const EdgeInsets.only(top: 8.0,bottom: 8.0),
                                child:Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(

                                      _con.headingslist[i]
                                      ['heading_name'],
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                          fontFamily: "AVENIRLTSTD",
                                          color: Color(0xff222222)),
                                    ),
                                    _con.headingslist[i]['heading_description']==""?Container():GestureDetector(
                                        onTap: ()
                                        {

                                          showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              // return object of type Dialog
                                              return StatefulBuilder(

                                                  builder: (context, setState) {
                                                    return  SingleChildScrollView(
                                                        child:AlertDialog(

                                                          content: Column(
                                                            mainAxisSize: MainAxisSize.min,
                                                            children: <Widget>[
                                                              Align(

                                                                child: GestureDetector(

                                                                  onTap: ()
                                                                  {
                                                                    Navigator.of(context).pop();
                                                                  },
                                                                  child: Icon(Icons.clear,color: Colors.grey,),
                                                                ),
                                                                alignment: Alignment.topRight,
                                                              ),
                                                              SizedBox(height: 10,),
                                                              SizedBox(height: 10,),
                                                              Flexible(child:
                                                              SingleChildScrollView(
                                                                  child: Text(
                                                                    _con.headingslist[i]
                                                                    ['heading_description'].toString(),
                                                                    style: TextStyle(
                                                                        fontFamily: "AVENIRLTSTD",
                                                                        color: Colors.black,
                                                                        fontSize: 18),


                                                                  )
                                                              )
                                                              ),



                                                            ],
                                                          ),
                                                        )
                                                    );
                                                  }
                                              );

                                            },
                                          );





                                        },
                                        child: Padding(
                                          padding: EdgeInsets.fromLTRB(0, 4, 0, 0),
                                          child: Text(

                                            "More Info.",

                                            // demo,
                                            textAlign: TextAlign.left,
                                            style: TextStyle(

                                                fontSize: 18,
                                                fontWeight: FontWeight.w700,
                                                // fontWeight: FontWeight.w500,
                                                fontFamily: "AVENIRLTSTD",
                                                color: Color(0xff0ba1d9)),

                                          ),
                                        )
                                    ),
                                  ],
                                )
                            ),


                            onTap: () async {
                              //print("checkingggg"+widget.predata['question_id'].toString());
                              bool abc = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          InspectionQuestionListWidget(
                                            _con.headingslist[i]
                                            ['heading_id'],
                                            widget.bookingid,
                                            widget.predata['id'],
                                          )));
                              if (abc) {
                               await CheckingInternet();
                              }

                            }

                          // print("${widget.bookingid}")
                        ),
                      ),
                    ),
                  ),
                );

              }),
        ),
//                         _con.questionpending
//                              ? Container()
//                                 :
//                              Flexible(
//                                flex: 2,
//                                  // color: Colors.blue,
//                                  child:Align(
//                                    alignment: Alignment.bottomCenter,
//                                    child:  ButtonBar(
//                                      alignment: MainAxisAlignment.center,
//                                      children: <Widget>[
//                                        SizedBox(
//                                          width: config.App(context).appWidth(45),
//
//                                          child: RaisedButton(
//                                            onPressed: () => _con.postMarkComplete(
//                                                widget.bookingid, 2, context),
//                                            child: Text(
//                                              "Non Compliant",
//                                              style: TextStyle(
//                                                  fontWeight: FontWeight.normal,
//                                                  fontSize: 18,
//                                                  fontFamily: "AVENIRLTSTD",
//                                                  color: Theme.of(context)
//                                                      .primaryColor),
//                                            ),
//                                            color: Theme.of(context).accentColor,
//                                          ),
//                                        ),
//                                        SizedBox(
//                                          width: config.App(context).appWidth(45),
//                                          child: RaisedButton(
//                                            onPressed: () => _con.postMarkComplete(
//                                                widget.bookingid, 3, context),
//                                            child: Text(
//                                              "Improvement Notice",
//                                              style: TextStyle(
//                                                  fontWeight: FontWeight.normal,
//                                                  fontSize: 17,
//                                                  fontFamily: "AVENIRLTSTD",
//                                                  color: Theme.of(context)
//                                                      .primaryColor),
//                                            ),
//                                            color: Theme.of(context).accentColor,
//                                          ),
//                                        ),
//                                      ],
//                                    ),
//                                  )
//                                  // height: MediaQuery.of(context).size.height * 0.1,
//                                  )
      ],
    );
  }

  CustomXRadioGroup buildCustomXRadioGroup(int i) {
    return CustomXRadioGroup(
      // name: que[i].qnumber,
      // label: que[i].qnumber,
      // header: "Barrier Fences, Walls, Gates & Windows",
      required: true,
      // selected: "male",
      options: [
        CustomOption(name: "Compliant", value: "compliant"),
        CustomOption(name: "Non Compliant", value: "noncompliant"),
        CustomOption(name: "Not Applicable", value: "notapplicable"),
      ],
    );
  }
  Future _submit(Map<String, dynamic> formData) async {
    List<Widget> children = [];
    formData.forEach((key, value) {
      children.add(Text("$key: ${value.toString()} ${value.runtimeType}"));
    });
    showDialog(
      context: _con.scaffoldKey.currentState.context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Form Data"),
          content: Column(
              crossAxisAlignment: CrossAxisAlignment.start, children: children),
          actions: <Widget>[
            FlatButton(
              child: Text("Close"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
