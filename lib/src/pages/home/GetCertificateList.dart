import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_signature_pad/flutter_signature_pad.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:poolinspection/src/elements/drawer.dart';
import 'package:poolinspection/src/models/getcertificatemodel.dart';
import 'package:poolinspection/src/pages/home/PermissionHandler.dart';
import 'package:poolinspection/src/pages/utils/signaturepad.dart';
import 'package:poolinspection/src/helpers/sharedpreferences/userpreferences.dart';
import 'package:poolinspection/config/app_config.dart' as config;
import 'package:poolinspection/src/models/route_argument.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:poolinspection/src/repository/user_repository.dart' as userRepo;
import 'package:share_extend/share_extend.dart';



class CertificateListClass extends StatefulWidget {
  RouteArgumentCertificate routeArgument;

  CertificateListClass({Key key, this.routeArgument}) : super(key: key);

  @override
  _CertificateListClassState createState() => _CertificateListClassState();

}
class _CertificateListClassState extends State<CertificateListClass> {


  List<GetCertificateModel> cleaner =new List<GetCertificateModel>();
  bool isLoading = false;



  bool _progressDone = false;
  double _percentage = 0.0;

  bool progressCircular = false;
  List<ListElement> certificate =new List<ListElement>();

  bool _firstSearch = true;
  String _query = "";
 int UserId;
  String categor;

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  Future refreshId() async {
    setState(() {




    });
  }


  @mustCallSuper
  @override
  void initState() {


    UserSharedPreferencesHelper.getUserDetails().then((user) {
      setState(() {
        // print("${user.userdata.inspector.firstName } controller user id");
        UserId=user.id;


      });
    });
  }


  Future downloadpdf(idofcertificate) async
  {
 ProgressDialog pr;
    pr = ProgressDialog(context,isDismissible: false);
    //final bytes = await .File(dataimage).readAsBytes();

    String _openResult = 'Unknown';

    final Directory directory = await getApplicationSupportDirectory();
    final String path = await directory.path;
    final File file = File('$path/certificate$idofcertificate.pdf');
    try {
      pr.show();
      print("directory"+directory.toString());
      print("file"+file.toString());
//      Fluttertoast.showToast(
//          msg: "Opening Certificate, Please Wait..",
//          toastLength: Toast.LENGTH_LONG,
//          gravity: ToastGravity.BOTTOM,
//          timeInSecForIosWeb: 1,
//          backgroundColor: Colors.blue,
//          textColor: Colors.white,
//          fontSize: 16.0
//      );
      final response = await http.get("https://poolinspection.beedevstaging.com/api/beedev/generate_certificate/$idofcertificate");
      await file.writeAsBytes(response.bodyBytes);

     pr.hide();
      print("certificateresponse"+file.path.toString());
   //   await pr.hide();

    }catch(e)
    {
      pr.hide();
     // await pr.hide();
      print("errorincertificatebackend"+e.toString());
      Fluttertoast.showToast(
          msg: "Error from backend"+e.toString(),
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0
      );
    }

try{

  final result = await OpenFile.open(file.path.toString());


  if(!mounted)  return;
  setState(() {
    _openResult = "type=${result.type}  message=${result.message}";
  });
}
catch(e)
    {

    }
  }


  Future<GetCertificateModel> createCertificateList() async{
   print("qqqwer"+UserId.toString());
    widget.routeArgument.heroTag.toString()=="Compliant"?categor="compliant":widget.routeArgument.heroTag.toString()=="Non Compliant"?categor="non-compliant":categor="notice";
     final response = await http.get('https://poolinspection.beedevstaging.com/api/beedev/$categor/$UserId',

    );

    GetCertificateModel getcertifcatelist= getCertificateModelFromJson(response.body);


    if(getcertifcatelist.status=="pass")
      {

        return getcertifcatelist;
      }
    else
      {

        return null;
      }
  }

