import 'dart:io';

import 'package:capstone/data/record.dart';
import '../widgets/buttons.dart';
import '../utils/sqlite_handler.dart';

import 'package:flutter/material.dart';

class UserPage extends StatefulWidget{
  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage>{

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
    MediaQueryData mediaQueryData = MediaQuery.of(context);
    double mediaHeight = mediaQueryData.size.height;
    double mediaWidth = mediaQueryData.size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: FloatingBackButton(),
      body: FutureBuilder(
        future: getRecords(),
        builder:(context, AsyncSnapshot<List<Record>> snapshot) {
          if (snapshot.hasData){
            records = snapshot.data as List<Record>;
            return GridView.builder(
              itemCount: records.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 10,
                mainAxisExtent: 300,
              ),
              itemBuilder: (context, index){
                Map rec = records[index].toMap();
                return Card(
                  
                  child: Stack(
                    children: [
                      
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('ID: ${rec['id']}'),
                          Text('Time: ${DateTime.fromMillisecondsSinceEpoch(rec['timestamp'])}'),
                          Container(
                            width: 200,
                            height: 200,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: FileImage(File(rec['image_url'])),
                                fit: BoxFit.cover
                              )
                            ),
                          ),
                          Text('Result: ${rec['result']}'),
                        ],
                      ),
                    ],
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


