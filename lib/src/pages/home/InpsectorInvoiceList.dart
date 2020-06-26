import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:poolinspection/src/elements/drawer.dart';
import 'package:poolinspection/src/models/getinpsectorinovicelist.dart';
import 'package:poolinspection/src/models/getinvoicelistmodel.dart';
import 'package:poolinspection/src/models/selectCompliantOrNotice.dart';
import 'package:poolinspection/src/pages/home/MyWebView.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:image_picker/image_picker.dart';
import 'package:poolinspection/src/pages/home/MyWebView.dart';
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


class InspectorInvoiceListClass extends StatefulWidget {

  @override
  _InspectorInvoiceListClassState createState() => _InspectorInvoiceListClassState();

}
class _InspectorInvoiceListClassState extends State<InspectorInvoiceListClass> {

  List<GetInspectorInvoiceList> cleaner =new List<GetInspectorInvoiceList>();
  bool isLoading = false;

  List<ListElement> inovoice =new List<ListElement>();
  bool _firstSearch = true;
  String _query = "";
  String message="Send Email";
  int UserId;


  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();



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


  Future sentEmail(Id) async
  {
    ProgressDialog pr;
    pr = ProgressDialog(context,isDismissible: false);
    //final bytes = await .File(dataimage).readAsBytes();


    try {
      pr.show();
      print("inspectorid"+Id.toString());
      final response = await http.get("https://poolinspection.beedevstaging.com/api/send_inspector_invoice/$Id");
      print("responsee"+response.body.toString());

      SelectNonCompliantOrNotice selectNonCompliantOrNotice= selectNonCompliantOrNoticeFromJson(response.body);



      if(selectNonCompliantOrNotice.error==0) {
        await pr.hide();
        Fluttertoast.showToast(
            msg: selectNonCompliantOrNotice.messages.toString()+" Succesfully",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.blueAccent,
            textColor: Colors.white,
            fontSize: 16.0
        );
//        setState(() {
//          message=selectNonCompliantOrNotice.messages.toString();
//        });

      }
      else
        {
          await pr.hide();
        }

      //   await pr.hide();

    }catch(e)
    {
      pr.hide();
      // await pr.hide();
      print("errorfrombackend"+e.toString());
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
  }


  Future<GetInspectorInvoiceList> createInvoiceList() async {
    try {
      final response = await http.get(
        'https://poolinspection.beedevstaging.com/api/beedev/inspector_invoice/$UserId',

      );
      print("hellllo"+response.body.toString());
      GetInspectorInvoiceList getinvoicelist = getInspectorInvoiceListFromJson(response.body);

      if (getinvoicelist.status == "pass") {
        return getinvoicelist;
      }
      else {
        return null;
      }
    }catch(e)
    {

      print("Backend Error"+e.toString());
//      Fluttertoast.showToast(
//          msg: "Error From Backend"+e.toString(),
//          toastLength: Toast.LENGTH_SHORT,
//          gravity: ToastGravity.BOTTOM,
//          timeInSecForIosWeb: 1,
//          backgroundColor: Colors.red,
//          textColor: Colors.white,
//          fontSize: 16.0
//      );
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
            child:Text(" Inspector Invoices",
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
                icon: Icon(Icons.menu),
                onPressed: () => _scaffoldKey.currentState.openDrawer())
          ],
        ),

        body: new Center(
          child:Container(

            child: FutureBuilder<GetInspectorInvoiceList>(
              future: createInvoiceList(),
              builder: (context, snapshot) {

                if (snapshot.hasData) {
                  //     spacecrafts.add(snapshot.data.data.elementAt(0).categoryname);
                  if(!snapshot.data.list.isEmpty)
                  {
                    inovoice.clear();
                    for(var l=0;l<snapshot.data.list.length;l++) {
                      ListElement d = new ListElement();
                      d.id = snapshot.data.list
                          .elementAt(l)
                          .id;
                      d.ownerName = snapshot.data.list
                          .elementAt(l)
                          .ownerName;
                      d.ownerEmail = snapshot.data.list
                          .elementAt(l)
                          .ownerEmail;
                      d.bookingDate = snapshot.data.list
                          .elementAt(l)
                          .bookingDate;
                      d.bookingTime = snapshot.data.list
                          .elementAt(l)
                          .bookingTime;
                      d.invoiceName = snapshot.data.list
                          .elementAt(l)
                          .invoiceName;
                      d.invoicePath = snapshot.data.list
                          .elementAt(l)
                          .invoicePath;
                      d.inspectorId = snapshot.data.list
                          .elementAt(l)
                          .inspectorId;

                      inovoice.add(d);
                    }
                  }
                  else
                  {
                    return Text("No Inspector Invoices Found.",style: TextStyle(color: Colors.black,fontSize: 20),);
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
                  return Text("No Invoice List is present.",style: TextStyle(color: Colors.black,fontSize: 20),);
                }

                // By default, show a loading spinner.
                return new CircularProgressIndicator();
              },
            ),
          ),
        )
    );


  }

  Widget _getItemUI(BuildContext context, int index) {
    return new  Padding(
        padding: new EdgeInsets.fromLTRB(20, 20, 20,20),
        child:Card(
          child: Padding(
              padding: new EdgeInsets.fromLTRB(10, 10, 10,10),
              child:
              new Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: <Widget>[

                  new Text(inovoice[index].ownerName.toString().substring(0,1).toUpperCase()+inovoice[index].ownerName.toString().substring(1,inovoice[index].ownerName.length).toString(), style: TextStyle(
                      fontFamily: "AVENIRLTSTD",
                      fontSize: 21,
                      color: Color(0xff000000),
                      fontWeight: FontWeight.w900),),
                  SizedBox(height: 8,),
                  Padding(
                    padding: EdgeInsets.fromLTRB(0, 0, 5, 5),
                    child: Text(
                      inovoice[index].ownerEmail.toString(),textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 18,
                          color: Color(0xff999999), fontFamily: "AVENIRLTSTD",fontWeight: FontWeight.normal),
                    ),
                  ),

                  new Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,

                      children: <Widget>[
                        new Text("Dated:"+" "+DateFormat("dd-MM-yyyy").format(DateTime.parse(inovoice[index].bookingDate.toString().substring(0,10))).toString(), style: TextStyle(
                            fontFamily: "AVENIRLTSTD",
                            fontSize: 16,
                            color: Color(0xff999999),
                            fontWeight: FontWeight.normal),),



                      ]
                  ),



                  Padding(
                    padding: new EdgeInsets.fromLTRB(0,6, 0,0), child:new RaisedButton(
                      onPressed:() {
                        print("gokuxx"+inovoice[index].id.toString());
                        sentEmail(inovoice[index].id.toString());
                      },
                      color: Colors.blue,
                      shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(5.0)),
                      child:GestureDetector(child:Text(
                        message,
                        style: TextStyle(
                            fontSize: 16,
                            color: Colors.white, fontFamily: "AVENIRLTSTD",fontWeight: FontWeight.normal),
                      ),
                        onTap: ()
                        {
                          print("gokuxx"+inovoice[index].id.toString());
                          sentEmail(inovoice[index].id.toString());


//                          Navigator.of(context).push(MaterialPageRoute(
//                              builder: (BuildContext context) => MyWebView(
//                                title:inovoice[index].invoiceName ,
//                                selectedUrl:"https://poolinspection.beedevstaging.com/api/beedev/view_invoice/"+inovoice[index].invoicePath,
//                              )));

                        }
                        ,
                      )


                  ),
                  ),


                ],
              )
          ),
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