/*import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static Database? _database;

  // Singleton pattern to reuse the database connection
  static Future<Database?> getDatabase() async {
    if (_database != null) return _database;

    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'people.db');

    _database = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''CREATE TABLE people (
          id INTEGER PRIMARY KEY,
          name TEXT
        )''');

        // Insert sample data
        await db.insert('people', {'id': 1, 'name': 'Alice'});
        await db.insert('people', {'id': 2, 'name': 'Bob'});
        await db.insert('people', {'id': 3, 'name': 'Charlie'});
      },
    );

    return _database;
  }

  // Method to search for a name in the database
  static Future<String> searchName(String name) async {
    final db = await getDatabase();
    if (db == null) return 'Database not ready';

    final List<Map<String, dynamic>> records = await db.query(
      'people',
      where: 'name = ?',
      whereArgs: [name],
    );

    if (records.isNotEmpty) {
      return records.first['name'];
    } else {
      return 'Not found';
    }
  }

  // Method to close the database when not in use
  static Future<void> closeDatabase() async {
    final db = await getDatabase();
    if (db != null) {
      await db.close();
    }
  }
}
*/