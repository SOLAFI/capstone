import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import 'dart:io';
import 'dart:convert';

import '../widgets/buttons.dart';
import '../widgets/text.dart';



class ImagePreviewPage extends StatefulWidget {
  ImagePreviewPage({Key? key, required this.image}) : super(key: key);

  final File image;

  @override
  _ImagePreviewPageState createState() => _ImagePreviewPageState();
}

class _ImagePreviewPageState extends State<ImagePreviewPage> {


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
      // appBar: AppBar(
      // ),
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
                      PoppinsTitleText('Image\nPreview', 30, Colors.grey.shade500),
                    ],
                  ),
                ),
              ),
              // Image preview
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: mediaWidth*0.8,
                  maxHeight: mediaHeight*0.5,
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
                  Padding(
                    padding: EdgeInsets.all(5),
                    child: IconButton(
                      onPressed: _selectImage,
                      icon: Icon(
                        Icons.image_outlined
                      )
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(5),
                    child: IconButton(
                      onPressed: () { 
                        setState(() {
                          _image = File('none');
                          predictionResult = '';
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
                padding: const EdgeInsets.only(top:10.0),
                child: ElevatedButton(
                  onPressed: _image.path=='none' ? null : _postToServer,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search,
                          size: 40,
                        ),
                        PoppinsTitleText('Recognize', 20, Colors.white),
                      ],
                    ),
                  ),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(_image.path=='none' ? Colors.grey.shade400 : Colors.amber),
                  ),
                ),
              ),
              // Response
              Text(
                '$predictionResult'
              ),
            ],
          ),
        ),
      ),
    );
  }


}
