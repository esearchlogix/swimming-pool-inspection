import 'dart:async';

import 'dart:io';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:poolinspection/src/controllers/inspection_controller.dart';
import 'package:poolinspection/src/pages/home/PermissionHandler.dart';


class MyDialogMobile extends StatefulWidget {
  final InspectionController _con;
  var question;
  int i;
  final int indexofrectiornoncomp;
  MyDialogMobile(this.i,this._con,this.indexofrectiornoncomp,this.question);
  @override
  _MyDialogMobileState createState() => new _MyDialogMobileState(i,_con,indexofrectiornoncomp,question);
}

class _MyDialogMobileState extends State<MyDialogMobile> {
  Color _c = Colors.redAccent;
  InspectionController _con;
  var question;
  bool photoselected=false;
  int indexofrectiornoncomp;
  int counter=0;
  int i;
  final GlobalKey<FormState> _formKey =  GlobalKey<FormState>();

  _MyDialogMobileState(i,_con,indexofrectiornoncomp,question)
  {
    this.i=i;
    this._con=_con;
    this.indexofrectiornoncomp=indexofrectiornoncomp;
    this.question=question;
  }

  void _onImageButtonPressed() async {

    if (_con.pickingType != FileType.custom || _con.hasValidMime) {


      setState(() => _con.loadingPath = true);
      try {
        // _con.paths = null;
        final File image=  await ImagePicker.pickImage(
          source: ImageSource.camera,
          maxWidth: 150,
          maxHeight: 150,
        );
        if (image == null) return;
        // getting a directory path for saving
        // Step 3: Get directory where we can duplicate selected file.
        final Directory directory = await getExternalStorageDirectory();
        final String path = await directory.path;
        // using your method of getting an image
        final File newImage = await image.copy(path+"/image${++counter}.png");
        setState(() {

          _con.loadingPath = false;

          // print("addedimagepath"+_con.path.toString());
          //_con.path.add("hello");
          _con.path.add(newImage.path.toString().substring(0,newImage.path.length));

          _con.fileName.add("image${counter}.png");


          //   print("goku is godimagepathinques"+newImage.toString());
          print("newaddpath"+_con.path.toString());
          print("newaddimages"+_con.fileName.toString());

        });


      } on PlatformException catch (e) {
        print("Unsupported operation" + e.toString());
      }
      if (!mounted) return;

    }

    Flushbar(
      title: "Image selected",
      message: "Please Submit Answer",
      duration: Duration(seconds: 3),
    )..show(context);



  }

  @override
  Widget build(BuildContext context1) {
    return AlertDialog(

      contentPadding: EdgeInsets.all(2.0),
      backgroundColor:Color(0xffd3d3d3),
      content:StatefulBuilder(  // You need this, notice the parameters below:
        builder: (BuildContext context, StateSetter setState) {

          return Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height/1.8,
            color: Color(0xffffffff),
            child:  Stack(

              children: <Widget>[


                SingleChildScrollView(
                  child: Container(
                    alignment: Alignment.topLeft,
                    child: Padding(
                        padding:EdgeInsets.fromLTRB(20, 20, 10, 0),
                        child:Form(
                          key: _formKey,
                          child: TextFormField(
                            style: TextStyle(color:Color(0xff000000),fontSize: 20,

                              fontFamily: "AVENIRLTSTD",),
                            initialValue: widget.question['comment'],
                            textInputAction: TextInputAction.done,
                            validator: (text) {
                              if (text == null || text.isEmpty ||text.trim().isEmpty) {
                                return 'Text is empty';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              enabledBorder: new UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color: Color(0xfffffff)
                                ),
                              ),
// and:

                              hintText: "Enter Comments",
                              hintStyle: TextStyle(
                                fontSize: 20,
                                color: Color(0xff999999),
                                fontFamily: "AVENIRLTSTD",
                              ),
// labelText: 'Enter the Value',
                              errorText: _con.validate
                                  ? 'Value Can\'t Be Empty'
                                  : null,
                            ),
                            onChanged: (abc) => _con.data.comment = abc,
                            onFieldSubmitted: (abc) => _con.data.comment = abc,
// onEditingComplete: ()=>print(abc),

                            maxLines: 5,
                          ),
                        )
                    ),),
                ),
                Align(

                  child: GestureDetector(

                    onTap: ()
                    {
                      print("helllo");
                      Navigator.pop(context1);
                    },
                    child: Icon(Icons.clear,color: Colors.grey,size: 30,),
                  ),
                  alignment: Alignment.topRight,
                ),
                Padding(
                  padding: EdgeInsets.all(10.0),
                  child:    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        Expanded(child:Align(

                          alignment: Alignment.bottomLeft,
                          child:  RaisedButton(
                            onPressed:(){
                              if(_formKey.currentState.validate())
                              {
                                _con.getPostQuestions(widget.i,indexofrectiornoncomp, context);


                              }
                            },
                            color:Theme.of(context).accentColor,
                            shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(5.0)),
                            child:Text(
                              "Submit",
                              style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white, fontFamily: "AVENIRLTSTD",fontWeight: FontWeight.normal),
                            ),


                          ),
                        ),),
                        Expanded(child:Align(

                            alignment: Alignment.bottomRight,
                            child:Padding(
                                padding: EdgeInsets.fromLTRB(2, 0, 0, 8),
                                child: Row(

                                  children: <Widget>[
                                    GestureDetector(
                                      onTap: () async
                                      {
                                        Permission.values
                                            .where((Permission permission) {
                                          if (Platform.isIOS) {
                                            return permission != Permission.storage &&
                                                permission != Permission.camera ;


                                          } else {
                                            return permission != Permission.storage &&
                                                permission != Permission.camera;
                                          }
                                        })
                                            .map((permission) => PermissionWidget(permission))
                                            .toList();

                                        if(counter.toString()=="5")
                                          {
                                                  Fluttertoast.showToast(
          msg: "5 Photos Selected",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.blue,
          textColor: Colors.white,
          fontSize: 16.0
      );
                                          }
                                        else
                                        await _onImageButtonPressed();


                                        setState(() {
                                          photoselected=true;
                                        });


                                      },
                                      child: Padding(

                                        padding: EdgeInsets.fromLTRB(0, 3, 0, 1),
                                        child: Text(
                                          photoselected==false?"Take Photo":"Selected "+counter.toString()+"/5",
// demo,

                                          style: TextStyle(


                                              fontSize: 18,
                                              fontWeight: FontWeight.w700,
// fontWeight: FontWeight.w500,
                                              fontFamily: "AVENIRLTSTD",
                                              color: Colors.blue),

                                        ),
                                      ),
                                    ) ,
//      widget.question['images']==null?
                                    photoselected==false?Padding(
                                      padding: EdgeInsets.fromLTRB(3, 0, 0, 2),
                                      child:  Icon(Icons.camera,color: Colors.grey,size: 25,),
                                    ):Padding(
                                      padding: EdgeInsets.fromLTRB(3, 0, 0, 2),
                                      child:  Icon(Icons.photo,color: Colors.grey,size: 25,),
                                    )

                                  ],
                                )

                            )
                        ),),

                      ],

                    ),
                  ),



                Padding(
                  padding: EdgeInsets.fromLTRB(10, 10, 10, 60),

                  child:  Align(

                      alignment: Alignment.bottomCenter,
                      child:  Divider(thickness: 2,)
                  ),
                ),






              ],
            ),
          );
        },
      ),



    );
  }
}
