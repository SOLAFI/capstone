import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:capstone/pages/select_location.dart';
import 'package:capstone/widgets/text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:animated_widgets/animated_widgets.dart';
import 'package:url_launcher/url_launcher.dart';

class PredictionResultPage extends StatefulWidget{
  PredictionResultPage({Key? key, required this.result, required this.recordID}) : super(key: key);

  final String result;
  final int recordID;

  @override
  _PredictionResultPageState createState() => _PredictionResultPageState();
}

class _PredictionResultPageState extends State<PredictionResultPage> {

  // Controller
  TextEditingController _issueController = TextEditingController();
  
  // Wiki values
  late String summary;
  late String imageURL;
  late String pageURL;
  late String orderName;
  late String familyName;
  late String genusName;
  late String speciesName;
  bool dioError = false;

  String baseURL = "http://172.16.13.81:5000";

  Future<String> _getWikiInfo(String className) async {
    className = className.substring(1,className.length-1);
    print(className);
    var response = await Dio().post(
      "$baseURL/wiki",
      data: {
        "class_name": className
      },
    ).catchError((error){
      setState(() {
        dioError = true;
      });
    });
    Map wikiInfo = JsonCodec().decode(response.toString());
    // setState(() {
      summary = wikiInfo['summary'];
      imageURL = wikiInfo['image_url'];
      pageURL = wikiInfo['page_url'];
      orderName = wikiInfo['taxonomy']['order_name'];
      familyName = wikiInfo['taxonomy']['family_name'];
      genusName = wikiInfo['taxonomy']['genus_name'];
      speciesName = wikiInfo['taxonomy']['species_name'];
    // });
    return 'success';
  }


  @override
  Widget build(BuildContext context) {

    MediaQueryData mediaQueryData = MediaQuery.of(context);
    double mediaHeight = mediaQueryData.size.height;
    double mediaWidth = mediaQueryData.size.width;

    String result = widget.result;

    Color reportIssueColor = Colors.grey;

    return Card(
      shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      child: SizedBox(
        width: mediaWidth,
        height: mediaHeight*0.82,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                // Title label
                PoppinsTitleText('Result:', 20, Colors.grey, TextAlign.center),
                // Class name
                PoppinsTitleText(result, 28, Colors.black, TextAlign.center),
                // From Wiki
                FutureBuilder(
                  future: _getWikiInfo(result),
                  builder: (context, snapshot){
                    if (dioError){
                      return Text('Wiki failed to load');
                    }
                    if (snapshot.hasData){
                      if(snapshot.data.toString() == 'success'){
                        return Column(
                          children: [
                            // Wiki infobox image
                            Padding(
                              padding: const EdgeInsets.only(bottom: 10.0),
                              child: Stack(
                                children: [
                                  ConstrainedBox(
                                    constraints: BoxConstraints(
                                      maxHeight: 500,
                                      maxWidth: 400,
                                    ),
                                    child: FadeInImage(
                                      image: NetworkImage(imageURL),
                                      placeholder: AssetImage('assets/images/image_placeholder.png'),
                                    ),
                                  ),
                                  Positioned(
                                    right: 0,
                                    child: GestureDetector(
                                      onTap: (){
                                        Navigator.of(context).push(MaterialPageRoute(
                                          builder: (context) => SelectLocationPage(recordID: widget.recordID)
                                        ));
                                      },
                                      child: Card(
                                        color: Colors.white70,
                                        elevation: 2,
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Image.asset(
                                                'assets/images/icons/pin.png',
                                                width: 18,
                                                height: 18,
                                              ),
                                              Text(
                                                ' Pin this bird on map',
                                                style: TextStyle(
                                                  color: Colors.deepPurple,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Feedback
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                GestureDetector(
                                  onTap: (){
                                    _reportDialog(context);
                                  },
                                  child: Row(
                                    children: [
                                      Text(
                                        'Report an issue',
                                        style: TextStyle(
                                          color: reportIssueColor,
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(5, 0, 10, 5),
                                        child: Icon(
                                          Icons.feedback,
                                          color: reportIssueColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                ThumbUpWidget(),
                              ],
                            ),
                            // Class details
                            Padding(
                              padding: const EdgeInsets.only(top:8.0),
                              child: Card(
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
                                elevation: 5,
                                child: Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          PoppinsTitleText('Order: ', 16, Colors.grey.shade500, TextAlign.start),
                                          Text(orderName)
                                        ],
                                      ),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          PoppinsTitleText('Family: ', 16, Colors.grey.shade600, TextAlign.start),
                                          Text(familyName)
                                        ],
                                      ),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          PoppinsTitleText('Genus: ', 16, Colors.grey.shade700, TextAlign.start),
                                          Text(genusName)
                                        ],
                                      ),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          PoppinsTitleText('Species: ', 16, Colors.grey.shade800, TextAlign.start),
                                          Text(speciesName)
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            // Title - Summary
                            Padding(
                              padding: const EdgeInsets.only(top: 20.0),
                              child: PoppinsTitleText('Summary', 24, Colors.black, TextAlign.center),
                            ),
                            // Summary text
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10.0),
                              child: Text(summary,
                              textAlign: TextAlign.justify,),
                            ),
                            // Link to wiki
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10.0),
                              child: Column(
                                children: [
                                  Text("\nSee full wiki page at:"),
                                  GestureDetector(
                                    onTap: (){
                                      _launchURL(pageURL);
                                    },
                                    child: Text(pageURL,
                                      style: TextStyle(
                                        color: Theme.of(context).primaryColor,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ],
                        );
                      }
                      else{
                        return Text('error: get wiki failed');
                      }
                    }
                    return SizedBox(
                      height: 200,
                      width: MediaQuery.of(context).size.width,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          CupertinoActivityIndicator(radius: 35,),
                          Text('Loading Wikipedia data...'),
                        ],
                      )
                    );
                  }
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _launchURL(String url) async {
    await canLaunch(url) ? launch(url, forceWebView: true) : throw 'Could not launch $url';
  }


  _reportDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Report an Issue'),
          content: TextField(
            controller: _issueController,
            textInputAction: TextInputAction.go,
            decoration: InputDecoration(hintText: 'Enter your feedback'),
          ),
          actions: [
            RawMaterialButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.of(context).pop()
            ),
            RawMaterialButton(
              child: Text('Submit'),
              onPressed: () => Navigator.of(context).pop()
            ),
          ],
        );
      }
    );
  }

}

class ThumbUpWidget extends StatefulWidget {
  const ThumbUpWidget({ Key? key }) : super(key: key);

  @override
  _ThumbUpWidgetState createState() => _ThumbUpWidgetState();
}

class _ThumbUpWidgetState extends State<ThumbUpWidget> {

  bool thumbUp = false;
  bool shake = false;
  Color activated = Colors.amber.shade700;
  Color deactivated = Colors.orange.shade100;


  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        setState(() {
          thumbUp = !thumbUp;
          if (thumbUp){
            shake = true;
            Timer(Duration(milliseconds: 500), (){
              setState(() {
                shake = false;
              });
            });
          }
          else{
            shake = false;
          }
        });
      },
      child: Row(
        children: [
          Text(
            'Helpful?',
            style: TextStyle(
              color: thumbUp ? activated : deactivated,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(5, 0, 10, 5),
            child: ShakeAnimatedWidget(
              enabled: shake,
              duration: Duration(milliseconds: 500),
              shakeAngle: Rotation.deg(z: 30),
              curve: Curves.easeIn,
              child: Icon(
                Icons.thumb_up,
                color: thumbUp ? activated : deactivated,
              ),
            ),
          ),
        ],
      ),
    );
  }
}