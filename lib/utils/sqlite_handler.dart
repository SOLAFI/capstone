import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../data/record.dart';


class RecDBProvider {

  static Future<Database> initDatabase() async{
    return openDatabase(
      join(await getDatabasesPath(), 'record_database.db'),
      onCreate: (db, version){
        return db.execute(
          'CREATE TABLE records(id INTEGER PRIMARY KEY, timestamp INTEGER, image_url TEXT, result TEXT, latitude REAL, longitude REAL)',
        );
      },
      version: 1,
    );
  }

  static Future<void> deleteRecDB() async {
    await deleteDatabase(join(await getDatabasesPath(), 'record_database.db'));
  }


  // Return a list of all records
  static Future<List<Record>> records() async {
    // Get a reference to the database.
    final db = await initDatabase();

    // Query the table for all The Dogs.
    final List<Map<String, dynamic>> maps = await db.query('records');

    // Convert the List<Map<String, dynamic> into a List<Dog>.
    return List.generate(maps.length, (i) {
      return Record(
        id: maps[i]['id'],
        imageURL: maps[i]['image_url'],
        result: maps[i]['result'],
        timestamp: maps[i]['timestamp'],
        latitude: maps[i]['latitude'],
        longitude: maps[i]['longitude'],
      );
    });
  }

  // Return a list of all records
  static Future<int> recordsCount() async {
    // Get a reference to the database.
    final db = await initDatabase();

    // Query the table for all The Dogs.
    final List<Map<String, dynamic>> maps = await db.query('records');

    // Convert the List<Map<String, dynamic> into a List<Dog>.
    List records = List.generate(maps.length, (i) {
      return Record(
        id: maps[i]['id'],
        imageURL: maps[i]['image_url'],
        result: maps[i]['result'],
        timestamp: 0,
        latitude: 0,
        longitude: 0,
      );
    });

    return records.length;
  }

  // Insert a record using a Record Object
  static Future<void> insertRecord(Record rec) async {
      final db = await initDatabase();
      await db.insert('records', rec.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // Delete a record by ID
  static Future<void> deleteByID(int id) async{
    final db = await initDatabase();
    await db.delete(
      'records',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Update a record with a Record Object
  Future<void> updateRecord (Record rec) async{
    final db = await initDatabase();
    await db.update('records',
      rec.toMap(),
      where: 'id = ?',
      whereArgs: [rec.id],
    );
  }

  // Get a record by ID
  Future<Record> getRecordByID(int id) async{
    final db = await initDatabase();
    List<Map> maps = await db.query('records',
      columns: null,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.length > 0) {
      Map rec = maps.first;
      return Record(
        id: rec['id'],
        imageURL: rec['image_url'],
        timestamp: rec['timestamp'],
        result: rec['result'],
        latitude: rec['latitude'],
        longitude: rec['longitude'],
      );
    }
    else {
      throw 'Record with id: $id not found';
    }
  }
}