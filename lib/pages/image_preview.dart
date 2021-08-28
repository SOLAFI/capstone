import 'dart:convert';

import 'package:capstone/utils/device_info.dart';
import 'package:capstone/utils/image_processing.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import 'dart:core';
import 'dart:io';

import 'package:capstone/utils/sqlite_handler.dart';
import 'package:capstone/pages/recognition_result.dart';
import '../widgets/buttons.dart';
import '../widgets/text.dart';
import '../data/record.dart';
import 'package:capstone/constants.dart';



class ImagePreviewPage extends StatefulWidget {
  ImagePreviewPage({Key? key, required this.image}) : super(key: key);

  final File image;

  @override
  _ImagePreviewPageState createState() => _ImagePreviewPageState();
}

class _ImagePreviewPageState extends State<ImagePreviewPage> {

  Map<String, dynamic> postResponse = new Map();

  bool _isRecognizing = false;
  bool _error = false;
  double _sendProgress = 0;
  int recCount = 0;
  String errorMessage = '';
  late String deviceInfo;
  late int recordID;

  void reset() {
    setState((){
      _isRecognizing = false;
      _sendProgress = 0;
      errorMessage = '';
      _error = false;
    });
  }


  Future<int> getRecordsCount() async{
    recCount = await RecDBProvider.recordsCount();
    return recCount;
  }


  // POST request
  void _postToServer() async {

    setState(() {
      _isRecognizing = true;
    });
    
    int timestamp = DateTime.now().millisecondsSinceEpoch;
    int recCount = await getRecordsCount();
    recordID = recCount + 1;
    
    deviceInfo = await DeviceInfoProvider.gerDeviceInfo();

    FormData formData = FormData.fromMap({
      "file": await MultipartFile.fromFile(_image.path, filename: _image.path.split('/').last),
      "timestamp": timestamp,
      "device_number": deviceInfo,
      "local_id": recordID,
    });

    Dio(BaseOptions(connectTimeout: 15000)).post(
      RECOGNIZE_REQUEST,
      data: formData,
      onSendProgress: (int current, int total) {setState(() {
        _sendProgress = current/total;
      });},
    ).then((response){
      String result = '';
      reset();
      setState(() {
        if(response.toString()=="invalid image"){
          _error = true;
          errorMessage = 'Recognition failed :(\nIs this an image of a bird?';
          result = response.toString();
        }
        else{
          result = response.toString();
          showModalBottomSheet(context: context, builder: (context) => PredictionResultPage(result: result, recordID: recordID,));
        }
      });
      /*
          Insert a record to SQLite DB
        */ 
      _image.readAsBytes().then((bytes){
        String imageStream = base64Encode(bytes);
        RecDBProvider.initDatabase();
        Record rec = new Record(
          id: recordID,
          timestamp: timestamp,
          result: result,
          imageStream: imageStream
        );
        RecDBProvider.insertRecord(rec);
      });
      
      
    }).catchError((e){
      setState(() {
          _error = true;
          _isRecognizing = false;
      });
      if(e.runtimeType.toString() == 'DioError'){
        setState(() {
          if (e.type == DioErrorType.connectTimeout){
            errorMessage += 'Network Error: connection timeout\nPlease check your nework connection';
          }
          else if (e.response!=null){
            errorMessage = '''Recognition failed: server error ${e.response.statusCode.toString()}
(internal error)''';
          }
          else if (e.type == DioErrorType.other){
            errorMessage = "Connection to service failed\nPlease contact service admin";
          }
          else{
            errorMessage = e.toString();
          }
        });
      }
      else {
        setState(() {
          errorMessage = e.toString();
        });
      }
    });
    
  }


  // Image picker
  File _image = new File('none');
  final picker = ImagePicker();

  Future _selectImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null){
      File? croppedFile = await ImageProcessingProvider.imageCrop(pickedFile);
      // Cropped
      if (croppedFile != null) {
        setState(() {
          _image = File(croppedFile.path);
        });
      }
      // Not cropped
      else{
        setState(() {
          _image = File(pickedFile.path);
        });
      }
      // setState(() {
      //   _image = File(pickedFile.path);
      // });
      reset();
    } else {
      print('No image selected');
    }
  }


  @override
  void initState() {
    super.initState();
    _image = widget.image;
  }


  @override
  Widget build(BuildContext context) {

    MediaQueryData mediaQueryData = MediaQuery.of(context);
    double mediaHeight = mediaQueryData.size.height;
    double mediaWidth = mediaQueryData.size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: FloatingBackButton(),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              // Title: "Image Preview"
              Padding(
                padding: EdgeInsets.only(top: mediaHeight*0.05, bottom: 20.0),
                child: SizedBox(
                  width: mediaWidth*0.8,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      PoppinsTitleText('Image\nPreview', 30, Colors.grey.shade500, TextAlign.start),
                    ],
                  ),
                ),
              ),
              // Image preview
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: mediaWidth*0.8,
                  maxHeight: mediaHeight*0.4,
                  minHeight: 200,
                ),
                child: _image.path == 'none' ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [Text('Please select an image',
                      style: TextStyle(
                        color: Colors.amber,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        fontStyle: FontStyle.italic
                      ),
                    ),]
                  )
                : Image.file(_image)
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Button - Reselect
                  Padding(
                    padding: EdgeInsets.all(5),
                    child: IconButton(
                      onPressed: _selectImage,
                      icon: Icon(
                        Icons.image_outlined
                      )
                    ),
                  ),
                  // Button - Clear image
                  Padding(
                    padding: EdgeInsets.all(5),
                    child: IconButton(
                      onPressed: () { 
                        reset();
                        setState(() {
                          _image = File('none');
                        }); 
                      },
                      icon: Icon(
                        Icons.close
                      )
                    ),
                  )
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical:8.0),
                child: ElevatedButton(
                  onPressed: _image.path=='none'||_isRecognizing||_error ? null : _postToServer,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search,
                          size: 40,
                        ),
                        PoppinsTitleText('Recognize', 20, Colors.white, TextAlign.center),
                      ],
                    ),
                  ),
                  
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(_image.path=='none'||_isRecognizing||_error ? Colors.grey.shade400 : Colors.amber),
                  ),
                ),
              ),
              _sendProgress==0||_sendProgress==1 ? Container() : Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 20),
                child: Column(
                  children: [
                    Text('Image uploading:', style: TextStyle(color: Colors.grey),),
                    Padding(
                      padding: const EdgeInsets.only(top:8.0),
                      child: LinearProgressIndicator(
                        backgroundColor: Colors.grey,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.amber),
                        value: _sendProgress,
                      ),
                    ),
                  ],
                ),
              ),
              // Recognizing...
              _isRecognizing ? Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text("Recognizing...",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                  CupertinoActivityIndicator(
                    radius: 20,
                  )
                ],
              ) : Container(),
              Text(errorMessage,
              style: TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
              ),
              errorMessage=='' ? Container() : IconButton(onPressed: reset, icon: Icon(Icons.refresh))
            ],
          ),
        ),
      ),
    );
  }


}
