import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import 'dart:io';
import 'dart:convert';

import '../widgets/buttons.dart';



class UploadImagePage extends StatefulWidget {
  UploadImagePage({Key? key}) : super(key: key);

  @override
  _UploadImagePageState createState() => _UploadImagePageState();
}

class _UploadImagePageState extends State<UploadImagePage> {

  static const double DEFAULT_PADDING = 20;

  Map<String, dynamic> postResponse = new Map();
  String predictionResult = '';


  // POST request
  void _postToServer() async {

    FormData formData = FormData.fromMap({
      "file": await MultipartFile.fromFile(_image.path, filename: _image.path.split('/').last),
    });

    try {
      var response = await Dio().post(
        "http://172.16.13.81:5000/recognize",
        data: formData,
        onSendProgress: (int current, int total) {print('----Uploading: ${current/total}');}
        );
      setState(() {
        postResponse = JsonCodec().decode(response.toString());
        predictionResult = postResponse['class_name'];
      });
    } catch (e) {
      print(e);
    }
  }


  // Image picker
  File _image = new File('none');
  final picker = ImagePicker();
  Future _selectImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null){
        _image = File(pickedFile.path);
        predictionResult = '';
      } else {
        print('No image selected');
      }
    });
  }

  @override
  Widget build(BuildContext context) {

    MediaQueryData mediaQueryData = MediaQuery.of(context);

    return Scaffold(
      // appBar: AppBar(
      // ),
      floatingActionButton: FloatingBackButton(),
      body: Center(
        child: Container(
          height: mediaQueryData.size.height*0.6,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              // Image preview
              Padding(
                padding: const EdgeInsets.all(DEFAULT_PADDING),
                child: Container(
                  height: mediaQueryData.size.width*0.5,
                  width: mediaQueryData.size.width*0.5,
                  color: Colors.grey[200],
                  child: FittedBox(
                    fit: BoxFit.contain,
                    child: _image.path == 'none' ? Padding(
                      padding: const EdgeInsets.all(DEFAULT_PADDING),
                      child: Text('Please select an image', style: TextStyle(color: Colors.grey[500]),),
                    ) : Image.file(_image),
                  ),
                ),
              ),
              // Buttons
              Container(
                height: mediaQueryData.size.height*0.25,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    // Guide
                    Text(
                      'Upload an image to recognize',
                    ),
                    // Buttons - select and clear image
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Button - select
                          ElevatedButton(
                            onPressed: _selectImage,
                            child: Text('Select an image'),
                          ),
                          // Button - clear
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: ElevatedButton(
                              onPressed: () { setState(() {
                                _image = File('none');
                                predictionResult = '';
                              }); },
                              child: Text('Clear image'),
                              ),
                          )
                        ],
                      ),
                    ),
                    // Button - recognize
                    Padding(
                      padding: const EdgeInsets.only(top: DEFAULT_PADDING),
                      child: ElevatedButton(
                        onPressed: _postToServer,
                        child: Text('Recognize'),
                      ),
                    ),
                    // Response
                    Text(
                      '$predictionResult'
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


}
