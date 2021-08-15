import 'package:capstone/data/record.dart';
import 'package:capstone/utils/device_info.dart';
import 'package:capstone/utils/sqlite_handler.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';

class SelectLocationPage extends StatefulWidget {

  final int recordID;

  const SelectLocationPage({ Key? key, required this.recordID}) : super(key: key);

  @override
  _SelectLocationPageState createState() => _SelectLocationPageState();
}

class _SelectLocationPageState extends State<SelectLocationPage> {

  LatLng tappedPoint = LatLng(0,0);
  bool selected = false;

  String baseURL = "http://172.16.13.81:5000";

  Future<LocationData> _getMyLocation() async{
    Location location = new Location();
    LocationData locationData = await location.getLocation();
    return locationData;
  }


  @override
  Widget build(BuildContext context) {

    StatelessWidget confirmButton = FloatingActionButton(
      onPressed: selected ? (){
        // Update local record in SQLite
        RecDBProvider.getRecordByID(widget.recordID).then((record){
          Record updated = record;
          updated.latitude = tappedPoint.latitude;
          updated.longitude = tappedPoint.longitude;
          RecDBProvider.updateRecord(updated).then((value){
            print('Record ${record.id} updated locally');
          }).onError((error, stackTrace){
            print(stackTrace.toString());
          });
        }).onError((error, stackTrace) {print(error.toString());});
        // Update record on server in MongoDB
        DeviceInfoProvider.gerDeviceInfo().then((deviceInfo){
          Dio().post(
          "$baseURL/update_location",
          data: {
            "record_id": "${deviceInfo}_${widget.recordID}",
            "location": {
              "latitude": tappedPoint.latitude,
              "longitude": tappedPoint.longitude,
            }
          }
        ).then((response){
          if (response.toString() == "updated"){
            print("Location updated on server for recognition record ${widget.recordID}");
          }
        }).onError((error, stackTrace) {print(error.toString());});
        });
        Navigator.of(context).pop();
      } : null,
      child: Icon(
        Icons.check,
        color: Colors.white,
      ),
      backgroundColor: selected?Colors.deepPurple:Colors.grey,
    );

    Marker tapped = Marker(
      width: 40,
      height: 40,
      point: LatLng(tappedPoint.latitude, tappedPoint.longitude),
      anchorPos: AnchorPos.align(AnchorAlign.top),
      builder: (ctx) =>
      Container(
        child: Image.asset(
          'assets/images/icons/pin_my_record.png',
          width: 40,
          height: 40,
        ),
      ),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: Text('Where did you find it?', style: TextStyle(fontFamily: 'Poppins'),),),
      floatingActionButton: confirmButton,
      body: Stack(
        children: [
          FutureBuilder(
            future: _getMyLocation(),
            builder: (context, AsyncSnapshot snapshot) {
              if (snapshot.hasError){
                return Text('Error');
              }
              if (snapshot.hasData){
                return FlutterMap(
                  options: MapOptions(
                    center: LatLng(snapshot.data.latitude, snapshot.data.longitude),
                    zoom: 14,
                    maxZoom: 18,
                    onTap: _saveLocation
                  ),
                  layers: [
                    TileLayerOptions(
                      urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                      subdomains: ['a', 'b', 'c']
                    ),
                    MarkerLayerOptions(
                      markers: selected?[tapped]:[],
                    )
                  ],
                );
              }
              return Center(child: Text('Map loading...'),);
            }
          )
        ],
      ),
    );
  }

  void _saveLocation(LatLng latlng) {
    setState(() {
      selected = true;
      tappedPoint = latlng;
    });
  }
}