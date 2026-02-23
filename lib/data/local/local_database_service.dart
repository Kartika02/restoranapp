import 'package:sqflite/sqflite.dart';
import 'package:restoranapp/data/model/restaurant_item.dart';

class LocalDatabaseService {
  static const String _databaseName = 'restaurant-app.db';
  static const String _tableName = 'restaurant';
  static const int _version = 1;

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initializeDb();
    return _database!;
  }

  Future<void> createTables(Database database) async {
    await database.execute("""CREATE TABLE $_tableName(
        id TEXT PRIMARY KEY,
        name TEXT,
        pictureId TEXT,
        city TEXT,
        rating REAL
      )
      """);
  }

  // make connection with database
  Future<Database> _initializeDb() async {
    return openDatabase(
      _databaseName,
      version: _version,
      onCreate: (Database database, int version) async {
        await createTables(database);
      },
    );
  }

  // create new item
  Future<int> insertItem(RestaurantItem restaurant) async {
    final db = await database;

    final data = restaurant.toJson();
    print("INSERT DATA: $data");
    final result = await db.insert(
      _tableName,
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return result;
  }

  // read all items
  Future<List<RestaurantItem>> getAllItems() async {
    final db = await database;
    final results = await db.query(_tableName);

    return results.map((result) => RestaurantItem.fromJson(result)).toList();
  }

  // todo-01-local-09: get a single item by id
  Future<RestaurantItem?> getItemById(String id) async {
    final db = await database;
    final results = await db.query(
      _tableName,
      where: "id = ?",
      whereArgs: [id],
      limit: 1,
    );

    return results.isEmpty ? null : RestaurantItem.fromJson(results.first);
  }

  // todo-01-local-10: delete an item by id
  Future<int> removeItem(String id) async {
    final db = await database;

    final result = await db.delete(
      _tableName,
      where: "id = ?",
      whereArgs: [id],
    );
    return result;
  }
}