  @override
  Widget build(BuildContext context) {

    // TODO: implement build
    return Scaffold(
        key: _scaffoldKey,
        //  drawer: DrawerOnly(),
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
            child:Text("Certificate",
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontFamily: "AVENIRLTSTD",
                fontSize: 20,
                color: Color(0xff222222),
              ),
            ),

          ),
          actions: <Widget>[

              IconButton(
                icon: Icon(Icons.refresh),
                onPressed: refreshId,
              ),
              //   IconButton(
              //       icon: Icon(Icons.menu),
              //         onPressed: () => _con.scaffoldKey.currentState.openDrawer()),

            IconButton(
                icon: Icon(Icons.menu),
                onPressed: () => _scaffoldKey.currentState.openDrawer())
          ],
        ),

        body:RefreshIndicator(
          onRefresh: refreshId,
          child: new Center(
          child:Container(

            child: FutureBuilder<GetCertificateModel>(
              future: createCertificateList(),
              builder: (context, snapshot) {

                if (snapshot.hasData) {
                  //     spacecrafts.add(snapshot.data.data.elementAt(0).categoryname);
                  if(!snapshot.data.list.isEmpty)
                    {
                certificate.clear();
                for(var l=0;l<snapshot.data.list.length;l++) {
                  ListElement c = new ListElement();
                  c.id = snapshot.data.list
                      .elementAt(l)
                      .id;
                  c.ownerLand = snapshot.data.list
                      .elementAt(l)
                      .ownerLand;
                  c.ownerLand = snapshot.data.list
                      .elementAt(l)
                      .ownerLand;
                  c.postcode = snapshot.data.list
                      .elementAt(l)
                      .postcode;
                  c.bookingTime=snapshot.data.list
                      .elementAt(l).
                       bookingTime;
                  c.bookingDateTime = snapshot.data.list
                      .elementAt(l)
                      .bookingDateTime;

                  c.status= snapshot.data.list
                      .elementAt(l)
                      .status;

                  c.isCertificateGenerated = snapshot.data.list  //1 for generated
                      .elementAt(l)
                      .isCertificateGenerated;
                  certificate.add(c);
                }
                }
                  else
                    {
                      return Text("No Certificates Found.",style: TextStyle(color: Colors.black,fontSize: 20),);
                    }


                  return  Column(
                      children: <Widget>[
                        // _createSearchView(),
                        Expanded(
                            child:ListView.builder(
                              itemCount: snapshot.data.list.length,
                              itemBuilder: _getItemUI,//one important thing to note here is parameter of itembuilder is context,index but if
                              //  itemExtent: 100.0,  //but if you giving method then they both will be treated as parameter of that method.
                              padding: EdgeInsets.all(0.0),
                            )),
                      ]);
                } else if (snapshot.hasError) {


                  return Text("No Certificates Found.",style: TextStyle(color: Colors.black,fontSize: 20),);
                }

                // By default, show a loading spinner.
                return new CircularProgressIndicator();
              },
            ),
          ),
        ),
    )
    );


  }

  Widget _getItemUI(BuildContext context, int index) {
    return new  Padding(
        padding: new EdgeInsets.fromLTRB(20, 20, 20,20),
        child:Card(
            child:Center(
              child:  Padding(
                  padding: new EdgeInsets.fromLTRB(20, 20, 20,20),
                  child:
                      new Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.max,
                        children: <Widget>[

                          new Text((index+1).toString()+". " +certificate[index].ownerLand, style: TextStyle(
                              fontFamily: "AVENIRLTSTD",
                              fontSize: 21,
                              color: Color(0xff000000),
                              fontWeight: FontWeight.w900),),
                          SizedBox(height: 8,),

                          new Text("Dated:"+" "+DateFormat("dd-MM-yyyy").format(DateTime.parse(certificate[index].bookingDateTime.toString().substring(0,10))).toString(), style: TextStyle(
                              fontFamily: "AVENIRLTSTD",
                              fontSize: 15,
                              color: Color(0xff999999),
                              fontWeight: FontWeight.normal),),


                      Padding(
                        padding: new EdgeInsets.fromLTRB(0, 20, 0,0),
                        child:   Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              new Text("Post Code", style: TextStyle(
                                  fontFamily: "AVENIRLTSTD",
                                  fontSize: 20,
                                  color: Color(0xff222222),
                                  fontWeight: FontWeight.normal),),

                              new Text(certificate[index].postcode, style: TextStyle(
                                  fontFamily: "AVENIRLTSTD",
                                  fontSize: 20,
                                  color: Color(0xff999999),
                                  fontWeight: FontWeight.w900),),
                            ]
                        ),
                      ),

                          Padding(
                            padding: new EdgeInsets.fromLTRB(0, 0, 0,0),
                            child:   Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                              new Text("Status", style: TextStyle(
                                  fontFamily: "AVENIRLTSTD",
                                  fontSize: 20,
                                  color: Color(0xff222222),
                                  fontWeight: FontWeight.normal),),

                                  ButtonTheme(
                                    minWidth: 22.0,
                                    height: 25.0,
                                    child:RaisedButton(
                                      onPressed:(){

                                      },
                                      color: Colors.green,
                                      shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(5.0)),
                                      child:Text(
                                        categor=="notice"?"Notice of Improvement":categor,textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.white, fontFamily: "AVENIRLTSTD",fontWeight: FontWeight.normal),
                                      ),


                                    ),
                                  ),

                                ]
                            ),
                          ),

                          Padding(
                            padding: new EdgeInsets.fromLTRB(0,10, 0,0), child:new RaisedButton(
                            onPressed:() {
                              certificate[index].isCertificateGenerated==1?  Permission.values
                                  .where((Permission permission) {
                                if (Platform.isIOS) {
                                  return permission != Permission.storage ;


                                } else {
                                  return permission != Permission.storage;
                                }
                              })
                                  .map((permission) => PermissionWidget(permission))
                                  .toList():null;
                                print("certificate generated?"+certificate[index].isCertificateGenerated.toString());
                                certificate[index].isCertificateGenerated==1?downloadpdf(certificate[index].id.toString()): Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => MyHomePage1(certificate[index].id.toString(),categor,certificate[index].bookingDateTime.toString(),certificate[index].bookingTime.toString())),
                                );


                            },
                            color: Colors.blue,
                            shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(5.0)),
                            child:GestureDetector(child:Text(
                              certificate[index].isCertificateGenerated==1?"Open":"View",
                              style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white, fontFamily: "AVENIRLTSTD",fontWeight: FontWeight.normal),
                            ),
                              onTap: ()
                              {
                                certificate[index].isCertificateGenerated==1?  Permission.values
                                    .where((Permission permission) {
                                  if (Platform.isIOS) {
                                    return permission != Permission.storage ;


                                  } else {
                                    return permission != Permission.storage;
                                  }
                                })
                                    .map((permission) => PermissionWidget(permission))
                                    .toList():null;


                                certificate[index].isCertificateGenerated==1? downloadpdf(certificate[index].id.toString()): Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => MyHomePage1(certificate[index].id.toString(),categor,certificate[index].bookingDateTime.toString(),certificate[index].bookingTime.toString())),
                                ).then((value) =>    setState(() {
                                  refreshId();
                                })
                                );


                             refreshId();

                              }
                              ,
                            )


                          ),
                          ),
                        ],
                      ),



              ),
            )
        )
    );
  }


//Create the Filtered ListView


}
//Widget _createSearchView() {
//
//  return new Container(
//      color: Theme.of(context).primaryColor,
//      child: new Padding(
//        padding: const EdgeInsets.all(8.0),
//        child: new Card(
//          child: new ListTile(
//            leading: new Icon(Icons.search),
//            title: new TextField(
//              controller: _searchview,
//              decoration: new InputDecoration(
//                  hintText: 'Searh', border: InputBorder.none),
//            ),
//            trailing: new IconButton(icon: new Icon(Icons.cancel), onPressed: () {
//              _searchview.clear();
//            },),
//          ),
//        ),
//      ));
//}