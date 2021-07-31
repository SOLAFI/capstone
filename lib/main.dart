import 'package:capstone/pages/map.dart';
import 'package:capstone/pages/user.dart';
import 'package:capstone/utils/sqlite_handler.dart';
import 'pages/image_preview.dart';

import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:location/location.dart';

import 'widgets/text.dart';

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
        canvasColor: Colors.transparent,
        primarySwatch: Colors.deepPurple,
      ),
      home: MyHomePage(title: 'Test Home Page'),
      routes: {
        '/user': (context) => UserPage(),
      },
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

  String funFactText = '''There are around 10,000 different species of bird. They range from big to small, and are lots of different colours!
How many different birds can you spot?''';

  @override
  void initState() {
    super.initState();
    _initLocationService();
    // RecDBProvider.deleteRecDB();
    RecDBProvider.recordsCount().then((value) => print('Number of records: $value'));
  }


    // Image picker
  File _image = new File('none');
  final picker = ImagePicker();
  Future _selectImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null){
        _image = File(pickedFile.path);
        _pushImagePreviewPage();
      } else {
        print('No image selected');
      }
    });
  }

  Future _takePhoto() async {
    final cameraFile = await ImagePicker().pickImage(source: ImageSource.camera);
    setState(() {
      if (cameraFile != null){
        _image = File(cameraFile.path);
        _pushImagePreviewPage();
      } else {
        print('No image selected');
      }
    });
  }

  Future<void> _initLocationService() async{
    Location location = new Location();
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;
    LocationData _locationData;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        print('Error when enabling service');
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        print('Error when granting permission');
      }
    }
    _locationData = await location.getLocation();
    print(_locationData);
  }

  @override
  Widget build(BuildContext context) {
    MediaQueryData mediaQueryData = MediaQuery.of(context);
    double verticalPadding = mediaQueryData.size.height * 0.1;
    double horizontalPadding = mediaQueryData.size.width * 0.05;

    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton:
        Column(mainAxisAlignment: MainAxisAlignment.end, children: [
          Padding(
            padding: EdgeInsets.only(bottom: 10),
            child: FloatingActionButton(
              onPressed: (){
                Navigator.of(context).pushNamed('/user');
              },
              child: Icon(Icons.person),
            ),
          ),
        ]
      ),
      body: Padding(
        padding: EdgeInsets.fromLTRB(horizontalPadding, verticalPadding,
            horizontalPadding, verticalPadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            // Card - fun fact
            Card(
              color: Colors.white,
              shadowColor: Colors.grey,
              elevation: 5.0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10))),
              child: SizedBox(
                width: mediaQueryData.size.width * 0.9,
                height: mediaQueryData.size.height * 0.2,
                child: Stack(
                  children: [
                    Positioned(
                      child: Image.asset('assets/images/bird.png'),
                      right: -30,
                    ),
                    SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Do you know that...',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w700,
                                fontSize: 20,
                                foreground: Paint()..shader = LinearGradient(
                                    colors: [Colors.amber.shade300, Colors.deepPurple.shade400]
                                  ).createShader(Rect.fromLTRB(0, 0, 200, 70)),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                funFactText,
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                )
              ),
            ),
            // Buttons - image source
            Padding(
              padding: EdgeInsets.only(top: DEFAULT_PADDING),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Upload image
                  GestureDetector(
                    onTap: _selectImage,
                    child: Card(
                      color: Colors.amber,
                      shadowColor: Colors.grey,
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10))),
                      child: SizedBox(
                        width: mediaQueryData.size.width * 0.4,
                        height: mediaQueryData.size.height * 0.3,
                        child: Stack(
                          children: [
                            Positioned(
                              child: Icon(
                                Icons.image,
                                size: 150,
                                color: Colors.amber[100],
                              ),
                              right: 0,
                              bottom: 0,
                            ),
                            Positioned(
                              child: PoppinsTitleText('Upload\nImage', 30, Colors.white, TextAlign.start),
                              width: 150,
                              left: 15,
                              top: 15,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Take photo
                  GestureDetector(
                    onTap: _takePhoto,
                    child: Card(
                      color: Colors.purple[400],
                      shadowColor: Colors.grey,
                      elevation: 5.0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10))),
                      child: SizedBox(
                        width: mediaQueryData.size.width * 0.4,
                        height: mediaQueryData.size.height * 0.3,
                        child: Stack(
                          children: [
                            Positioned(
                              child: Icon(
                                Icons.camera_enhance,
                                size: 150,
                                color: Colors.purple[100],
                              ),
                              right: 0,
                              bottom: 0,
                            ),
                            Positioned(
                              child: PoppinsTitleText('Take\nPhoto', 30, Colors.white, TextAlign.start),
                              width: 150,
                              left: 15,
                              top: 15,
                            ),
                          ],
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
              child: GestureDetector(
                onTap: (){
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => MapPage()));
                },
                child: Card(
                  color: Colors.grey.shade50,
                  shadowColor: Colors.grey,
                  elevation: 5.0,
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                  child: Stack(
                    children: [
                      SizedBox(
                        width: mediaQueryData.size.width * 0.9,
                        height: mediaQueryData.size.height * 0.2,
                        child: Image.asset(
                          'assets/images/map.jpeg',
                          fit: BoxFit.cover,
                        ),
                      ),
                      SizedBox(
                        width: mediaQueryData.size.width * 0.9,
                        height: mediaQueryData.size.height * 0.2,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.transparent,
                                Colors.black12,
                              ],
                              begin: Alignment.center,
                              end: Alignment.bottomLeft,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        child: PoppinsTitleText('Map', 30, Colors.white, TextAlign.start),
                        bottom: 15,
                        left: 15,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  /// ********* Push page methods ***********

  void _pushImagePreviewPage() {
    Navigator.of(context).push(
        new MaterialPageRoute(builder: (context) => new ImagePreviewPage(image: _image,)));
  }
}
