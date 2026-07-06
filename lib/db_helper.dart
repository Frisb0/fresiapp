import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static const _databaseName = "fresi_database.db";
  static const _databaseVersion = 2;

  DBHelper._privateConstructor();
  static final DBHelper instance = DBHelper._privateConstructor();

  static Database? _database;
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE usuarios (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          username TEXT UNIQUE NOT NULL,
          password TEXT NOT NULL
        )
      ''');
    }
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
          CREATE TABLE productos (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nombre TEXT NOT NULL,
            precio REAL NOT NULL,
            stock INTEGER NOT NULL,
            dias_frescura INTEGER DEFAULT 7
          )
          ''');

    await db.execute('''
          CREATE TABLE ventas (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            usuario TEXT NOT NULL,
            fecha_hora TEXT NOT NULL,
            total REAL NOT NULL
          )
          ''');

    await db.execute('''
          CREATE TABLE usuarios (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            username TEXT UNIQUE NOT NULL,
            password TEXT NOT NULL
          )
          ''');
  }

  Future<int> registrarUsuario(String username, String password) async {
    Database db = await instance.database;
    try {
      return await db.insert('usuarios', {'username': username, 'password': password});
    } catch (e) {
      return -1; 
    }
  }

  Future<bool> verificarLogin(String username, String password) async {
    Database db = await instance.database;
    List<Map<String, dynamic>> res = await db.query(
      'usuarios',
      where: 'username = ? AND password = ?',
      whereArgs: [username, password],
    );
    return res.isNotEmpty;
  }

  Future<List<Map<String, dynamic>> > obtenerProductos() async {
    Database db = await instance.database;
    return await db.query('productos');
  }

  Future<int> insertarProducto(String nombre, double precio, int stock) async {
    Database db = await instance.database;
    return await db.insert('productos', {'nombre': nombre, 'precio': precio, 'stock': stock});
  }

  Future<bool> registrarVenta(List<Map<String, dynamic>> items, double total, String usuarioActivo) async {
    Database db = await instance.database;
    try {
      await db.transaction((txn) async {
        await txn.insert('ventas', {
          'usuario': usuarioActivo, 
          'fecha_hora': DateTime.now().toString().substring(0, 16),
          'total': total,
        });

        for (var item in items) {
          int idProd = item['id'];
          int cantidadVendida = item['cantidad'];

          List<Map<String, dynamic>> res = await txn.query('productos', where: 'id = ?', whereArgs: [idProd]);
          int stockActual = res.first['stock'];

          if (stockActual < cantidadVendida) {
            throw Exception("Stock insuficiente");
          }

          await txn.update(
            'productos',
            {'stock': stockActual - cantidadVendida},
            where: 'id = ?',
            whereArgs: [idProd],
          );
        }
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> obtenerVentas() async {
    Database db = await instance.database;
    return await db.query('ventas', orderBy: 'id DESC');
  }
}