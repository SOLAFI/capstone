import 'dart:io';

import 'package:capstone/data/record.dart';
import 'package:capstone/utils/sqlite_handler.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import '../widgets/buttons.dart';
import 'package:flutter/material.dart';
import 'package:speech_bubble/speech_bubble.dart';

class MapPage extends StatefulWidget{

  MapPage({Key? key}) : super(key: key);

  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage>{

  List<Marker> markers = [];


  @override
  void initState() {
    super.initState();
    getRecords().then((records){
      if(records.length!=0){
        for(int i=0; i<records.length; i++){
          Marker marker = imageMarker(records[i].latitude, records[i].latitude,
            Image.file(File(records[i].imageURL), width: 28, height: 28, fit: BoxFit.cover,)
          );
          markers.add(marker);
        }
      }
      else{
        print('MAP: no records to display');
      }
      
    });
  }

  Future<LocationData> _getMyLocation() async{
    Location location = new Location();
    LocationData locationData = await location.getLocation();
    return locationData;
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: FloatingBackButton(),
      body: Center(
        child: FutureBuilder(
          future: _getMyLocation(),
          builder: (context, AsyncSnapshot snapshot) {
            if(snapshot.hasError){
              return Text('error');
            }
            if(snapshot.hasData){
              Marker currentLocation = Marker(
                width: 30,
                height: 30,
                point: LatLng(snapshot.data.latitude, snapshot.data.longitude),
                builder: (ctx) =>
                Container(
                  child: Icon(Icons.pin_drop, color: Colors.amber.shade600, size: 30,),
                ),
              );
              markers.add(currentLocation);
              return FlutterMap(
                        options: MapOptions(
                          center: LatLng(
                            snapshot.data.latitude,
                            snapshot.data.longitude,
                          ),
                          zoom: 15,
                        ),
                        layers: [
                          TileLayerOptions(
                            urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                            subdomains: ['a', 'b', 'c']
                          ),
                          MarkerLayerOptions(
                            markers: markers,
                          )
                        ],
                      );
            }
            return Text('Loading...');
          },
        ),
      ),
    );
  }

  Future<List<Record>> getRecords() async {
    return RecDBProvider.records();
  }

  Marker imageMarker(double lat, double lng, Image image){
    return Marker(
      height: 80,
      width: 50,
      point: LatLng(lat, lng),
      builder: (ctx) =>
      Stack(
        children:[ 
          Positioned(
            top: 0,
            left: 0,
            child: SpeechBubble(
              nipLocation: NipLocation.BOTTOM,
              nipHeight: 10,
              color: Colors.deepPurple,
              child: Container(
                height: 30,
                width: 30,
                child: image,
              ),
            ),
          ),
        ]
      ),
    );
  }
}

