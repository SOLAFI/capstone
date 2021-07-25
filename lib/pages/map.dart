import 'package:location/location.dart';
import '../widgets/buttons.dart';

import 'package:flutter/material.dart';
import 'package:amap_flutter_map/amap_flutter_map.dart';
import 'package:amap_flutter_base/amap_flutter_base.dart';

class MapPage extends StatefulWidget{

  MapPage({Key? key}) : super(key: key);

  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage>{

  static const String androidKey = '6b876190172b34d115e0a49126427553';
  static const String iosKey = '2ba558cf5b3693da79bef41c2a521caf';

  @override
  void initState() {
    super.initState();
  }

  Future<LocationData> _getMyLocation() async{
    Location location = new Location();
    LocationData locationData = await location.getLocation();
    return locationData;
  }

  static const AMapApiKey amapApiKeys = AMapApiKey(
      androidKey: androidKey,
      iosKey: iosKey);

  AMapController? _mapController;
  void onMapCreated(AMapController controller) {
    setState(() {
      _mapController = controller;
      getApprovalNumber();
    });
  }

  /// 获取审图号
  void getApprovalNumber() async {
    //普通地图审图号
    String? mapContentApprovalNumber =
        await _mapController?.getMapContentApprovalNumber();
    //卫星地图审图号
    String? satelliteImageApprovalNumber =
        await _mapController?.getSatelliteImageApprovalNumber();
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
              final CameraPosition _kInitialPosition = CameraPosition(
                target: LatLng(snapshot.data.latitude, snapshot.data.longitude),
                zoom: 15.0,
              );
                ///在创建地图时设置apiKey属性
              AMapWidget map = AMapWidget(
                    ///配置apiKey,设置为null或者不设置则优先使用native端配置的key
                    apiKey: amapApiKeys,
                    initialCameraPosition: _kInitialPosition,
                    mapType: MapType.normal,
                    onMapCreated: onMapCreated,
                    myLocationStyleOptions: MyLocationStyleOptions(true),
              );
              return map;
            }
            return Text('Loading...');
          },
        ),
      ),
    );
  }

  // Future<List<Record>> getRecords() async {
  //   return RecDBProvider.records();
  // }

  // @override
  // Widget build(BuildContext context) {

  //   List<Record> records = [];

  //   return Scaffold(
  //     backgroundColor: Colors.white,
  //     floatingActionButton: FloatingBackButton(),
  //     body: FutureBuilder(
  //       future: getRecords(),
  //       builder:(context, AsyncSnapshot<List<Record>> snapshot) {
  //         if (snapshot.hasData){
  //           records = snapshot.data as List<Record>;
  //           return ListView.builder(
  //             itemCount: records.length,
  //             itemBuilder: (context, index){
  //               return Card(
  //                 child: ListTile(
  //                   title: Text(records[index].toString()),
  //                 ),
  //               );
  //             }
  //           );
  //         }
  //         else {
  //           return Center(child: Text('No record found'));
  //         }
  //       },
  //     ),
  //   );
  // }
}


