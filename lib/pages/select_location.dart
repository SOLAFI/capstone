import 'package:capstone/data/record.dart';
import 'package:capstone/utils/sqlite_handler.dart';
import 'package:capstone/widgets/buttons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';

class SelectLocationPage extends StatefulWidget {

  final int recordID;

  const SelectLocationPage({ Key? key, required this.recordID }) : super(key: key);

  @override
  _SelectLocationPageState createState() => _SelectLocationPageState();
}

class _SelectLocationPageState extends State<SelectLocationPage> {

  LatLng tappedPoint = LatLng(0,0);

  Future<LocationData> _getMyLocation() async{
    Location location = new Location();
    LocationData locationData = await location.getLocation();
    return locationData;
  }

  @override
  Widget build(BuildContext context) {

    StatelessWidget confirmButton = FloatingActionButton(
      onPressed: (){
        Navigator.of(context).pop();
        RecDBProvider.getRecordByID(widget.recordID).then((record){
          Record updated = Record(
            id: record.id,
            imageURL: record.imageURL,
            timestamp: record.timestamp,
            result: record.result,
            latitude: tappedPoint.latitude,
            longitude: tappedPoint.longitude);
          RecDBProvider.updateRecord(updated).then((value){
            print('Record ${record.id} updated');
          }).onError((error, stackTrace){
            print(error.toString());
          });
        }).onError((error, stackTrace) {print(error.toString());});
      },
      child: Icon(
        Icons.check,
        color: Colors.white,
      ),
      backgroundColor: Colors.deepPurple,
    );

    Marker tapped = Marker(
      width: 40,
      height: 40,
      point: LatLng(tappedPoint.latitude, tappedPoint.longitude),
      anchorPos: AnchorPos.align(AnchorAlign.top),
      builder: (ctx) =>
      Container(
        child: Image.asset(
          'assets/images/icons/pin.png',
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
                      markers: [tapped],
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
      tappedPoint = latlng;
    });
  }
}