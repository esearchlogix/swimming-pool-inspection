import 'dart:io';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:poolinspection/config/app_config.dart' as config;
import 'package:poolinspection/src/controllers/inspection_controller.dart';
import 'package:poolinspection/src/models/DeleteImageModel.dart';
import 'package:poolinspection/src/pages/home/PermissionHandler.dart';
import 'package:poolinspection/src/pages/utils/MyDialogMobile.dart';
import 'package:poolinspection/src/pages/utils/MyDialogTablet.dart';
import 'package:poolinspection/src/pages/utils/customradio.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:rflutter_alert/rflutter_alert.dart';



class QuestionsList extends StatefulWidget {
  var question;
  int i;

  QuestionsList(this.question, this.i);

  @override
  _QuestionsListState createState() => _QuestionsListState();
}

class _QuestionsListState extends StateMVC<QuestionsList> {
 final GlobalKey<FormState> _formKey =  GlobalKey<FormState>();
  InspectionController _con;
  StateSetter _setState;


  int showCommentAndImages=0;
  int indexofrectiornoncomp=-1;
  bool filter = false;
  List<String> parts=[];
  List<String> partImageName=[];

  _QuestionsListState() : super(InspectionController()) {
    _con = controller;
  }

//  void _openFileExplorer() async {
//    if (_con.pickingType != FileType.custom || _con.hasValidMime) {
//      setState(() => _con.loadingPath = true);
//      try {
//        if (_con.multiPick) {
//          _con.path = null;
//          _con.paths = await FilePicker.getMultiFilePath(
//              type: FileType.image);
//        } else {
//          _con.paths = null;
//          _con.path = await FilePicker.getFilePath(
//              type: _con.pickingType);
//        }
//      } on PlatformException catch (e) {
//        print("Unsupported operation" + e.toString());
//      }
//      if (!mounted) return;
//      setState(() {
//        _con.loadingPath = false;
//        _con.fileName = _con.path != null
//            ? _con.path.split('/').last
//            : _con.paths != null ? _con.paths.keys.toString() : '...';
//      });
//    }
//    Flushbar(
//      title: "Image selected",
//      message: "Proceed ahead",
//      duration: Duration(seconds: 3),
//    )..show(context);
//  }


