import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../data/record.dart';


class RecDBProvider {

  static Future<Database> initDatabase() async{
    return openDatabase(
      join(await getDatabasesPath(), 'record_database.db'),
      onCreate: (db, version){
        return db.execute(
          'CREATE TABLE records(id INTEGER PRIMARY KEY, timestamp INTEGER, result TEXT, latitude REAL, longitude REAL, image_stream TEXT)',
        );
      },
      version: 4,
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

    // Convert the List<Map<String, dynamic> into a List.
    return List.generate(maps.length, (i) {
      return Record(
        id: maps[i]['id'],
        result: maps[i]['result'],
        timestamp: maps[i]['timestamp'],
        imageStream: maps[i]['image_stream'],
        longitude: maps[i]['longitude'],
        latitude: maps[i]['latitude']
      );
    });
  }

  // Return a list of all records
  static Future<int> recordsCount() async {
    // Get a reference to the database.
    final db = await initDatabase();

    // Query the table for all
    final List<Map<String, dynamic>> maps = await db.query('records');

    // Convert the List<Map<String, dynamic> into a List<Record>.
    List records = List.generate(maps.length, (i) {
      return Record(
        id: maps[i]['id'],
        result: maps[i]['result'],
        timestamp: maps[i]['timestamp'],
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
  static Future<void> updateRecord (Record rec) async{
    final db = await initDatabase();
    await db.update('records',
      rec.toMap(),
      where: 'id = ?',
      whereArgs: [rec.id],
    );
  }

  // Get a record by ID
  static Future<Record> getRecordByID(int id) async{
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
        timestamp: rec['timestamp'],
        result: rec['result'],
        imageStream: rec['image_stream'],
        latitude: rec['latitude'],
        longitude: rec['longitidue']
      );
    }
    else {
      throw 'Record with id: $id not found';
    }
  }

  // Check if a species exists
  static Future<bool> checkIfRecognized(String className) async{
    final db = await initDatabase();
    List<Map> maps = await db.query('records',
      columns: ['id', 'result'],
      where: 'result = ?',
      whereArgs: [className],
    );
    if (maps.length>0) {
      return true;
    } else {
      return false;
    }
  }
}