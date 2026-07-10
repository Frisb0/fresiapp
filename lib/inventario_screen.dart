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
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Expanded(
              child: _productos.isEmpty
                  ? const Center(child: Text('No hay productos registrados.', style: TextStyle(fontSize: 18)))
                  : SingleChildScrollView(
                      child: Table(
                        border: TableBorder.all(color: Colors.black26, width: 1),
                        columnWidths: const {
                          0: FlexColumnWidth(2.5),
                          1: FlexColumnWidth(1.2),
                          2: FlexColumnWidth(1.5),
                          3: FlexColumnWidth(1.4),
                        },
                        children: [
                          TableRow(
                            decoration: BoxDecoration(color: Colors.grey[200]),
                            children: const [
                              Padding(padding: EdgeInsets.all(10.0), child: Text('Producto', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black87))),
                              Padding(padding: EdgeInsets.all(10.0), child: Text('Stock', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black87))),
                              Padding(padding: EdgeInsets.all(10.0), child: Text('Precio', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black87))),
                              Padding(padding: EdgeInsets.all(10.0), child: Text('Ingreso', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black87))),
                            ],
                          ),
                          ..._productos.map((p) {
                            bool alertaFrescura = (p['dias_frescura'] ?? 7) <= 2;
                            bool alertaPocoStock = (p['stock'] ?? 0) <= 5;
                            String fechaIngreso = p['fecha_ingreso'] ?? '--/--';

                            return TableRow(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Text(
                                    alertaFrescura ? '${p['nombre']} ⚠️' : p['nombre'],
                                    style: TextStyle(
                                      color: alertaFrescura ? Colors.red : colorTextoTema, 
                                      fontWeight: alertaFrescura ? FontWeight.bold : FontWeight.normal,
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(10.0), 
                                  child: Text(
                                    p['stock'].toString(), 
                                    style: TextStyle(
                                      fontSize: 18, 
                                      fontWeight: alertaPocoStock ? FontWeight.bold : FontWeight.normal,
                                      color: alertaPocoStock ? Colors.red : colorTextoTema
                                    )
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(10.0), 
                                  child: Text('\$${(p['precio'] as num).toInt()}', style: TextStyle(fontSize: 18, color: colorTextoTema)),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(10.0), 
                                  child: Text(fechaIngreso, style: TextStyle(fontSize: 18, color: colorTextoTema)),
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