  Future clearImage(int bookingAnswerId, Image,int bookingId,int indexofimage) async
  {
    ProgressDialog pr;
    pr = ProgressDialog(context,isDismissible: false);
    //final bytes = await .File(dataimage).readAsBytes();
    print("DeleteImageBookANsId="+bookingAnswerId.toString());
    print("DeleteImage="+Image);
    print("DeleteImageBookingID="+bookingId.toString());
    try {
      pr.show();

//      Fluttertoast.showToast(
//          msg: "Opening Certificate, Please Wait..",
//          toastLength: Toast.LENGTH_LONG,
//          gravity: ToastGravity.BOTTOM,
//          timeInSecForIosWeb: 1,
//          backgroundColor: Colors.blue,
//          textColor: Colors.white,
//          fontSize: 16.0
//      );
      final response = await http.post(
          'https://poolinspection.beedevstaging.com/api/beedev/remove-booking-ans-image',
          body: {
            'booking_ans_id': bookingAnswerId.toString(),
            'image':Image,
            'booking_id':bookingId.toString(),

          }
      );

      DeleteImageModel imagedelete = deleteImageModelFromJson(response.body);


     if(imagedelete.status=="success") {
       pr.hide();

             Fluttertoast.showToast(
          msg: "Image Deleted Successfully",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.blue,
          textColor: Colors.white,
          fontSize: 16.0
      );

       setState(() {

         partImageName.removeAt(indexofimage);

       });
     }else
       {
         pr.hide();
         Fluttertoast.showToast(
             msg: imagedelete.messages.toString(),
             toastLength: Toast.LENGTH_LONG,
             gravity: ToastGravity.BOTTOM,
             timeInSecForIosWeb: 1,
             backgroundColor: Colors.blue,
             textColor: Colors.white,
             fontSize: 16.0
         );

       }

      //   await pr.hide();

    }catch(e)
    {
      pr.hide();
      // await pr.hide();
      print("ErrorInDeleteImageBackend"+e.toString());
      Fluttertoast.showToast(
          msg: "ErrorInDeleteImageBackend"+e.toString(),
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0
      );
    }

  }

//  void _onImageButtonPressed() async {
//
//    if (_con.pickingType != FileType.custom || _con.hasValidMime) {
//
//
//      setState(() => _con.loadingPath = true);
//      try {
//        // _con.paths = null;
//        final File image=  await ImagePicker.pickImage(
//          source: ImageSource.camera,
//          maxWidth: 150,
//          maxHeight: 150,
//        );
//        if (image == null) return;
//        // getting a directory path for saving
//        // Step 3: Get directory where we can duplicate selected file.
//        final Directory directory = await getExternalStorageDirectory();
//        final String path = await directory.path;
//        // using your method of getting an image
//        final File newImage = await image.copy(path+"/image${++counter}.png");
//        setState(() {
//
//          _con.loadingPath = false;
//
//         // print("addedimagepath"+_con.path.toString());
//          //_con.path.add("hello");
//          _con.path.add(newImage.path.toString().substring(0,newImage.path.length));
//
//          _con.fileName.add("image${counter}.png");
//
//
//          //   print("goku is godimagepathinques"+newImage.toString());
//          print("newaddpath"+_con.path.toString());
//          print("newaddimages"+_con.fileName.toString());
////        _con.fileName = _con.path != null
////            ? _con.path.split('/').last
////            : '...';
//        });
////        _setState(() {
////
////
////
////        });
////        setState(() {
////          _image = newImage;
////        });
//// copy the file to a new path
//
//
////        setState(() {
////          _image = newImage;
////        });
//        // Step 4: Copy the file to a application document directory.
//
//      } on PlatformException catch (e) {
//        print("Unsupported operation" + e.toString());
//      }
//      if (!mounted) return;
//
//    }
//
//    Flushbar(
//      title: "Image selected",
//      message: "Please Submit Answer",
//      duration: Duration(seconds: 3),
//    )..show(context);
//
//
//
//  }
  @override
  void initState() {
    super.initState();

    print("soclose"+widget.question['heading_id'].toString());
    widget.question['images']==''?widget.question['images']=null:null;
    _con.data.bookingAnsId = widget.question['id'];
    _con.data.comment = widget.question['comment'];
    _con.data.bookingID=widget.question['booking_id'].toString();
    _con.data.questionId=widget.question['quesion_id'].toString();
    _con.data.headingid=widget.question['heading_id'].toString();
    String input = "qqqqq";
    String imagetemp = "";

    widget.question['file_name']!=null?input=GlobalConfiguration().getString('api_question_image').toString()+widget.question['hint_img_destination'].toString()+"/"+widget.question['file_name'].toString():input="qwww";
    widget.question['images']!=null?imagetemp=widget.question['images']:null;
    parts = input.split(",");
    partImageName= imagetemp==""?[]:imagetemp.split(",");

    print("totalImage$partImageName");
    print("totalImagelength${partImageName.length}");
   // print("hintbaseurl"+GlobalConfiguration().getString('api_question_image').toString()+widget.question['hint_img_destination'].toString()+"/"+parts[0].toString());
    switch (widget.question['ans']) {
      case "2":
        print("${widget.question['ans']} compliant");
        _con.sampleData.add(new RadioModel(true, 'Compliant', 'April 18'));
    //    _con.sampleData.add(new RadioModel(false, 'Rectification Required', 'April 17'));
        _con.sampleData.add(new RadioModel(false, 'Non Compliant', 'April 17'));
        _con.sampleData
            .add(new RadioModel(false, 'Not Applicable', 'April 16'));
        break;
//      case "4":
//        print("${widget.question['ans']} rectification required");
//        _con.sampleData.add(new RadioModel(false, 'Compliant', 'April 18'));
//        _con.sampleData.add(new RadioModel(true, 'Rectification Required', 'April 17'));
//        _con.sampleData.add(new RadioModel(false, 'Non Compliant', 'April 17'));
//        _con.sampleData.add(new RadioModel(false, 'Not Applicable', 'April 16'));
//        break;
      case "3":
        print("${widget.question['ans']} noncompliant");

        _con.sampleData.add(new RadioModel(false, 'Compliant', 'April 18'));
       // _con.sampleData.add(new RadioModel(false, 'Rectification Required', 'April 17'));
        _con.sampleData.add(new RadioModel(true, 'Non Compliant', 'April 17'));
        _con.sampleData
            .add(new RadioModel(false, 'Not Applicable', 'April 16'));
        break;
      case "1":
        print("${widget.question['ans']} not applicable");

        _con.sampleData.add(new RadioModel(false, 'Compliant', 'April 18'));
       // _con.sampleData.add(new RadioModel(false, 'Rectification Required', 'April 17'));
        _con.sampleData.add(new RadioModel(false, 'Non Compliant', 'April 17'));
        _con.sampleData.add(new RadioModel(true, 'Not Applicable', 'April 16'));
        break;

      case "10":
        print("${widget.question['ans']} yes");
        _con.sampleData.add(new RadioModel(false, 'Compliant', 'April 18'));
        // _con.sampleData.add(new RadioModel(false, 'Rectification Required', 'April 17'));
        _con.sampleData.add(new RadioModel(false, 'Non Compliant', 'April 17'));
        _con.sampleData.add(new RadioModel(false, 'Not Applicable', 'April 16'));
        _con.sampleData.add(new RadioModel(true, 'Yes', 'April 18'));
        // _con.sampleData.add(new RadioModel(false, 'Rectification Required', 'April 17'));
        _con.sampleData.add(new RadioModel(false, 'No', 'April 17'));
        break;

      case "11":
        print("${widget.question['ans']} no");
        _con.sampleData.add(new RadioModel(false, 'Compliant', 'April 18'));
        // _con.sampleData.add(new RadioModel(false, 'Rectification Required', 'April 17'));
        _con.sampleData.add(new RadioModel(false, 'Non Compliant', 'April 17'));
        _con.sampleData.add(new RadioModel(false, 'Not Applicable', 'April 16'));
        _con.sampleData.add(new RadioModel(false, 'Yes', 'April 18'));
        // _con.sampleData.add(new RadioModel(false, 'Rectification Required', 'April 17'));
        _con.sampleData.add(new RadioModel(true, 'No', 'April 17'));

        break;
      default:
        _con.sampleData.add(new RadioModel(false, 'Compliant', 'April 18'));
       // _con.sampleData.add(new RadioModel(false, 'Rectification Required', 'April 17'));
        _con.sampleData.add(new RadioModel(false, 'Non Compliant', 'April 17'));
        _con.sampleData
            .add(new RadioModel(false, 'Not Applicable', 'April 16'));
        _con.sampleData.add(new RadioModel(false, 'Yes', 'April 18'));
        // _con.sampleData.add(new RadioModel(false, 'Rectification Required', 'April 17'));
        _con.sampleData.add(new RadioModel(false, 'No', 'April 17'));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: config.Colors().scaffoldColor(1),
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
              color: config.Colors().secondColor(1),
            ),
            onPressed: () => Navigator.pop(context,true)),
        title: Align(alignment: Alignment.topCenter,
          child:Text("Building Regulations              ",
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontFamily: "AVENIRLTSTD",
              fontSize: 20,
              color: Color(0xff222222),
            ),
          ),

        ),
        actions: <Widget>[


        ],
      ),


      body: widget.question == null
          ? CircularProgressIndicator()
          : Column(
       crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Flexible(
            flex: 10,
            child: SingleChildScrollView(
              child: Container(

                  decoration: BoxDecoration(color: Colors.white),
                  child:  Padding(
                    padding: EdgeInsets.fromLTRB(18, 10,10, 10),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child:Text("REGULATION NAME: "+widget.question['regulation_name'].toString(),style: TextStyle(fontSize: 22, color: Colors.black,  fontFamily: "AVENIRLTSTD",fontWeight: FontWeight.w700),),
                    ),
                  )
              ),
            ),
          ),
