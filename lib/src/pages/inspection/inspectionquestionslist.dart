import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:poolinspection/config/app_config.dart' as config;
import 'package:poolinspection/src/controllers/inspection_controller.dart';
import 'package:poolinspection/src/helpers/connectivity.dart';
import 'package:poolinspection/src/models/questionmodel.dart';

import 'inspectionquestion.dart';

class InspectionQuestionListWidget extends StatefulWidget {
  int headingid;
  int bookingid;
  var bookingStringid;
  InspectionQuestionListWidget(
      this.headingid, this.bookingid, this.bookingStringid);
  @override
  _InspectionQuestionListWidgetState createState() =>
      _InspectionQuestionListWidgetState();
}

class _InspectionQuestionListWidgetState
    extends StateMVC<InspectionQuestionListWidget> {
  InspectionController _con;
  bool filter = false;
  bool isOnline=false;
  StreamSubscription _connectionChangeStream;
  ConnectionStatusSingleton connectionStatus;
  _InspectionQuestionListWidgetState() : super(InspectionController()) {
    _con = controller;
  }
  Future CheckingInternet() async
  {

      _connectionChangeStream = await connectionStatus.connectionChange.listen(connectionChanged);
    await connectionStatus.checkConnection().then((val) {
      val ? loadData() :refreshOfflineId();
      isOnline = val;
    });


  }
  Future refreshOfflineId() async {
    _con.questionslist=[];
    setState(() {

      _con.readQuestionListCounter(widget.headingid.toString(),widget.bookingid.toString()).then((onValue) {

        var onOfflineValue=json.decode(onValue.toString());
        setState(() {
          for (var i = 0; i < onOfflineValue['questions_from_headingId'].length; i++) {
            _con.questionslist.add(onOfflineValue['questions_from_headingId'][i]);
          }

        });
      });




    });
  }
  QuestionModel model;
  @override
  void initState() {
    // TODO: implement initState
    connectionStatus = ConnectionStatusSingleton.getInstance();
    CheckingInternet();

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
//    print("${widget.headingid}, ${widget.bookingid} ${widget.bookingStringid}");
//    _con.getquestions(widget.headingid, widget.bookingid);
    refreshId(); //dont know about it

  }

  Future refreshId() async {
    _con.questionslist = [];
          setState(() {

            _con.getquestions(widget.headingid, widget.bookingid);
          });
  }

  @override
  Widget build(BuildContext context) {
    print(_con.questionslist.length);
    return Scaffold(
      key: _con.scaffoldKey,
      backgroundColor: config.Colors().scaffoldColor(1),
      appBar: AppBar(
        leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
              color: config.Colors().secondColor(1),
            ),
            onPressed: () => Navigator.pop(context, true)),
        title: Text(
          'Select Questions',
          style: TextStyle( fontFamily: "AVENIRLTSTD", fontWeight: FontWeight.bold),
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.refresh),
        onPressed:()async {
          isOnline ? refreshId : refreshOfflineId(); //working
        })
          //   IconButton(
          //       icon: Icon(Icons.menu),
          //         onPressed: () => _con.scaffoldKey.currentState.openDrawer()),
        ],
      ),

      // drawer: drawerData(context, userRepo.user.rolesManage),

      body: _con.questionslist.length == 0?Center(child: isOnline?CircularProgressIndicator():
      _con.questionslist.length == 0?CircularProgressIndicator(backgroundColor: Colors.redAccent,):RefreshIndicator(
        onRefresh: refreshOfflineId,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child:InpsectionQuestionList(),
        ),
      ),)

          :
      RefreshIndicator(
        onRefresh: refreshId,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child:InpsectionQuestionList(),
        ),
      ),
    );
  }

  Widget InpsectionQuestionList()
  {
    return ListView.builder(
        itemCount: _con.questionslist.length,
        itemBuilder: (context, i) {
          return GestureDetector(
              child:Padding(
                padding: EdgeInsets.all(8.0),
                child: Card(
                  elevation: 1.0,
                  child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        children: <Widget>[

                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              _con.questionslist[i]['question'],
                              style: TextStyle(
                                  fontFamily: "AVENIRLTSTD", color: Color(0xff222222),fontSize: 18),
                            ),
                          ),

                          SizedBox(height: 10,),
                          Align(
                              alignment:Alignment.centerRight,
                              child:

                              _con.questionslist[i]['ans'] == null ||
                                  _con.questionslist[i]['ans'] == "0"
                                  ? Padding(
                                  padding: EdgeInsets.all(6.0),
                                  child:new RaisedButton(
                                      disabledElevation:0.0,

                                      onPressed:() async{
                                        var abc;
                                        print("4321"+_con.questionslist[i].toString());
                                        abc = await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) => QuestionsList(
                                                    _con.questionslist[i], i)));
                                        if (abc==true) {
                                          refreshId();
                                        }
                                        else
                                          {
                                            refreshOfflineId();

                                          }
                                      },
                                      color:Colors.redAccent,
                                      shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(5.0)),
                                      child:Text("Not Answered", style: TextStyle(
                                          color: Colors.white,
                                          fontFamily: "AVENIRLTSTD", fontSize: 15),)
                                  )
                              ) : Padding(
                                  padding: EdgeInsets.all(6.0),
                                  child:new RaisedButton(
                                      disabledElevation:0.0,
                                      onPressed:() async{
                                        var abc;
                                        print("4321"+_con.questionslist[i].toString());
                                        abc = await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) => QuestionsList(
                                                    _con.questionslist[i], i)));
                                        if (abc==true) {   //lead to bug
                                          refreshId();
                                        }
                                        else
                                          {
                                            refreshOfflineId();

                                          }
                                      },
                                      color:Color(0xff20c67e),
                                      shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(5.0)),
                                      child:Text("Answered", style: TextStyle(
                                          color: Colors.white,
                                          fontFamily: "AVENIRLTSTD", fontSize: 15),)
                                  )
                              )
                          ),
                        ],
                      )
                  ),
                ),
              ),
              onTap: () async {
                var abc;
                print("4321"+_con.questionslist[i].toString());
                abc = await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => QuestionsList(
                            _con.questionslist[i], i)));
                if (abc==true) { //lead to bug
                  //refreshId();
                  CheckingInternet();
                }
                else
                  {
                    refreshOfflineId();
                  //  StoreQuestionListInLocal(json.encode(onValue).toString(),headingId.toString(),booking.toString())
                  }
              }
          );
        });
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



