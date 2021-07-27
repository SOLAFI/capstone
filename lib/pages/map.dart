import 'package:capstone/data/record.dart';
import 'package:capstone/utils/sqlite_handler.dart';
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
    List<Record> records = [];

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
              return FlutterMap(
                        options: MapOptions(
                          center: LatLng(
                            snapshot.data.latitude,
                            snapshot.data.longitude,
                          ),
                          zoom: 13,
                        ),
                        layers: [
                          TileLayerOptions(
                            urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                            subdomains: ['a', 'b', 'c']
                          ),
                          MarkerLayerOptions(
                            markers: [
                              Marker(
                                width: 80.0,
                                height: 80.0,
                                point: LatLng(snapshot.data.latitude, snapshot.data.longitude),
                                builder: (ctx) =>
                                Container(
                                  child: 
                                      Icon(Icons.pin_drop,size: 30,color: Colors.deepPurple,),
                                ),
                              ),
                            ],
                          )
                        ],
                      );
              // return Container(
              //   height: 500,
              //   child: Column(
              //     mainAxisAlignment: MainAxisAlignment.center,
              //     children: [
              //       SizedBox(
              //         width: MediaQuery.of(context).size.width,
              //         height: 50,
              //         child: Text(snapshot.data.toString())
              //       ),
              //       Container(
              //         height: 200,
              //         width: MediaQuery.of(context).size.width,
              //         child: FutureBuilder(
              //           future: getRecords(),
              //           builder:(context, AsyncSnapshot<List<Record>> snapshot) {
              //             if (snapshot.hasData){
              //               records = snapshot.data as List<Record>;
              //               return ListView.builder(
              //                 itemCount: records.length,
              //                 itemBuilder: (context, index){
              //                   return Card(
              //                     child: ListTile(
              //                       title: Text(records[index].toString()),
              //                     ),
              //                   );
              //                 }
              //               );
              //             }
              //             else {
              //               return Center(child: Text('No record found'));
              //             }
              //           },
              //         ),
              //       ),
              //     ],
              //   ),
              // );
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
}


