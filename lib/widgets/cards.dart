import 'dart:convert';
import 'dart:io';

import 'package:capstone/data/record.dart';
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
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      child: SizedBox(
        height: 400,
        width: MediaQuery.of(context).size.width,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: 350,
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
                crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Record ID: ${widget.record.id.toString()}'),
                      Text('Timestamp: ${DateTime.fromMillisecondsSinceEpoch(widget.record.timestamp).toString()}'),
                      Text('Result: ${widget.record.result}'),
                      Text('Latitude: ${widget.record.longitude.toString()}'),
                      Text('Longitude: ${widget.record.latitude.toString()}')
                    ],
                  ),
            ),
          ],
        ),
      ),
    );
  }
}