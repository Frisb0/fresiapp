import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'db_helper.dart';

class RegistroVentasScreen extends StatefulWidget {
  final String usuarioActivo; // [✓] Recibe de forma obligatoria el usuario logueado

  const RegistroVentasScreen({super.key, required this.usuarioActivo});

  @override
  State<RegistroVentasScreen> createState() => _RegistroVentasScreenState();
}

class _RegistroVentasScreenState extends State<RegistroVentasScreen> {
  List<Map<String, dynamic>> _ventasHistorial = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _cargarHistorialVentas();
  }

  @override
  void initState() {
    super.initState();
    _cargarHistorialVentas();
  }

  void _cargarHistorialVentas() async {
    final datos = await DBHelper.instance.obtenerVentas();
    if (!mounted) return;
    setState(() {
      _ventasHistorial = datos;
    });
  }

  void _eliminarVentaRegistro(int id) async {
    Database db = await DBHelper.instance.database;
    await db.delete('ventas', where: "id = ?", whereArgs: [id]);
    _cargarHistorialVentas();
    
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('🗑️ Registro de venta eliminado del historial.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registro de Ventas Reales', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: _ventasHistorial.isEmpty
                  ? const Center(
                      child: Text(
                        'No se han registrado transacciones aún.', 
                        style: TextStyle(fontSize: 16),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _ventasHistorial.length,
                      itemBuilder: (context, index) {
                        final venta = _ventasHistorial[index];
                        return Card(
                          elevation: 3,
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.green[100],
                              child: Text(
                                '#${venta['id']}', 
                                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                              ),
                            ),
                            title: Text(
                              'Total Cobrado: \$${venta['total']}', 
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            subtitle: Text('Atendido por: ${venta['usuario']}\nFecha: ${venta['fecha_hora']}'),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.red),
                              onPressed: () => _eliminarVentaRegistro(venta['id']),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}