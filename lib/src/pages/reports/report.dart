import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:poolinspection/src/controllers/report_controller.dart';
import 'package:poolinspection/src/elements/textlabel.dart';
import 'package:poolinspection/src/models/reportmodel.dart';
import 'package:poolinspection/src/models/route_argument.dart';
import 'package:poolinspection/src/repository/user_repository.dart';
import 'package:poolinspection/config/app_config.dart' as config;

import 'reportdetail.dart';

class NoticeReportWidget extends StatefulWidget {
  RouteArgumentReport routeArgument;
  NoticeReportWidget({Key key, this.routeArgument}) : super(key: key);

  @override
  _NoticeReportWidgetState createState() => _NoticeReportWidgetState();
}

class _NoticeReportWidgetState extends StateMVC<NoticeReportWidget> {
  ReportController _con;
  ReportModel model = new ReportModel();
  _NoticeReportWidgetState() : super(ReportController()) {
    _con = controller;
  }
  @override
  void initState() {
    print("qwer=${widget.routeArgument.id}     -----------------------------------");
    _con.choice = widget.routeArgument.id;

    _con.reportsList(user.id, widget.routeArgument.id-4).then((onValue) {
      setState(() {
        _con.noticeofcompliant = onValue;
        print(onValue);
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      backgroundColor: config.Colors().scaffoldColor(1),
      appBar: AppBar(
        leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
              color: config.Colors().secondColor(1),
            ),
            onPressed: () => Navigator.pop(context)),
        title: Text(
          widget.routeArgument.heroTag,
          style: TextStyle(
            fontFamily: "AVENIRLTSTD",
          ),
        ),
        // actions: <Widget>[
        //   IconButton(icon: Icon(Icons.dns), onPressed: () => print(''))
        // ],
      ),
      body: RefreshIndicator(
        onRefresh: _con.onRefresh,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: _con.noticeofcompliant == null
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : _con.noticeofcompliant['compliant_report_list'].length == 0
                  ? Center(child: Text("No Records Found.",style: TextStyle(color: Colors.black,fontSize: 20),))
                  : ListView.builder(
                      itemCount: _con
                          .noticeofcompliant['compliant_report_list'].length,
                      itemBuilder: (context, i) => Card(
                            child: Container(
                              child: ListTile(
                                // leading: CircleAvatar(
                                //     child: Text(
                                //         "${model.compliantReportList[i].id}")),
                                onTap: () {
//                                  ReportModel model = ReportModel.fromJson(
//                                      _con.noticeofcompliant);
//                                  Navigator.push(
//                                    context,
//                                    MaterialPageRoute(
//                                        builder: (context) =>
//                                            ReportDetailWidget(
//                                              routeArgument:
//                                                  model.compliantReportList[i],
//                                            )),
//
//                                    // );
//                                  );
                                },
                                trailing: MaterialButton(
                                  shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(5.0)),
                                    onPressed: ()
                                  {

                                  },
                                  color: Colors.blueAccent,
                                  child: Padding(
                                    padding: const EdgeInsets.all(5.0),
                                    child: Text(
                                        "${DateFormat("yMMMMd").format(DateTime.parse(_con.noticeofcompliant['compliant_report_list'][i]['booking_date_time']))}",
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontFamily: "AVENIRLTSTD",
                                            // fontWeight: FontWeight.bold,
                                            color: Colors.white)),
                                  ),
                                ),
                                title:Padding(
                                  padding: const EdgeInsets.all(5.0),
                                  child:  Text(
                                    "${_con.noticeofcompliant['compliant_report_list'][i]['owner_land'].toString().substring(0,1).toUpperCase()+_con.noticeofcompliant['compliant_report_list'][i]['owner_land'].toString().substring(1,_con.noticeofcompliant['compliant_report_list'][i]['owner_land'].toString().length).toLowerCase()}",
                                    style: TextStyle(
                                        fontSize: 20,
                                        color: Color(0xff222222),
                                        fontFamily: "AVENIRLTSTD",
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                subtitle: Padding(
                                  padding: const EdgeInsets.fromLTRB(5, 5, 0, 5),
                                  child: Text(
                                    "${_con.noticeofcompliant['compliant_report_list'][i]['email_owner']}",
                                    style: TextStyle(
                                        fontSize: 18,
                                        color: Color(0xff222222),
                                        fontFamily: "AVENIRLTSTD",
                                        fontWeight: FontWeight.w400),
                                  ),
                                ),
                              ),
                            ),
                          )),
        ),
      ),
    );
  }

  // Widget buildFutureBuilder() {
  //   return FutureBuilder(
  //     builder: (context, projectSnap) {
  //       // if (projectSnap.connectionState == ConnectionState.none &&
  //       //     projectSnap.hasData == null) {
  //       //   print('project snapshot data is: ${projectSnap.data}');
  //       //   return Container();
  //       // }
  //       projectSnap.connectionState == ConnectionState.none &&
  //               projectSnap.hasData == null
  //           ? Container()
  //           :
  //           // else if (projectSnap.hasData) {
  //           model = ReportModel.fromJson(projectSnap.data);
  //       return ListView.builder(
  //           itemCount: model.compliantReportList.length,
  //           itemBuilder: (context, i) => ListTile(
  //               leading: CircleAvatar(
  //                   child: Text("${model.compliantReportList[i].id}")),
  //               title: Text("${model.compliantReportList[i].ownerLand}"),
  //               subtitle: Text("${model.compliantReportList[i].address}"),
  //               onTap: () => Navigator.push(
  //                     context,
  //                     MaterialPageRoute(
  //                         builder: (context) => ReportDetailWidget(
  //                               routeArgument: model.compliantReportList[i],
  //                             )),

  //                     // );
  //                   )));
  //     },
  //     future: reportsList(),
  //   );
  // }
}
