import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

import 'pages/upload_image.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TBD',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Test Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  static const double DEFAULT_PADDING = 20;

  @override
  Widget build(BuildContext context) {

    MediaQueryData mediaQueryData = MediaQuery.of(context);
    double verticalPadding = mediaQueryData.size.height * 0.1;
    double horizontalPadding = mediaQueryData.size.width * 0.05;

    return Scaffold(
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: 10),
            child: FloatingActionButton(
              onPressed: null,
                child: Icon(Icons.person),
              ),
          ),
        ]
      ),
      body: Padding(
        padding: EdgeInsets.fromLTRB(horizontalPadding, verticalPadding, horizontalPadding, verticalPadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            // Card - fun fact
            Card(
              color: Colors.grey[200],
              shadowColor: Colors.grey,
              elevation: 10.0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
              child: SizedBox(
                width: mediaQueryData.size.width*0.9,
                height: mediaQueryData.size.height*0.2,
                child: FittedBox(
                  fit: BoxFit.none,
                  child: Text('Fun Fact')
                ),
              ),
            ),
            // Buttons - image source
            Padding(padding: EdgeInsets.only(top: DEFAULT_PADDING),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Upload image
                  GestureDetector(
                    onTap: _pushUploadImage,
                    child: Card(
                      color: Colors.orange[100],
                      shadowColor: Colors.grey,
                      elevation: 10.0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
                      child: SizedBox(
                        width: mediaQueryData.size.width*0.4,
                        height: mediaQueryData.size.height*0.3,
                        child: FittedBox(
                          fit: BoxFit.none,
                          child: Text('upload image')
                        ),
                      ),
                    ),
                  ),
                  // Take photo
                  GestureDetector(
                    onTap: _selectImage,
                    child: Card(
                      color: Colors.purple[100],
                      shadowColor: Colors.grey,
                      elevation: 10.0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
                      child: SizedBox(
                        width: mediaQueryData.size.width*0.4,
                        height: mediaQueryData.size.height*0.3,
                        child: FittedBox(
                          fit: BoxFit.none,
                          child: Text('take photo')
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Card - map
            Padding(
              padding: const EdgeInsets.only(top: DEFAULT_PADDING),
              child: Card(
                color: Colors.white,
                shadowColor: Colors.grey,
                elevation: 10.0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
                child: SizedBox(
                  width: mediaQueryData.size.width*0.9,
                  height: mediaQueryData.size.height*0.2,
                  child: FittedBox(
                    fit: BoxFit.none,
                    child: Text('Map')
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  File _image = new File('none');
  final picker = ImagePicker();
  Future _selectImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.camera);
    setState(() {
      if (pickedFile != null){
        _image = File(pickedFile.path);
        print(_image.path);
      } else {
        print('No image selected');
      }
    });
  }

  /// ********* Push page methods ***********

  void _pushUploadImage(){
    Navigator.of(context).push(
      new MaterialPageRoute(builder: (context) => new UploadImagePage())
    );
  }

}