//          widget.question
//          ['heading_description']==""?Container() :Flexible(
//            flex: 3,
//              child:Container(
//                width: MediaQuery.of(context).size.width,
//                  decoration: BoxDecoration(color: Colors.white),
//                  child:Column(
//                    children: <Widget>[
//                      GestureDetector(
//
//                          onTap: ()
//                          {
//
//                            showDialog(
//                              context: context,
//                              builder: (BuildContext context) {
//                                // return object of type Dialog
//                                return StatefulBuilder(
//                                    builder: (context, setState) {
//                                      return  SingleChildScrollView(
//                                          child:AlertDialog(
//
//                                            content: Column(
//                                              mainAxisSize: MainAxisSize.min,
//                                              children: <Widget>[
//                                                Align(
//
//                                                  child: GestureDetector(
//
//                                                    onTap: ()
//                                                    {
//                                                      Navigator.of(context).pop();
//                                                    },
//                                                    child: Icon(Icons.clear,color: Colors.grey,),
//                                                  ),
//                                                  alignment: Alignment.topRight,
//                                                ),
//                                                SizedBox(height: 10,),
//                                                Flexible(child:
//                                                SingleChildScrollView(
//                                                    child: Text(
//                                                      widget.question
//                                                      ['heading_description'].toString(),
//                                                      style: TextStyle(
//                                                          fontFamily: "AVENIRLTSTD",
//                                                          color: Colors.black,
//                                                          fontSize: 20),
//
//
//                                                    )
//                                                )
//                                                ),
//
//
//
//                                              ],
//                                            ),
//                                          )
//                                      );
//                                    }
//                                );
//
//                              },
//                            );
//
//
//
//
//
//                          },
//                          child: Padding(
//
//                            padding: EdgeInsets.fromLTRB(0, 2, 0, 0),
//                            child: Align(
//                              alignment: Alignment.topLeft,
//                              child: Padding(
//                                padding: EdgeInsets.fromLTRB(20, 10, 5, 0),
//                                child: Text(
//
//                                  "Description",
//
//                                  // demo,
//                                  textAlign: TextAlign.left,
//                                  style: TextStyle(
//
//                                      fontSize: 20,
//                                      fontWeight: FontWeight.w700,
//                                      // fontWeight: FontWeight.w500,
//                                      fontFamily: "AVENIRLTSTD",
//                                      color: Colors.blueAccent),
//
//                                ),
//                              )
//
//                            ),
//                          )
//                      ),
//                    ],
//                  )
//              )
//          ),
          SizedBox(height: 20,),
          Flexible(
           flex: 8,
         child:SingleChildScrollView(
           child:  Padding(
             padding: EdgeInsets.fromLTRB(20, 8, 8, 8),
             child:Text(widget.question['heading_name'].toString(),
               style: TextStyle(fontSize: 20, color: Colors.black,  fontFamily: "AVENIRLTSTD",fontWeight: FontWeight.w700),),),
         )

         ),
