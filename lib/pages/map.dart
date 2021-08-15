import 'dart:convert';

import 'package:capstone/data/record.dart';
import 'package:capstone/utils/device_info.dart';
import 'package:capstone/widgets/cards.dart';
import 'package:dio/dio.dart';
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
              List records = snapshot.data as List;
              if(records.length!=0){
                for(int i=0; i<records.length; i++){
                  double latitude = records[i]['location']['latitude'];
                  double longitude = records[i]['location']['longitude'];
                  List idList = records[i]['record_id'].split('_');
                  String globalID = records[i]['record_id'];
                  int id = int.parse(idList[idList.length-1]);
                  int timestamp = int.parse(records[i]['timestamp']);
                  String imagePath = records[i]['image_path'];
                  String result = records[i]['result'];
                  String imageStream = records[i]['image_stream'];
                  String myDevice = '';
                  DeviceInfoProvider.gerDeviceInfo().then((value) {
                    myDevice = value;
                    if (latitude!=0 && longitude!=0) {
                      markers.add(Marker(
                        height: 40,
                        width: 40,
                        point: LatLng(latitude, longitude),
                        builder: (ctx) => GestureDetector(
                          onTap: (){
                            showBottomSheet(context: context, builder: (context){
                              return MapInfoCard(globalID: globalID, record: Record(
                                id: id,
                                imagePath: imagePath,
                                timestamp: timestamp,
                                latitude: latitude,
                                longitude: longitude,
                                result: result,
                                imageStream: imageStream
                                )
                              );
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
                          child: (globalID.contains(myDevice))?
                            Image.asset('assets/images/icons/pin_my_record.png',
                              width: 40,
                              height: 40,)
                            :Image.asset('assets/images/icons/pin.png',
                              width: 40,
                              height: 40,)
                          )
                        )
                      );
                    }
                  });
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

  Future<List> getRecords() async {
    Response response = await Dio().get(
      'http://172.16.13.81:5000/map_records'
    ).catchError((e){
      print(e.toString());
    });
    List list = JsonCodec().decode(response.data);
    return list;
  }

}

