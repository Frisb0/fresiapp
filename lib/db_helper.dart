import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static const _databaseName = "fresi_database.db";
  static const _databaseVersion = 1;

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
    return await openDatabase(path,
        version: _databaseVersion,
        onCreate: _onCreate);
  }

  // Creación de tablas limpias y relacionales
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
  }

  // --- Operaciones del Inventario ---
  Future<List<Map<String, dynamic>>> obtenerProductos() async {
    Database db = await instance.database;
    return await db.query('productos');
  }

  Future<int> insertarProducto(String nombre, double precio, int stock) async {
    Database db = await instance.database;
    return await db.insert('productos', {'nombre': nombre, 'precio': precio, 'stock': stock});
  }

  // --- Mecanismo de Transacción SQL (Venta Completa) ---
  Future<bool> registrarVenta(List<Map<String, dynamic>> items, double total) async {
    Database db = await instance.database;
    try {
      await db.transaction((txn) async {
        // 1. Guardar la cabecera de la venta
        await txn.insert('ventas', {
          'usuario': 'Fresia',
          'fecha_hora': DateTime.now().toString().substring(0, 16),
          'total': total,
        });

        // 2. Descontar el stock de cada producto vendido
        for (var item in items) {
          int idProd = item['id'];
          int cantidadVendida = item['cantidad'];

          // Obtener el stock actual en la transacción
          List<Map<String, dynamic>> res = await txn.query('productos', where: 'id = ?', whereArgs: [idProd]);
          int stockActual = res.first['stock'];

          if (stockActual < cantidadVendida) {
            throw Exception("Stock insuficiente para el producto ID $idProd");
          }

          await txn.update(
            'productos',
            {'stock': stockActual - cantidadVendida},
            where: 'id = ?',
            whereArgs: [idProd],
          );
        }
      });
      return true; // Transmisión/Commit exitoso
    } catch (e) {
      print("Error en transacción (Ejecutando Rollback): $e");
      return false; // Error gatilla Rollback automático de sqflite
    }
  }

  Future<List<Map<String, dynamic>>> obtenerVentas() async {
    Database db = await instance.database;
    return await db.query('ventas', orderBy: 'id DESC');
  }
}