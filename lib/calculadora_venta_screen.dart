import 'package:flutter/material.dart';
import 'db_helper.dart';

class CalculadoraVentaScreen extends StatefulWidget {
  final String usuarioActivo; // Recibe de forma modular el vendedor logueado

  const CalculadoraVentaScreen({super.key, required this.usuarioActivo});

  @override
  State<CalculadoraVentaScreen> createState() => _CalculadoraVentaScreenState();
}

class _CalculadoraVentaScreenState extends State<CalculadoraVentaScreen> {
  List<Map<String, dynamic>> _productosDisponibles = [];
  final List<Map<String, dynamic>> _carritoVenta = [];
  
  String? _idProductoSeleccionado;
  final _cantidadController = TextEditingController(text: "1");
  double _precioFinalTotal = 0.0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _cargarProductos(); 
  }

  @override
  void initState() {
    super.initState();
    _cargarProductos();
  }

  void _cargarProductos() async {
    final datos = await DBHelper.instance.obtenerProductos();
    if (!mounted) return;
    setState(() {
      _productosDisponibles = datos;
      if (_idProductoSeleccionado != null && 
          !_productosDisponibles.any((p) => p['id'].toString() == _idProductoSeleccionado)) {
        _idProductoSeleccionado = null;
      }
    });
  }

  void _agregarAlCarrito() {
    if (_idProductoSeleccionado == null) return;
    
    final cantidad = int.tryParse(_cantidadController.text) ?? 1;
    final prod = _productosDisponibles.firstWhere((p) => p['id'].toString() == _idProductoSeleccionado);

    setState(() {
      _carritoVenta.add({
        'id': prod['id'],
        'nombre': prod['nombre'],
        'cantidad': cantidad,
        'subtotal': prod['precio'] * cantidad
      });
      _precioFinalTotal += prod['precio'] * cantidad;
      _cantidadController.text = "1";
    });
  }

  void _eliminarDelCarrito(int index) {
    setState(() {
      _precioFinalTotal -= _carritoVenta[index]['subtotal'];
      _carritoVenta.removeAt(index);
    });
  }

  void _procesarVentaReal() async {
    if (_carritoVenta.isEmpty) return;

    // [✓] Enviamos 'widget.usuarioActivo' para que guarde tu login real (ej: "Aaron") en SQLite
    bool exito = await DBHelper.instance.registrarVenta(_carritoVenta, _precioFinalTotal, widget.usuarioActivo);

    if (!mounted) return;

    if (exito) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('🎉 Boleta completada y stock actualizado de forma segura.')),
      );
      setState(() {
        _carritoVenta.clear();
        _precioFinalTotal = 0.0;
        _idProductoSeleccionado = null;
      });
      _cargarProductos(); 
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ Error en la venta: Stock insuficiente o transacción cancelada.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calculadora de venta rápida', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _cantidadController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(fontSize: 18),
                    decoration: InputDecoration(
                      labelText: 'Cant.',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  flex: 5,
                  child: DropdownButtonFormField<String>(
                    isExpanded: true,
                    // [✓] SOLUCIÓN: Reemplazado 'initialValue' por 'value' para corregir la advertencia del linter
                    value: _idProductoSeleccionado,
                    decoration: InputDecoration(
                      labelText: 'Producto',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                    items: _productosDisponibles.map((p) {
                      return DropdownMenuItem<String>(
                        value: p['id'].toString(),
                        child: Text('${p['nombre']} (\$${p['precio']})', overflow: TextOverflow.ellipsis),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _idProductoSeleccionado = value;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            ElevatedButton.icon(
              onPressed: _agregarAlCarrito,
              icon: const Icon(Icons.add),
              label: const Text('Añadir al Carrito'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green[100], foregroundColor: Colors.black87),
            ),
            const SizedBox(height: 15),
            Expanded(
              child: _carritoVenta.isEmpty
                  ? const Center(child: Text('El carrito está vacío.', style: TextStyle(fontSize: 16)))
                  : ListView.builder(
                      itemCount: _carritoVenta.length,
                      itemBuilder: (context, idx) {
                        final item = _carritoVenta[idx];
                        return ListTile(
                          title: Text('${item['nombre']} x${item['cantidad']}'),
                          subtitle: Text('Subtotal: \$${item['subtotal']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _eliminarDelCarrito(idx),
                          ),
                        );
                      },
                    ),
            ),
            const Divider(thickness: 2),
            const Text('Precio final total:', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            Text('\$ $_precioFinalTotal', style: const TextStyle(fontSize: 44, fontWeight: FontWeight.bold, color: Colors.green)),
            const SizedBox(height: 15),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
              onPressed: _procesarVentaReal,
              child: const Text('Completar Venta', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}