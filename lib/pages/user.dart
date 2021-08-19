import 'dart:convert';

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

    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: FloatingBackButton(),
      body: FutureBuilder(
        future: getRecords(),
        builder:(context, AsyncSnapshot<List<Record>> snapshot) {
          if (snapshot.hasData){
            List list = snapshot.data!;
            if (list.length==0){
              return Center(child: Text('No record found'));
            }
            records = snapshot.data as List<Record>;
            return GridView.builder(
              itemCount: records.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 10,
                mainAxisExtent: 300,
              ),
              itemBuilder: (context, index){
                Record rec = records[index];
                return Card(
                  child: Stack(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('ID: ${rec.id}'),
                          Text('Time: ${DateTime.fromMillisecondsSinceEpoch(rec.timestamp)}'),
                          Container(
                            width: 200,
                            height: 200,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: MemoryImage(
                                  base64Decode(rec.imageStream),
                                ),
                                fit: BoxFit.cover
                              )
                            ),
                          ),
                          Text('Result: ${rec.result}'),
                        ],
                      ),
                    ],
                  ),
                );
              }
            );
          }
          else {
            return Center(child: Text('Loading...'));
          }
        },
      ),
    );
  }
}


