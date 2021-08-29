import 'dart:convert';

import 'package:capstone/data/record.dart';
import 'package:capstone/utils/device_info.dart';
import 'package:capstone/utils/sqlite_handler.dart';
import 'package:capstone/widgets/text.dart';
import 'package:flutter/material.dart';

class MapInfoCard extends StatefulWidget {
  final Record record;
  final String globalID;
  const MapInfoCard({ Key? key, required this.globalID, required this.record }) : super(key: key);

  @override
  _MapInfoCardState createState() => _MapInfoCardState();
}

class _MapInfoCardState extends State<MapInfoCard> {
  
  String userString = '';
  
  @override
  void initState() {
    DeviceInfoProvider.getDeviceInfo().then((deviceInfo){
      setState(() {
        if (widget.globalID.split('_')[1] == deviceInfo.split('_')[1]) {
          userString = 'ME';
        } else {
          userString = 'USER_${widget.globalID.split('_')[1].split('-')[0]} (${widget.globalID.split('_')[0]})';
        }
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(widget.record.timestamp);
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      child: SizedBox(
        height: 350,
        width: MediaQuery.of(context).size.width,
        child: Column(
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
                            base64Decode(widget.record.imageStream),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                FutureBuilder(
                  future: RecDBProvider.checkIfRecognized(widget.record.result),
                  builder: (context, snapshot){
                    if(snapshot.hasData){
                      bool found = snapshot.data as bool;
                      if (!found) {
                        return Positioned(
                          top: 10,
                          left: 10,
                          child: Card(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 1.0, horizontal: 8.0),
                              child: Text(
                                'NEW',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                  color: Colors.deepPurple,
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
                                widget.record.result,
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
                            'latitude: ${widget.record.latitude}',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                            ),
                          ),
                          Text(
                            'longitude: ${widget.record.longitude}',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
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
                      // Text('Latitude: ${widget.record.longitude.toString()}'),
                      // Text('Longitude: ${widget.record.latitude.toString()}')
                    ],
                  ),
            ),
          ],
        ),
      ),
    );
  }
}