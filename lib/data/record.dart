import 'dart:core';

class Record {
  final int id;
  final int timestamp;
  final String imageURL;
  final String result;
  double longitude;
  double latitude;
  
  Record({
    required this.id,
    required this.imageURL,
    required this.timestamp,
    required this.result,
    this.latitude=-1,
    this.longitude=-1,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'image_url': imageURL,
      'timestamp': timestamp,
      'result': result,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  @override
  String toString() {
    return '''
Record:
  id: $id
  time: ${DateTime.fromMillisecondsSinceEpoch(timestamp)}
  image url: $imageURL
  result: $result
  latitude: $latitude
  longtitude: $longitude''';
  }

}