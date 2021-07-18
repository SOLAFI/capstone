import 'package:capstone/data/record.dart';
import '../widgets/buttons.dart';
import '../utils/sqlite_handler.dart';

import 'package:flutter/material.dart';

class MapPage extends StatefulWidget{
  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage>{

  @override
  void initState() {
    super.initState();
  }

  Future<List<Record>> getRecords() async {
    return RecDBProvider.records();
  }

  @override
  Widget build(BuildContext context) {

    List<Record> records = [];

    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: FloatingBackButton(),
      body: FutureBuilder(
        future: getRecords(),
        builder:(context, AsyncSnapshot<List<Record>> snapshot) {
          if (snapshot.hasData){
            records = snapshot.data as List<Record>;
            return ListView.builder(
              itemCount: records.length,
              itemBuilder: (context, index){
                return Card(
                  child: ListTile(
                    title: Text(records[index].toString()),
                  ),
                );
              }
            );
          }
          else {
            return Center(child: Text('No record found'));
          }
        },
      ),
    );
  }
}


