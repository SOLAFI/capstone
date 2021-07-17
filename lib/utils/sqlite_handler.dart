import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../data/record.dart';


class SQLiteHandler {

  static Future<Database> _initDatebase() async{
    return openDatabase(
      join(await getDatabasesPath(), 'record_database.db'),
      onCreate: (db, version){
        return db.execute(
          'CREATE TABLE records(id INTEGER PRIMARY KEY, image_url TEXT)',
        );
      },
      version: 1,
    );
  }

  // Return a list of all records
  static Future<List<Record>> records() async {
    // Get a reference to the database.
    final db = await _initDatebase();

    // Query the table for all The Dogs.
    final List<Map<String, dynamic>> maps = await db.query('records');

    // Convert the List<Map<String, dynamic> into a List<Dog>.
    return List.generate(maps.length, (i) {
      return Record(
        id: maps[i]['id'],
        imageURL: maps[i]['image_url']
      );
    });
  }

  // Insert a record using a Record Object
  static Future<void> insertRecord(Record rec) async {
      final db = await _initDatebase();
      await db.insert('records', rec.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // Delete a record by ID
  static Future<void> deleteByID(int id) async{
    final db = await _initDatebase();
    await db.delete(
      'records',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Update a record with a Record Object
  Future<void> updateRecord (Record rec) async{
    final db = await _initDatebase();
    await db.update('records',
      rec.toMap(),
      where: 'id = ?',
      whereArgs: [rec.id],
    );
  }

  // Get a record by ID
  Future<Record> getRecordByID(int id) async{
    final db = await _initDatebase();
    List<Map> maps = await db.query('records',
      columns: ['id', 'image_url'],
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.length > 0) {
      return Record(id: maps.first['id'], imageURL: maps.first['image_url']);
    }
    else {
      return Record(id:-1, imageURL: '');
    }
  }
}