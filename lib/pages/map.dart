import 'dart:io';

import 'package:capstone/data/record.dart';
import 'package:capstone/utils/sqlite_handler.dart';
import 'package:capstone/widgets/cards.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import '../widgets/buttons.dart';
import 'package:flutter/material.dart';

class MapPage extends StatefulWidget{

  MapPage({Key? key}) : super(key: key);

  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage>{

  List<Marker> markers = [];
  AnchorPos anchorPos = AnchorPos.align(AnchorAlign.top);

  StatelessWidget backButton = FloatingBackButton();

  @override
  void initState() {
    super.initState();
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
      floatingActionButton: backButton,
      body: Center(
        child: FutureBuilder(
          future: getRecords(),
          builder: (context, snapshot){
            if (snapshot.hasData) {
              List records = snapshot.data as List<Record>;
              if(records.length!=0){
                for(int i=0; i<records.length; i++){
                  // print(records[i].toString());
                  if (records[i].latitude!=0 && records[i].longitude!=0) {
                    markers.add(Marker(
                      height: 70,
                      width: 70,
                      point: LatLng(records[i].latitude, records[i].longitude),
                      builder: (ctx) => GestureDetector(
                        onTap: (){
                          showBottomSheet(context: context, builder: (context){
                            return MapInfoCard(record: records[i]);
                          });
                          setState(() {
                            backButton = FloatingActionButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                                setState(() {
                                  backButton = FloatingBackButton();
                                });
                              },
                              child: Icon(
                                Icons.close,
                                color: Colors.white,
                              ),
                              backgroundColor: Colors.grey,
                            );
                          });
                        },
                        child: Card(
                                color: Colors.deepPurple.shade200,
                                child: Padding(
                                  padding: const EdgeInsets.all(5.0),
                                  child: Image.file(
                                    File(records[i].imageURL),
                                    width: 65,
                                    height: 65,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                      )
                      )
                    );
                  }
                }
                if (markers.length==0){
                  print('Records: no valid record');
                }
              }
              else{
                print('MAP: no records to display');
              }
              return FutureBuilder(
                future: _getMyLocation(),
                builder: (context, AsyncSnapshot snapshot) {
                  if(snapshot.hasError){
                    return Text('error');
                  }
                  if(snapshot.hasData){
                    Marker currentLocation = Marker(
                      width: 40,
                      height: 40,
                      point: LatLng(snapshot.data.latitude, snapshot.data.longitude),
                      anchorPos: anchorPos,
                      builder: (ctx) =>
                      Container(
                        child: Image.asset(
                          'assets/images/icons/pin.png',
                          width: 40,
                          height: 40,
                        ),
                      ),
                    );
                    markers.add(currentLocation);
                        
                    return FlutterMap(
                              options: MapOptions(
                                center: LatLng(
                                  snapshot.data.latitude,
                                  snapshot.data.longitude,
                                ),
                                zoom: 14,
                                maxZoom: 18,
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
                  return SizedBox(
                    height: 150,
                    width: 150,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        CupertinoActivityIndicator(radius: 40,),
                        Text('Map loading...'),
                      ],
                    )
                  );
                },
              );
            }
            return Text('Loading...');
          }
        ),
      ),
    );
  }

  Future<List<Record>> getRecords() async {
    return RecDBProvider.records();
  }

}