/// Two layouts for mobile and tablet diffefence is 40 and 80 in flex
          MediaQuery.of(context).size.width<=600?Expanded(
            flex: 40,
            child: Padding(
                padding: EdgeInsets.fromLTRB(15, 15, 15, 0),
                child:  Container(
                  color: Theme.of(context).primaryColor,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                     SizedBox(height: 10,),
                     ListTile(
                         title: Row(
                           mainAxisAlignment: MainAxisAlignment.center,
                           children: <Widget>[
                             Expanded(child:Align(

                               child: Padding(
                                 padding: EdgeInsets.fromLTRB(8, 4, 8, 6),
                                 child: Text(
                                   ("Q${widget.i + 1}.").toString()+" "+widget.question['question'],
                                   // demo,
                                   textAlign: TextAlign.left,
                                   style: TextStyle(
                                       fontSize: 23,
                                       // fontWeight: FontWeight.w500,
                                       fontFamily: "AVENIRLTSTD",
                                       color: Color(0xff222222)),
                                 ),
                               ),
                               alignment: Alignment.centerLeft,
                             )
                             ),

                           ],),

                         subtitle:Padding(
                           padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                           child: GestureDetector(
                             onTap: ()
                             {
                               bool show=false;

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
                                              child:  Text(
                                                widget.question['hint']
                                                    .toString(),
                                                style: TextStyle(
                                                    fontFamily: "AVENIRLTSTD",
                                                    color: Colors.black,
                                                    fontSize: 18),
                                              ),
                                            )
                                             ),
                                             SizedBox(height: 20,),
                                             widget.question['file_name']!=null?Flexible(
                                                 child: GestureDetector(

                                                   child: Text(
                                                     "show image",
                                                     style: TextStyle(
                                                         fontFamily: "AVENIRLTSTD",
                                                         color: Colors.blueAccent,
                                                         fontSize: 18),
                                                   ),
                                                   onTap: () {
                             setState(() {
                               print("imgend"+GlobalConfiguration().getString('api_question_image').toString()+widget.question['destination'].toString()+widget.question['file_name'].toString());
                              // print("urlofimagehint"+GlobalConfiguration().toString()+"/"+widget.question['destination'].toString()+"/"+widget.question['images'].toString());
                               show == false
                                   ? show = true
                                   : show = false;
                             });
                                                   },

                                                 )
                                             ):Container(),
                                             show==true?Flexible(child: show == true
                                                 ? Divider(thickness: 2,)
                                                 : Container(),):Container(),


                                             show==true?show == true
                                                     ?Container(

                                               child: Image.network(
                                                   parts[0].toString(),

                                                   fit: BoxFit.fitWidth)
                                             )


                                                     : Container()
                                             :Container(),

                                             show==true && parts.length>1?show == true
                                                 ?Container(

                                                 child: Image.network(
                                       GlobalConfiguration().getString('api_question_image').toString()+widget.question['hint_img_destination'].toString()+"/"+ parts[1].toString(),

                                                     fit: BoxFit.fitWidth)
                                             )


                                                 : Container()
                                                 :Container()

                                           ],
                                         ),
                                       )
                                       );
                                     }
                             );

                                   },
                                 );





                             },
                             child: Text(

                               "More Info.",

                               // demo,
                               textAlign: TextAlign.left,
                               style: TextStyle(

                                   fontSize: 20,
                                   fontWeight: FontWeight.w700,
                                   // fontWeight: FontWeight.w500,
                                   fontFamily: "AVENIRLTSTD",
                                   color: Colors.blueAccent),

                             ),
                           ),
                         )

                       ),

                        MediaQuery.of(context).size.width<=600?SizedBox(height: 30):SizedBox(height: 90,),


                        _con.confirmLoader
                            ? SizedBox(
                            width: 35,
                            child: Center(child: CircularProgressIndicator()))
                            : Container(
                          // alignment: Alignment.bottomCenter,
                          height: config.App(context).appHeight(widget.question['ans'].toString()=="3"?(
                              partImageName.length==0?55:partImageName.length==1?85:partImageName.length==2?125:partImageName.length==3?155:partImageName.length==4?215:215
                          ):55),
                          child: Column(

                            children: <Widget>[

//                              showCommentAndImages==1?
//
//                               :Container(),
                              Expanded(

                                child: ListView.builder(

                                physics: NeverScrollableScrollPhysics(),
                                itemCount: _con.sampleData.length,
                                itemBuilder: (BuildContext context, int index) {
                                  return new InkWell(

                                    //highlightColor: Colors.red,
                                    // splashColor: Colors.blueAccent,
                                    onTap: () {

//                                      _con.sampleData[index].buttonText=="Rectification Required"||
//                                          _con.sampleData[index].buttonText=="Non Compliant"?null:_con.data.comment=null;
//
//                                      _con.sampleData[index].buttonText=="Rectification Required"||
//                                          _con.sampleData[index].buttonText=="Non Compliant"?null:_con.data.imagename=null;
//
//                                      _con.sampleData[index].buttonText=="Rectification Required"||
//                                          _con.sampleData[index].buttonText=="Non Compliant"?null:_con.data.imagepath=null;

                                      _con.sampleData[index].buttonText=="Rectification Required"||
                                          _con.sampleData[index].buttonText=="Non Compliant"? MediaQuery.of(context).size.width<=600?showdialogmobile(1,index):showdialogtablet(1, index)
//
                                     :
                                      _con.getPostQuestions(widget.i,index, context);


                                    },

                                    child:widget.question['question_type'].toString()=="0"?index<=2?new RadioItem(_con.sampleData[index]):Container()
                                    :index>=3?new RadioItem(_con.sampleData[index]):Container(),

                                  );
                                },
                              ),
                              ),

                              partImageName.length>=1&&(widget.question['ans'].toString()!="1"&&
                                  widget.question['ans'].toString()!="2")?Padding(
                                padding: EdgeInsets.fromLTRB(0, 0, 25, 15),
                                child: Align(
                                  alignment: Alignment.topRight,
                                  child:
                                  Container(
                                    height: 20,
                                    width: 20,
                                    child: GestureDetector(
                                      child: Icon(Icons.cancel,size: 30,color: Colors.blue,),
                                      onTap: () async{
                                        await clearImage(widget.question['id'],partImageName[0].toString(),widget.question['booking_id'],0);
                                      },
                                    ),
                                  ),
                                ),
                              ):Container(),
                              partImageName.length>=1&&(widget.question['ans'].toString()!="1"&&
                                  widget.question['ans'].toString()!="2")?Expanded(
                                  child:   Image.network(
                                    "${GlobalConfiguration().getString('api_question_image')}${widget.question['destination']}/${partImageName[0]}",
                                    fit: BoxFit.fill,


                                  )
                              ):Container(),

                              partImageName.length>=2&&(widget.question['ans'].toString()!="1"&&
                                  widget.question['ans'].toString()!="2")?Padding(
                                padding: EdgeInsets.fromLTRB(0, 15, 25, 0),
                                child: Align(
                                  alignment: Alignment.topRight,
                                  child:
                                  Container(
                                    height: 20,
                                    width: 20,
                                    child: GestureDetector(
                                      child: Icon(Icons.cancel,size: 30,color: Colors.blue,),
                                      onTap: () async{
                                        await clearImage(widget.question['id'],partImageName[1].toString(),widget.question['booking_id'],1);
                                      },
                                    ),
                                  ),
                                ),
                              ):Container(),
                              partImageName.length>=2&&(widget.question['ans'].toString()!="1"&&
                                  widget.question['ans'].toString()!="2")?Expanded(
                                  child:   Image.network(
                                    "${GlobalConfiguration().getString('api_question_image')}${widget.question['destination']}/${partImageName[1]}",
                                    fit: BoxFit.fill,


                                  )
                              ):Container(),


                              partImageName.length>=3&&(widget.question['ans'].toString()!="1"&&
                                  widget.question['ans'].toString()!="2")?Padding(
                                padding: EdgeInsets.fromLTRB(0, 15, 25, 0),
                                child: Align(
                                  alignment: Alignment.topRight,
                                  child:
                                  Container(
                                    height: 20,
                                    width: 20,
                                    child: GestureDetector(
                                      child: Icon(Icons.cancel,size: 30,color: Colors.blue,),
                                      onTap: () async{
                                        await clearImage(widget.question['id'],partImageName[2].toString(),widget.question['booking_id'],2);
                                      },
                                    ),
                                  ),
                                ),
                              ):Container(),
                              partImageName.length>=3&&(widget.question['ans'].toString()!="1"&&
                                  widget.question['ans'].toString()!="2")?Expanded(
                                  child:   Image.network(
                                    "${GlobalConfiguration().getString('api_question_image')}${widget.question['destination']}/${partImageName[2]}",
                                    fit: BoxFit.fill,


                                  )
                              ):Container(),


                              partImageName.length>=4&&(widget.question['ans'].toString()!="1"&&
                                  widget.question['ans'].toString()!="2")?Padding(
                                padding: EdgeInsets.fromLTRB(0, 15, 25, 0),
                                child: Align(
                                  alignment: Alignment.topRight,
                                  child:
                                  Container(
                                    height: 20,
                                    width: 20,
                                    child: GestureDetector(
                                      child: Icon(Icons.cancel,size: 30,color: Colors.blue,),
                                      onTap: () async{
                                        await clearImage(widget.question['id'],partImageName[3].toString(),widget.question['booking_id'],3);
                                      },
                                    ),
                                  ),
                                ),
                              ):Container(),
                              partImageName.length>=4&&(widget.question['ans'].toString()!="1"&&
                                  widget.question['ans'].toString()!="2")?Expanded(
                                  child:   Image.network(
                                    "${GlobalConfiguration().getString('api_question_image')}${widget.question['destination']}/${partImageName[3]}",
                                    fit: BoxFit.fill,


                                  )
                              ):Container(),

                              partImageName.length>=5&&(widget.question['ans'].toString()!="1"&&
                                  widget.question['ans'].toString()!="2")?Padding(
                                padding: EdgeInsets.fromLTRB(0, 15, 25, 0),
                                child: Align(
                                  alignment: Alignment.topRight,
                                  child:
                                  Container(
                                    height: 20,
                                    width: 20,
                                    child: GestureDetector(
                                      child: Icon(Icons.cancel,size: 30,color: Colors.blue,),
                                      onTap: () async{
                                        await clearImage(widget.question['id'],partImageName[4].toString(),widget.question['booking_id'],4);
                                      },
                                    ),
                                  ),
                                ),
                              ):Container(),
                              partImageName.length>=5&&(widget.question['ans'].toString()!="1"&&
                                  widget.question['ans'].toString()!="2")?Expanded(
                                  child:   Image.network(
                                    "${GlobalConfiguration().getString('api_question_image')}${widget.question['destination']}/${partImageName[4]}",
                                    fit: BoxFit.fill,


                                  )
                              ):Container(),
//
//                              widget.question['images']==null||(widget.question['ans'].toString()=="1"||
//                                  widget.question['ans'].toString()=="2")?Container():Padding(
//                                padding: EdgeInsets.fromLTRB(0, 0, 10, 15),
//                                child: Align(
//                                  alignment: Alignment.topRight,
//                                  child:
//                                  Container(
//                                    height: 20,
//                                    width: 20,
//                                    child: GestureDetector(
//                                      child: Icon(Icons.clear,size: 30,),
//                                      onTap: () async{
//
//                                      await clearImage(widget.question['id'],widget.question['images'],widget.question['booking_id']);
//
//
//                                      },
//                                    ),
//                                  ),
//                                ),
//                              ),
//                              widget.question['images']==null||(widget.question['ans'].toString()=="1"||
//                                  widget.question['ans'].toString()=="2")?Container():Expanded(
//                             child:   Image.network(
//                               "${GlobalConfiguration().getString('api_question_image')}${widget.question['destination']}/${widget.question['images']}",
//                               fit: BoxFit.fill,
//
//
//                           )
//                           ),



                            ],
                          )

                        ),
