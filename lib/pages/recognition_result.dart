import 'dart:async';

import 'package:capstone/widgets/text.dart';
import 'package:flutter/material.dart';
import 'package:animated_widgets/animated_widgets.dart';
import 'package:url_launcher/url_launcher.dart';

class PredictionResultPage extends StatefulWidget{
  PredictionResultPage({Key? key, required this.postResponse}) : super(key: key);

  final Map<String, dynamic> postResponse;

  @override
  _PredictionResultPageState createState() => _PredictionResultPageState();
}

class _PredictionResultPageState extends State<PredictionResultPage> {

  // Controller
  TextEditingController _issueController = TextEditingController();


  @override
  Widget build(BuildContext context) {

    MediaQueryData mediaQueryData = MediaQuery.of(context);
    double mediaHeight = mediaQueryData.size.height;
    double mediaWidth = mediaQueryData.size.width;

    Map result = widget.postResponse;
    String className = result['class_name'];
    String summary = result['summary'];
    String imageURL = result['image_url'];
    String pageURL = result['page_url'];
    String orderName = result['taxonomy']['order_name'];
    String familyName = result['taxonomy']['family_name'];
    String genusName = result['taxonomy']['genus_name'];
    String speciesName = result['taxonomy']['species_name'];

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
                PoppinsTitleText(className, 28, Colors.black, TextAlign.center),
                // Wiki infobox image
                Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: 500,
                      maxWidth: 400,
                    ),
                    child: Image.network(imageURL),
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
                )
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