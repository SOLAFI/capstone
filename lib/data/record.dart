import 'dart:ffi';

class Record {
  final int id;
  final int timestamp;
  final String imageURL;
  final double longitude;
  final double latitude;
  
  Record({
    required this.id,
    required this.imageURL,
    required this.timestamp,
    required this.latitude,
    required this.longitude,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'image_url': imageURL,
      'timestamp': timestamp,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  @override
  String toString() {
    return '''
      Record:
        time: $timestamp
        id: $id
        image url: $imageURL}
    ''';
  }

}