//                        SizedBox(
//                          height: config.App(context).appHeight(2),
//                        ),
//                        //TODO
//                        // _con.loadingPath != null
//                        //     ? Container(
//                        //         padding: EdgeInsets.all(1.0),
//                        //         height: 200,
//                        //         child: buildListView(),
//                        //       )
//                        //     : Container(),
//                        //TODO
//                        widget.question['images'] == null
//                            ? Container()
//                            : Container(
//                          padding: EdgeInsets.all(1.0),
//                          height: 200,
//                          child: ListView.builder(
//                            scrollDirection: Axis.horizontal,
//                            itemCount: widget.question['images'].length,
//                            itemBuilder: (BuildContext context, int i) {
//                              return widget.question['images'].length == 0
//                                  ? Center(
//                                child: CircularProgressIndicator(),
//                              )
//                                  : Image.network(
//                                  "${GlobalConfiguration().getString('api_question_image')}${widget.question['destination']}/${widget.question['images'][i]}",
//                                  // height: 100,
//                                  // width: 100,
//                                  fit: BoxFit.fitHeight);
//                            },
//                          ),
//                        )
                      ],
                    ),
                  ),
                )


//              new Stack(
//                children: <Widget>[
//              Text("REGULATION NAME: "+widget.question['regulation_name'].toString(),style: TextStyle(fontSize: 22, color: Colors.black,  fontFamily: "AVENIRLTSTD",fontWeight: FontWeight.w700),),
//
//                  Container(
//                    color: Theme.of(context).primaryColor,
//                    child:
//                  ),
//                ],
//              )
            ),
            ): Expanded(    //this for tablet
            flex: 90,
            child: Padding(
                padding: EdgeInsets.fromLTRB(15, 15, 15, 0),
                child:  Container(
                  color: Theme.of(context).primaryColor,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        SizedBox(height: 10,),
                        ListTile(
                            title: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Expanded(child:Align(

                                  child: Padding(
                                    padding: EdgeInsets.fromLTRB(8, 4, 8, 6),
                                    child: Text(
                                      ("Q${widget.i + 1}.").toString()+" "+widget.question['question'],
                                      // demo,
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                          fontSize: 23,
                                          // fontWeight: FontWeight.w500,
                                          fontFamily: "AVENIRLTSTD",
                                          color: Color(0xff222222)),
                                    ),
                                  ),
                                  alignment: Alignment.centerLeft,
                                )
                                ),

                              ],),

                            subtitle:Padding(
                              padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                              child: GestureDetector(
                                onTap: ()
                                {
                                  bool show=false;

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
                                                        child:  Text(
                                                          widget.question['hint']
                                                              .toString(),
                                                          style: TextStyle(
                                                              fontFamily: "AVENIRLTSTD",
                                                              color: Colors.black,
                                                              fontSize: 18),
                                                        ),
                                                      )
                                                      ),
                                                      SizedBox(height: 20,),
                                                      widget.question['file_name']!=null?Flexible(
                                                          child: GestureDetector(

                                                            child: Text(
                                                              "show image",
                                                              style: TextStyle(
                                                                  fontFamily: "AVENIRLTSTD",
                                                                  color: Colors.blueAccent,
                                                                  fontSize: 18),
                                                            ),
                                                            onTap: () {
                                                              setState(() {
                                                                print("imgend"+GlobalConfiguration().getString('api_question_image').toString()+widget.question['destination'].toString()+widget.question['file_name'].toString());
                                                                // print("urlofimagehint"+GlobalConfiguration().toString()+"/"+widget.question['destination'].toString()+"/"+widget.question['images'].toString());
                                                                show == false
                                                                    ? show = true
                                                                    : show = false;
                                                              });
                                                            },

                                                          )
                                                      ):Container(),
                                                      show==true?Flexible(child: show == true
                                                          ? Divider(thickness: 2,)
                                                          : Container(),):Container(),


                                                      show==true?show == true
                                                          ?Container(

                                                          child: Image.network(
                                                              parts[0].toString(),

                                                              fit: BoxFit.fitWidth)
                                                      )


                                                          : Container()
                                                          :Container(),

                                                      show==true && parts.length>1?show == true
                                                          ?Container(

                                                          child: Image.network(
                                                              GlobalConfiguration().getString('api_question_image').toString()+widget.question['hint_img_destination'].toString()+"/"+ parts[1].toString(),

                                                              fit: BoxFit.fitWidth)
                                                      )


                                                          : Container()
                                                          :Container()

                                                    ],
                                                  ),
                                                )
                                            );
                                          }
                                      );

                                    },
                                  );





                                },
                                child: Text(

                                  "More Info.",

                                  // demo,
                                  textAlign: TextAlign.left,
                                  style: TextStyle(

                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                      // fontWeight: FontWeight.w500,
                                      fontFamily: "AVENIRLTSTD",
                                      color: Colors.blueAccent),

                                ),
                              ),
                            )

                        ),

                        MediaQuery.of(context).size.width<=600?SizedBox(height: 30):SizedBox(height: 90,),


                        _con.confirmLoader
                            ? SizedBox(
                            width: 35,
                            child: Center(child: CircularProgressIndicator()))
                            : Container(
                          // alignment: Alignment.bottomCenter,
                            height: config.App(context).appHeight(widget.question['ans'].toString()=="3"?(
                                partImageName.length==0?55:partImageName.length==1?85:partImageName.length==2?125:partImageName.length==3?155:partImageName.length==4?215:215
                            ):55),
                            child: Column(

                              children: <Widget>[

//                              showCommentAndImages==1?
//
//                               :Container(),
                                Expanded(

                                  child: ListView.builder(

                                    physics: NeverScrollableScrollPhysics(),
                                    itemCount: _con.sampleData.length,
                                    itemBuilder: (BuildContext context, int index) {
                                      return new InkWell(

                                        //highlightColor: Colors.red,
                                        // splashColor: Colors.blueAccent,
                                        onTap: () {

//                                      _con.sampleData[index].buttonText=="Rectification Required"||
//                                          _con.sampleData[index].buttonText=="Non Compliant"?null:_con.data.comment=null;
//
//                                      _con.sampleData[index].buttonText=="Rectification Required"||
//                                          _con.sampleData[index].buttonText=="Non Compliant"?null:_con.data.imagename=null;
//
//                                      _con.sampleData[index].buttonText=="Rectification Required"||
//                                          _con.sampleData[index].buttonText=="Non Compliant"?null:_con.data.imagepath=null;

                                          _con.sampleData[index].buttonText=="Rectification Required"||
                                              _con.sampleData[index].buttonText=="Non Compliant"? MediaQuery.of(context).size.width<=600?showdialogmobile(1,index):showdialogtablet(1, index)
//
                                              :
                                          _con.getPostQuestions(widget.i,index, context);


                                        },

                                        child:widget.question['question_type'].toString()=="0"?index<=2?new RadioItem(_con.sampleData[index]):Container()
                                            :index>=3?new RadioItem(_con.sampleData[index]):Container(),

                                      );
                                    },
                                  ),
                                ),

                                partImageName.length>=1&&(widget.question['ans'].toString()!="1"&&
                                    widget.question['ans'].toString()!="2")?Padding(
                                  padding: EdgeInsets.fromLTRB(0, 0, 25, 15),
                                  child: Align(
                                    alignment: Alignment.topRight,
                                    child:
                                    Container(
                                      height: 20,
                                      width: 20,
                                      child: GestureDetector(
                                        child: Icon(Icons.cancel,size: 30,color: Colors.blue,),
                                        onTap: () async{
                                          await clearImage(widget.question['id'],partImageName[0].toString(),widget.question['booking_id'],0);
                                        },
                                      ),
                                    ),
                                  ),
                                ):Container(),
                                partImageName.length>=1&&(widget.question['ans'].toString()!="1"&&
                                    widget.question['ans'].toString()!="2")?Expanded(
                                    child:   Image.network(
                                      "${GlobalConfiguration().getString('api_question_image')}${widget.question['destination']}/${partImageName[0]}",
                                      fit: BoxFit.fill,


                                    )
                                ):Container(),

                                partImageName.length>=2&&(widget.question['ans'].toString()!="1"&&
                                    widget.question['ans'].toString()!="2")?Padding(
                                  padding: EdgeInsets.fromLTRB(0, 15, 25, 0),
                                  child: Align(
                                    alignment: Alignment.topRight,
                                    child:
                                    Container(
                                      height: 20,
                                      width: 20,
                                      child: GestureDetector(
                                        child: Icon(Icons.cancel,size: 30,color: Colors.blue,),
                                        onTap: () async{
                                          await clearImage(widget.question['id'],partImageName[1].toString(),widget.question['booking_id'],1);
                                        },
                                      ),
                                    ),
                                  ),
                                ):Container(),
                                partImageName.length>=2&&(widget.question['ans'].toString()!="1"&&
                                    widget.question['ans'].toString()!="2")?Expanded(
                                    child:   Image.network(
                                      "${GlobalConfiguration().getString('api_question_image')}${widget.question['destination']}/${partImageName[1]}",
                                      fit: BoxFit.fill,


                                    )
                                ):Container(),


                                partImageName.length>=3&&(widget.question['ans'].toString()!="1"&&
                                    widget.question['ans'].toString()!="2")?Padding(
                                  padding: EdgeInsets.fromLTRB(0, 15, 25, 0),
                                  child: Align(
                                    alignment: Alignment.topRight,
                                    child:
                                    Container(
                                      height: 20,
                                      width: 20,
                                      child: GestureDetector(
                                        child: Icon(Icons.cancel,size: 30,color: Colors.blue,),
                                        onTap: () async{
                                          await clearImage(widget.question['id'],partImageName[2].toString(),widget.question['booking_id'],2);
                                        },
                                      ),
                                    ),
                                  ),
                                ):Container(),
                                partImageName.length>=3&&(widget.question['ans'].toString()!="1"&&
                                    widget.question['ans'].toString()!="2")?Expanded(
                                    child:   Image.network(
                                      "${GlobalConfiguration().getString('api_question_image')}${widget.question['destination']}/${partImageName[2]}",
                                      fit: BoxFit.fill,


                                    )
                                ):Container(),


                                partImageName.length>=4&&(widget.question['ans'].toString()!="1"&&
                                    widget.question['ans'].toString()!="2")?Padding(
                                  padding: EdgeInsets.fromLTRB(0, 15, 25, 0),
                                  child: Align(
                                    alignment: Alignment.topRight,
                                    child:
                                    Container(
                                      height: 20,
                                      width: 20,
                                      child: GestureDetector(
                                        child: Icon(Icons.cancel,size: 30,color: Colors.blue,),
                                        onTap: () async{
                                          await clearImage(widget.question['id'],partImageName[3].toString(),widget.question['booking_id'],3);
                                        },
                                      ),
                                    ),
                                  ),
                                ):Container(),
                                partImageName.length>=4&&(widget.question['ans'].toString()!="1"&&
                                    widget.question['ans'].toString()!="2")?Expanded(
                                    child:   Image.network(
                                      "${GlobalConfiguration().getString('api_question_image')}${widget.question['destination']}/${partImageName[3]}",
                                      fit: BoxFit.fill,


                                    )
                                ):Container(),

                                partImageName.length>=5&&(widget.question['ans'].toString()!="1"&&
                                    widget.question['ans'].toString()!="2")?Padding(
                                  padding: EdgeInsets.fromLTRB(0, 15, 25, 0),
                                  child: Align(
                                    alignment: Alignment.topRight,
                                    child:
                                    Container(
                                      height: 20,
                                      width: 20,
                                      child: GestureDetector(
                                        child: Icon(Icons.cancel,size: 30,color: Colors.blue,),
                                        onTap: () async{
                                          await clearImage(widget.question['id'],partImageName[4].toString(),widget.question['booking_id'],4);
                                        },
                                      ),
                                    ),
                                  ),
                                ):Container(),
                                partImageName.length>=5&&(widget.question['ans'].toString()!="1"&&
                                    widget.question['ans'].toString()!="2")?Expanded(
                                    child:   Image.network(
                                      "${GlobalConfiguration().getString('api_question_image')}${widget.question['destination']}/${partImageName[4]}",
                                      fit: BoxFit.fill,


                                    )
                                ):Container(),
//
//                              widget.question['images']==null||(widget.question['ans'].toString()=="1"||
//                                  widget.question['ans'].toString()=="2")?Container():Padding(
//                                padding: EdgeInsets.fromLTRB(0, 0, 10, 15),
//                                child: Align(
//                                  alignment: Alignment.topRight,
//                                  child:
//                                  Container(
//                                    height: 20,
//                                    width: 20,
//                                    child: GestureDetector(
//                                      child: Icon(Icons.clear,size: 30,),
//                                      onTap: () async{
//
//                                      await clearImage(widget.question['id'],widget.question['images'],widget.question['booking_id']);
//
//
//                                      },
//                                    ),
//                                  ),
//                                ),
//                              ),
//                              widget.question['images']==null||(widget.question['ans'].toString()=="1"||
//                                  widget.question['ans'].toString()=="2")?Container():Expanded(
//                             child:   Image.network(
//                               "${GlobalConfiguration().getString('api_question_image')}${widget.question['destination']}/${widget.question['images']}",
//                               fit: BoxFit.fill,
//
//
//                           )
//                           ),



                              ],
                            )

                        ),
