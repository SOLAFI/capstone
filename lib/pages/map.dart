import 'package:flutter/material.dart';

import '../data/record.dart';
import '../utils/sqlite_handler.dart';

class MapPage extends StatefulWidget{
  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage>{

  String text = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SizedBox(
          height: 200,
          child: Column(
            children: [
              ElevatedButton(
                child: Text('SQLite test - list'),
                onPressed: ()async{
                  // generatedID++;
                  // var record = Record(id: generatedID, imageURL: 'example$generatedID');
                  // await insertRecord(record);
                  List list = await RecDBProvider.records();
                  setState(() {
                    text = list.toString();
                  });
                }
              ),
              Text(text),
            ],
          ),
        ),
      ),
    );
  }
}


