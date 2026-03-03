import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:restoranapp/data/model/restaurant_item.dart';

class LocalDatabaseService {
  static const String _databaseName = 'restaurant-app.db';
  static const String _tableName = 'restaurant';
  static const int _version = 1;

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
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _databaseName);
    return openDatabase(
      path,
      version: _version,
      onCreate: (Database database, int version) async {
        await createTables(database);
      },
    );
  }

  // create new item
  Future<int> insertItem(RestaurantItem restaurantItem) async {
    final db = await _initializeDb();

    final data = restaurantItem.toJson();
    print("INSERT DATA: $data");
    final id = await db.insert(
      _tableName,
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return id;
  }

  // read all items
  Future<List<RestaurantItem>> getAllItems() async {
    final db = await _initializeDb();
    final results = await db.query(_tableName);

    return results.map((result) => RestaurantItem.fromJson(result)).toList();
  }

  // todo-01-local-09: get a single item by id
  Future<RestaurantItem?> getItemById(String id) async {
    final db = await _initializeDb();
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
    final db = await _initializeDb();

    final result = await db.delete(
      _tableName,
      where: "id = ?",
      whereArgs: [id],
    );
    return result;
  }
}
