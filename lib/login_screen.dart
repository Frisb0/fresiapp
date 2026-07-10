import 'package:flutter/material.dart';
import 'db_helper.dart';
import 'main.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _userController = TextEditingController();
  final _passController = TextEditingController();
  bool _esRegistro = false;

  void _procesarAutenticacion() async {
    final username = _userController.text.trim();
    final password = _passController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⚠️ Por favor completa todos los campos.')),
      );
      return;
    }

    if (_esRegistro) {
      int res = await DBHelper.instance.registrarUsuario(username, password);
      if (!mounted) return;
      if (res != -1) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('🎉 Vendedor registrado con éxito. Ya puedes iniciar sesión.')),
        );
        setState(() {
          _esRegistro = false;
          _passController.clear();
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('❌ El nombre de usuario ya está en uso.')),
        );
      }
    } else {
      bool valido = await DBHelper.instance.verificarLogin(username, password);
      if (!mounted) return;
      if (valido) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MenuPrincipal(usuarioActivo: username)),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('❌ Credenciales incorrectas. Inténtalo de nuevo.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final esOscuro = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(_esRegistro ? 'Registrar Vendedor' : 'Ingreso FresiApp', style: const TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: Icon(esOscuro ? Icons.light_mode : Icons.dark_mode, size: 28),
            onPressed: () {
              temaClaroOscuroNotifier.value = esOscuro ? ThemeMode.light : ThemeMode.dark;
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.local_florist, size: 80, color: Colors.green[600]),
                const SizedBox(height: 20),
                Text(
                  _esRegistro ? 'Crea una cuenta de acceso' : 'Identifícate para continuar',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 30),
                TextField(
                  controller: _userController,
                  style: const TextStyle(fontSize: 18),
                  decoration: const InputDecoration(labelText: 'Nombre de Vendedor', prefixIcon: Icon(Icons.person)),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: _passController,
                  obscureText: true,
                  style: const TextStyle(fontSize: 18),
                  decoration: const InputDecoration(labelText: 'Contraseña', prefixIcon: Icon(Icons.lock)),
                ),
                const SizedBox(height: 40),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  onPressed: _procesarAutenticacion,
                  child: Text(_esRegistro ? 'Registrar' : 'Entrar', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 15),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _esRegistro = !_esRegistro;
                    });
                  },
                  child: Text(
                    _esRegistro ? '¿Ya tienes cuenta? Inicia Sesión' : '¿Nuevo vendedor? Regístrate aquí',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}