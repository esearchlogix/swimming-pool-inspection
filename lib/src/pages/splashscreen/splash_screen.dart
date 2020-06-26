import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:poolinspection/res/string.dart';
import 'package:poolinspection/src/controllers/controller.dart';
import 'package:poolinspection/src/helpers/connectivity.dart';
import 'package:poolinspection/src/repository/user_repository.dart' as userRepo;
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class SplashScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return SplashScreenState();
  }
}

class SplashScreenState extends StateMVC<SplashScreen> {
  StreamSubscription _connectionChangeStream;
  bool isOffline = false;

  Controller _con;

  SplashScreenState() : super(Controller()) {
    _con = controller;
  }
  ConnectionStatusSingleton connectionStatus;
  @override
  void initState() {
    super.initState();
    // print(currentUser.email);
//    connectionStatus = ConnectionStatusSingleton.getInstance();
//    _connectionChangeStream =
//        connectionStatus.connectionChange.listen(connectionChanged);
//    connectionStatus.checkConnection().then((val) {
//      val ? loadData() : print("not connected");
//      isOffline = val;
//    });
    isOffline=true;  // is offline means checking whether offline or not in methods , it is not means app is offline, it  is checking
    loadData();
    // loadData();
  }

//  void connectionChanged(dynamic hasConnection) {
//    setState(() {
//      connectionStatus.checkConnection().then((val) {
//        val ? loadData() : print("not connected");
//        isOffline = val;
//      });
//      // isOffline = !hasConnection;
//    });
//  }

  Future<Timer> loadData() async {
    return new Timer(Duration(seconds: 5), onDoneLoading);
  }

  onDoneLoading() async {
    // print(currentUser.token2fa);
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (userRepo.token!= null) {
        Navigator.of(context).pushReplacementNamed('/Home');
      } else {
        Navigator.of(context).pushReplacementNamed('/Login');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _con.scaffoldKey,
      body: Container(
//        decoration: BoxDecoration(
//          color: Theme.of(context).hintColor,
//        ),
        decoration: new BoxDecoration(

          image: new DecorationImage(
            image: new AssetImage("assets/img/poolsplashimage.png"),
            fit: BoxFit.fill,

          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                Icons.pool,
                size: 90,
                color: Theme.of(context).scaffoldBackgroundColor,
              ),
              Text(
                "Pool Inspection",
                style: Theme.of(context).textTheme.display1.merge(TextStyle(
                    color: Theme.of(context).scaffoldBackgroundColor)),
              ),
              SizedBox(height: 50),
             // isOffline
              true
                  ? CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).scaffoldBackgroundColor),
                    )
                  : SizedBox(
                      width: MediaQuery.of(context).size.width * 2 / 3,
                      child: RaisedButton(
                          shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(10.0)),
                         color: Colors.redAccent,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Icon(Icons.refresh,color: Colors.white,),
                              Text(" No Internet", style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: "AVENIRLTSTD",fontSize: 20
                              ),)
                            ],
                          ),
//                          onPressed: () async => connectionChanged(
//                                  await connectionStatus
//                                      .checkConnection()
//                                      .then((val) {
//                                val ? loadData() : print("not connected");
//                                isOffline = val;
//                              }))
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
