import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static const _databaseName = 'my_database.db';
  static const _databaseVersion = 1;

  static const tableName = 'reviews';
  static const columnId = 'id';
  static const columnProductId = 'product_id';
  static const columnComment = 'comment';
  static const columnRating = 'rating';
  static const columnImages = 'images';



  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabse();
    return _database!;
  }

  _initDatabse () async {
    String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(path, version: _databaseVersion, onCreate: _onCreate);
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableName (
        $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnProductId INTEGER NOT NULL,
        $columnComment TEXT NOT NULL,
        $columnRating INTEGER NOT NULL,
        $columnImages TEXT
      )
    ''');
  }

  Future<int> insertReview (Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.insert(tableName, row);
  }

  Future<List<Map<String, dynamic>>> getReviewsByProductId(int productId) async {
    Database db = await instance.database;
    return await db.query(tableName, where: '$columnProductId = ?', whereArgs: [productId]);
  }
}