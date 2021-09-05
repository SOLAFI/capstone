import 'dart:convert';

import 'package:capstone/utils/device_info.dart';
import 'package:capstone/utils/sqlite_handler.dart';
import 'package:capstone/widgets/text.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../constants.dart';

class MapInfoCard extends StatefulWidget {
  final String ID;
  const MapInfoCard({ Key? key, required this.ID }) : super(key: key);

  @override
  _MapInfoCardState createState() => _MapInfoCardState();
}

class _MapInfoCardState extends State<MapInfoCard> {
  
  String userString = '';
  
  @override
  void initState() {
    DeviceInfoProvider.getDeviceInfo().then((deviceInfo){
      setState(() {
        if (widget.ID.split('_')[1] == deviceInfo.split('_')[1]) {
          userString = 'ME';
        } else {
          userString = 'USER_${widget.ID.split('_')[1].split('-')[0]} (${widget.ID.split('_')[0]})';
        }
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      child: SizedBox(
        height: 350,
        width: MediaQuery.of(context).size.width,
        child: FutureBuilder(
          future: getRecordDetail(widget.ID),
          builder: (context, snapshot){ 
            if (snapshot.hasData) {
            Map recordData = snapshot.data as Map;
            String imageStream = recordData['image_stream'];
            String result = recordData['result'];
            DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(int.parse(recordData['timestamp']));
            double latitude = recordData['location']['latitude'];
            double longitude = recordData['location']['longitude'];
            String pageURL = "https://en.wikipedia.org/wiki/${result.replaceAll(" ", "_")}";
            return Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Stack(
                  children: [
                    Align(
                      alignment: Alignment.center,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10.0, bottom: 8, right: 10.0, top: 15),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxHeight: 170,
                            maxWidth: MediaQuery.of(context).size.width*0.7,
                          ),
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(Radius.circular(10)),
                            ),
                            elevation: 5,
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(width: 10, color: Colors.grey.shade100),
                                borderRadius: BorderRadius.all(Radius.circular(10)),
                              ),
                              child: Image.memory(
                                base64Decode(imageStream),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    FutureBuilder(
                      future: RecDBProvider.checkIfRecognized(result),
                      builder: (context, snapshot){
                        if(snapshot.hasData){
                          bool found = snapshot.data as bool;
                          if (!found) {
                            return Positioned(
                              bottom: 0,
                              left: 10,
                              child: Card(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 1.0, horizontal: 8.0),
                                  child: Text(
                                    'NEW SPECIES',
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontWeight: FontWeight.w700,
                                      fontSize: 16,
                                      // color: Colors.deepPurple,
                                      foreground: Paint()..shader = LinearGradient(
                                        colors: [Colors.amber, Colors.deepPurple]
                                      ).createShader(Rect.fromLTRB(0, 0, 120, 10)),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }
                          return Container();
                        }
                        return Container();
                      }
                    )
                  ],
                ),
                SizedBox(
                  height: 150,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SizedBox(
                                  width: MediaQuery.of(context).size.width*0.4,
                                  child: PoppinsTitleText(
                                    result,
                                    20,
                                    Colors.black,
                                    TextAlign.start),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Row(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(2.0),
                                          child: Icon(
                                            Icons.camera,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        Text(
                                          'uploaded at:',
                                          style: TextStyle(
                                            color: Colors.black,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      '${dateTime.year}-${dateTime.month}-${dateTime.day} ${dateTime.hour}:${dateTime.second}',
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 14,
                                        color: Colors.deepPurple
                                      ),
                                    )
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Column(
                            children: [
                              Text(
                                'latitude: $latitude',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              Text(
                                'longitude: $longitude',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                          GestureDetector(
                            onTap: (){
                              _launchURL(pageURL);
                            },
                            child: Text(
                              pageURL,
                              style: TextStyle(
                                color: Theme.of(context).primaryColor,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 20.0, bottom: 5),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  'by: $userString',
                                  style: TextStyle(
                                    color: Colors.grey.shade400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                  ),
                ],
              );
            }
            return Center(
              child: Text(
                'Loading...'
              ),
            );
          }
        )
      ),
    );
  }

  Future<Map> getRecordDetail(String ID) async {
    Response response = await Dio().get(
      MAP_RECORD_DETAIL_REQUEST,
      queryParameters: {'ID': ID},
    ).catchError((e){
      print(e.toString());
    });
    Map record = JsonCodec().decode(response.data);
    return record;
  }

  void _launchURL(String url) async {
    await canLaunch(url) ? launch(url, forceWebView: true) : throw 'Could not launch $url';
  }

}