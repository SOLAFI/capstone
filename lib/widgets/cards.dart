import 'dart:convert';
import 'dart:io';

import 'package:capstone/data/record.dart';
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
  @override
  Widget build(BuildContext context) {
    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(widget.record.timestamp);
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      child: SizedBox(
        height: 300,
        width: MediaQuery.of(context).size.width,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: 300,
                  maxWidth: MediaQuery.of(context).size.width*0.45,
                ),
                child: Image.memory(
                  base64Decode(widget.record.imageStream),
                ),
              ),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width*0.4,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Text('Record ID: ${widget.record.id.toString()}'),
                      PoppinsTitleText(
                        widget.record.result,
                        20,
                        Colors.deepPurple,
                        TextAlign.center),
                        Text('\nFound at:'),
                        Text('${dateTime.year}-${dateTime.month}-${dateTime.day} ${dateTime.hour}:${dateTime.second}'),
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