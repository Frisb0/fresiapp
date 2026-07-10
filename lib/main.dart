import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'inventario_screen.dart';
import 'registro_ventas_screen.dart';
import 'calculadora_venta_screen.dart';
import 'producto_screen.dart';

final ValueNotifier<ThemeMode> temaClaroOscuroNotifier = ValueNotifier(ThemeMode.dark);

void main() {
  runApp(const FresiApp());
}

class FresiApp extends StatelessWidget {
  const FresiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: temaClaroOscuroNotifier,
      builder: (_, mode, __) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'FresiApp',
          themeMode: mode,
          theme: ThemeData(
            brightness: Brightness.light,
            primarySwatch: Colors.green,
            scaffoldBackgroundColor: Colors.white,
            appBarTheme: const AppBarTheme(backgroundColor: Colors.green, foregroundColor: Colors.white),
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            primarySwatch: Colors.green,
            scaffoldBackgroundColor: const Color(0xFF121212),
            appBarTheme: const AppBarTheme(backgroundColor: Colors.green, foregroundColor: Colors.white),
          ),
          home: const LoginScreen(),
        );
      },
    );
  }
}

class MenuPrincipal extends StatelessWidget {
  final String usuarioActivo;

  const MenuPrincipal({super.key, required this.usuarioActivo});

  @override
  Widget build(BuildContext context) {
    final esOscuro = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('FresiApp', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: Icon(esOscuro ? Icons.light_mode : Icons.dark_mode, size: 28),
            onPressed: () {
              temaClaroOscuroNotifier.value = esOscuro ? ThemeMode.light : ThemeMode.dark;
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Bienvenido "$usuarioActivo"',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),
            _crearBotonMenu(context, 'Inventario', Icons.inventory, Colors.grey[400]!, const InventarioScreen()),
            const SizedBox(height: 15),
            _crearBotonMenu(
              context, 
              'Registro de ventas', 
              Icons.assignment, 
              Colors.grey[400]!, 
              RegistroVentasScreen(usuarioActivo: usuarioActivo)
            ),
            const SizedBox(height: 15),
            _crearBotonMenu(
              context, 
              'Calculadora de venta', 
              Icons.calculate, 
              Colors.grey[400]!, 
              CalculadoraVentaScreen(usuarioActivo: usuarioActivo)
            ),
            const SizedBox(height: 15),
            _crearBotonMenu(context, 'Agregar producto', Icons.add_circle, Colors.grey[400]!, const ProductosScreen()),
          ],
        ),
      ),
    );
  }

  Widget _crearBotonMenu(BuildContext context, String texto, IconData icono, Color color, Widget pantallaDestino) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.black87,
        padding: const EdgeInsets.symmetric(vertical: 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      onPressed: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => pantallaDestino));
      },
      icon: Icon(icono, size: 24),
      label: Text(texto),
    );
  }
}