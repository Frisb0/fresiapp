import 'package:flutter/material.dart';
import 'db_helper.dart';

class InventarioScreen extends StatefulWidget {
  const InventarioScreen({super.key});

  @override
  State<InventarioScreen> createState() => _InventarioScreenState();
}

class _InventarioScreenState extends State<InventarioScreen> {
  List<Map<String, dynamic>> _productos = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _cargarInventario();
  }

  @override
  void initState() {
    super.initState();
    _cargarInventario();
  }

  void _cargarInventario() async {
    final datos = await DBHelper.instance.obtenerProductos();
    if (!mounted) return;
    setState(() {
      _productos = datos;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorTextoTema = Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventario en Tiempo Real', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: _productos.isEmpty
                  ? const Center(child: Text('No hay productos registrados.', style: TextStyle(fontSize: 18)))
                  : SingleChildScrollView(
                      child: Table(
                        border: TableBorder.all(color: Colors.black26, width: 1),
                        children: [
                          // Cabecera de la tabla con textos grandes (Ajuste #3)
                          TableRow(
                            decoration: BoxDecoration(color: Colors.grey[200]),
                            children: [
                              const Padding(padding: EdgeInsets.all(12.0), child: Text('Producto', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.black87))),
                              const Padding(padding: EdgeInsets.all(12.0), child: Text('Stock', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.black87))),
                              const Padding(padding: EdgeInsets.all(12.0), child: Text('Precio', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.black87))),
                            ],
                          ),
                          ..._productos.map((p) {
                            bool alertaFrescura = (p['dias_frescura'] ?? 7) <= 2;
                            return TableRow(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Text(
                                    alertaFrescura ? '${p['nombre']} ⚠️ (Viejo)' : p['nombre'],
                                    style: TextStyle(
                                      color: alertaFrescura ? Colors.red : colorTextoTema, 
                                      fontWeight: alertaFrescura ? FontWeight.bold : FontWeight.normal,
                                      fontSize: 20, // Ajuste #3
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(12.0), 
                                  child: Text(p['stock'].toString(), style: TextStyle(fontSize: 20, color: colorTextoTema)), // Ajuste #3
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(12.0), 
                                  child: Text('\$${p['precio']}', style: TextStyle(fontSize: 20, color: colorTextoTema)), // Ajuste #3
                                ),
                              ],
                            );
                          }).toList(),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}