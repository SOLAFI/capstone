import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import 'dart:core';
import 'dart:io';
import 'dart:convert';

import 'package:capstone/utils/sqlite_handler.dart';
import 'package:capstone/pages/recognition_result.dart';
import '../widgets/buttons.dart';
import '../widgets/text.dart';
import '../data/record.dart';



class ImagePreviewPage extends StatefulWidget {
  ImagePreviewPage({Key? key, required this.image}) : super(key: key);

  final File image;

  @override
  _ImagePreviewPageState createState() => _ImagePreviewPageState();
}

class _ImagePreviewPageState extends State<ImagePreviewPage> {

  Map<String, dynamic> postResponse = new Map();

  bool _isRecognizing = false;
  double _sendProgress = 0;
  bool _invalidImage = false;
  int recCount = 0;


  Future<void> getRecordsCount() async{
    recCount = await RecDBProvider.recordsCount();
  }


  // POST request
  void _postToServer() async {

    setState(() {
      _isRecognizing = true;
    });

    FormData formData = FormData.fromMap({
      "file": await MultipartFile.fromFile(_image.path, filename: _image.path.split('/').last),
    });

    try {
      var response = await Dio().post(
        "http://172.16.13.81:5000/recognize",
        data: formData,
        onSendProgress: (int current, int total) {setState(() {
          _sendProgress = current/total;
        });}
      );
      setState(() {
        _isRecognizing = false;
        _sendProgress = 0;
      });
      // print(response.toString());
      String result = '';
      if(response.toString()=="invalid image"){
        _isRecognizing = true;  // Only to disable the recognize button, not really recognizing
        _invalidImage = true;
        result = response.toString();
      }
      else{
        postResponse = JsonCodec().decode(response.toString());
        showModalBottomSheet(context: context, builder: (context) => PredictionResultPage(postResponse: postResponse));
        result = postResponse['class_name'];
      }
      /*
          Insert a record to SQLite DB
       */
      RecDBProvider.initDatabase();
      String uploadedImage = _image.path;
      double latitude = 0;
      double longitude = 0;
      int timestamp = DateTime.now().millisecondsSinceEpoch;
      Record rec = new Record(
        id: recCount+1,
        timestamp: timestamp,
        imageURL: uploadedImage,
        result: result,
        latitude: latitude,
        longitude: longitude,
      );
      RecDBProvider.insertRecord(rec);
    } catch (e) {
      print(e);
    }
  }


  // Image picker
  File _image = new File('none');
  final picker = ImagePicker();
  Future _selectImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null){
        _image = File(pickedFile.path);
        _isRecognizing = false;
        _invalidImage = false;
      } else {
        print('No image selected');
      }
    });
  }


  @override
  void initState() {
    super.initState();
    _image = widget.image;
    _isRecognizing = false;
    _sendProgress = 0;
    _invalidImage = false;
    //RecDBProvider.deleteRecDB();
    getRecordsCount();
    print('Current number of records: $recCount');
  }


  @override
  Widget build(BuildContext context) {

    MediaQueryData mediaQueryData = MediaQuery.of(context);
    double mediaHeight = mediaQueryData.size.height;
    double mediaWidth = mediaQueryData.size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: FloatingBackButton(),
      body: Center(
        child: SizedBox(
          height:mediaHeight*0.9,
          width: mediaWidth*0.8,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              // Title: "Image Preview"
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20.0),
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
                        setState(() {
                          _image = File('none');
                          _isRecognizing = false;
                          _sendProgress = 0;
                          _invalidImage = false;
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
                  onPressed: _image.path=='none'||_isRecognizing ? null : _postToServer,
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
                    backgroundColor: MaterialStateProperty.all<Color>(_image.path=='none'||_isRecognizing ? Colors.grey.shade400 : Colors.amber),
                  ),
                ),
              ),
              _sendProgress==0||_sendProgress==1 ? Container() : Padding(
                padding: const EdgeInsets.only(top:8.0),
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
              _isRecognizing && _sendProgress==1 ? Column(
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
              _invalidImage?
              Text('Recognition failed :(\nIs this an image of a bird?',
              style: TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
              ):Container()
            ],
          ),
        ),
      ),
    );
  }


}
