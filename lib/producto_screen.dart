import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'db_helper.dart';

class ProductosScreen extends StatefulWidget {
  const ProductosScreen({super.key});

  @override
  State<ProductosScreen> createState() => _ProductosScreenState();
}

class _ProductosScreenState extends State<ProductosScreen> {
  List<Map<String, dynamic>> _productos = [];
  final _nombreController = TextEditingController();
  final _precioController = TextEditingController();
  final _stockController = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _refreshProductos();
  }

  @override
  void initState() {
    super.initState();
    _refreshProductos();
  }

  void _refreshProductos() async {
    final data = await DBHelper.instance.obtenerProductos();
    if (!mounted) return;
    setState(() {
      _productos = data;
    });
  }

  void _mostrarFormulario(int? id) async {
    if (id != null) {
      final productoExistente = _productos.firstWhere((element) => element['id'] == id);
      _nombreController.text = productoExistente['nombre'];
      _precioController.text = productoExistente['precio'].toString();
      _stockController.text = productoExistente['stock'].toString();
    } else {
      _nombreController.clear();
      _precioController.clear();
      _stockController.clear();
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          top: 20,
          left: 20,
          right: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              id == null ? 'Añadir Nuevo Producto' : 'Modificar Producto',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            TextField(controller: _nombreController, decoration: const InputDecoration(labelText: 'Nombre del Producto')),
            const SizedBox(height: 10),
            TextField(controller: _precioController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Precio Unitario')),
            const SizedBox(height: 10),
            TextField(controller: _stockController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Cantidad de Stock')),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.white),
              onPressed: () async {
                final nombre = _nombreController.text;
                final precio = double.tryParse(_precioController.text) ?? 0.0;
                final stock = int.tryParse(_stockController.text) ?? 0;

                if (nombre.isEmpty || precio <= 0 || stock < 0) return;

                if (id == null) {
                  await DBHelper.instance.insertarProducto(nombre, precio, stock);
                } else {
                  String fechaHoy = DateTime.now().toString().substring(8, 10) + "/" + DateTime.now().toString().substring(5, 7);
                  Database db = await DBHelper.instance.database;
                  await db.update(
                    'productos',
                    {
                      'nombre': nombre.trim(),
                      'precio': precio,
                      'stock': stock,
                      'fecha_ingreso': fechaHoy
                    },
                    where: "id = ?",
                    whereArgs: [id],
                  );
                }

                if (!mounted) return;
                _refreshProductos();
                Navigator.pop(context);
              },
              child: Text(id == null ? 'Agregar' : 'Guardar Cambios'),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _eliminarProducto(int id) async {
    Database db = await DBHelper.instance.database;
    await db.delete('productos', where: "id = ?", whereArgs: [id]);

    if (!mounted) return;
    _refreshProductos();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('🗑️ Producto eliminado del inventario.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Productos', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: _productos.isEmpty
          ? const Center(child: Text('No hay productos registrados.'))
          : ListView.builder(
              itemCount: _productos.length,
              itemBuilder: (context, index) {
                final prod = _productos[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: prod['stock'] == 0 ? Colors.red[100] : Colors.green[100],
                      child: Text(
                        '${prod['stock']}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: prod['stock'] == 0 ? Colors.red : Colors.green,
                        ),
                      ),
                    ),
                    title: Text(prod['nombre'], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    subtitle: Text('Precio Unitario: \$${prod['precio']}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: () => _mostrarFormulario(prod['id'])),
                        IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _eliminarProducto(prod['id'])),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
        onPressed: () => _mostrarFormulario(null),
      ),
    );
  }
}