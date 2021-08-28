import 'dart:core';

class Record {
  final int id;
  final int timestamp;
  final String result;
  double longitude;
  double latitude;
  String imageStream;
  
  Record({
    required this.id,
    required this.timestamp,
    required this.result,
    this.latitude=-1,
    this.longitude=-1,
    this.imageStream = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'timestamp': timestamp,
      'result': result,
      'latitude': latitude,
      'longitude': longitude,
      'image_stream': imageStream,
    };
  }

  @override
  String toString() {
    return '''
Record:
  id: $id
  time: ${DateTime.fromMillisecondsSinceEpoch(timestamp)}
  result: $result
  latitude: $latitude
  longtitude: $longitude''';
  }

}