//                        SizedBox(
//                          height: config.App(context).appHeight(2),
//                        ),
//                        //TODO
//                        // _con.loadingPath != null
//                        //     ? Container(
//                        //         padding: EdgeInsets.all(1.0),
//                        //         height: 200,
//                        //         child: buildListView(),
//                        //       )
//                        //     : Container(),
//                        //TODO
//                        widget.question['images'] == null
//                            ? Container()
//                            : Container(
//                          padding: EdgeInsets.all(1.0),
//                          height: 200,
//                          child: ListView.builder(
//                            scrollDirection: Axis.horizontal,
//                            itemCount: widget.question['images'].length,
//                            itemBuilder: (BuildContext context, int i) {
//                              return widget.question['images'].length == 0
//                                  ? Center(
//                                child: CircularProgressIndicator(),
//                              )
//                                  : Image.network(
//                                  "${GlobalConfiguration().getString('api_question_image')}${widget.question['destination']}/${widget.question['images'][i]}",
//                                  // height: 100,
//                                  // width: 100,
//                                  fit: BoxFit.fitHeight);
//                            },
//                          ),
//                        )
                      ],
                    ),
                  ),
                )


//              new Stack(
//                children: <Widget>[
//              Text("REGULATION NAME: "+widget.question['regulation_name'].toString(),style: TextStyle(fontSize: 22, color: Colors.black,  fontFamily: "AVENIRLTSTD",fontWeight: FontWeight.w700),),
//
//                  Container(
//                    color: Theme.of(context).primaryColor,
//                    child:
//                  ),
//                ],
//              )
            ),
          )
        ],
      )
    );


  }



  showdialogtablet(showCommentAndImageslocal,indexofrectiornoncomplocal)
  {
    setState(() {
      showCommentAndImages = showCommentAndImages;
      indexofrectiornoncomp = indexofrectiornoncomplocal;
      _con.sampleData.forEach((element) => element.isSelected = false);
      _con.sampleData[indexofrectiornoncomp].isSelected = true;
      print("gokuimage2"+widget.question['images'].toString());
      print("gokuimage"+" ${GlobalConfiguration().getString('api_question_image')}${widget.question['destination']}/${widget.question['images']}");
    });
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        // return object of type Dialog
        return MyDialogTablet(widget.i,_con,indexofrectiornoncomp,widget.question);
      },
    );
  }

  showdialogmobile(showCommentAndImageslocal,indexofrectiornoncomplocal)
  {

    setState(() {
      showCommentAndImages = showCommentAndImages;
      indexofrectiornoncomp = indexofrectiornoncomplocal;
      _con.sampleData.forEach((element) => element.isSelected = false);
      _con.sampleData[indexofrectiornoncomp].isSelected = true;
      print("gokuimage2"+widget.question['images'].toString());
      print("gokuimage"+" ${GlobalConfiguration().getString('api_question_image')}${widget.question['destination']}/${widget.question['images']}");
    });
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        // return object of type Dialog
        return MyDialogMobile(widget.i,_con,indexofrectiornoncomp,widget.question);
      },
    );
  }



}




