class Record {
  final int id;
  final String imageURL;
  
  Record({
    required this.id,
    required this.imageURL
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'image_url': imageURL,
    };
  }

  @override
  String toString() {
    return 'Record{id: $id, image url: $imageURL}';
  }

}