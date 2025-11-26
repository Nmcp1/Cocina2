import 'package:flutter/material.dart';
import 'package:cocinagame/constants/theme.dart';
import 'package:cocinagame/services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _obscurePassword = true;

  // Controladores
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground1,
      body: Stack(
        children: [
          // MEDIA ELIPSE SUPERIOR
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: 150,
              decoration: BoxDecoration(
                color: kPrimary,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.elliptical(400, 250),
                  bottomRight: Radius.elliptical(400, 250),
                ),
              ),
            ),
          ),

          // TEXTO SUPERIOR
          Positioned(
            top: 60,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                'COCINA2',
                style: const TextStyle(
                  fontSize: 48,
                  color: kBackground1,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          // CONTENIDO CENTRAL
          Positioned(
            top: 180,
            left: 0,
            right: 0,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // LOGO
                  ClipOval(
                    child: SizedBox(
                      width: 200,
                      height: 200,
                      child: Image.asset(
                        'assets/images/logo_cocina2.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    '¡Bienvenido!',
                    style: TextStyle(
                      fontSize: 36,
                      color: kText1,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 40),

                  // CAMPO EMAIL
                  TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Usuario (correo)',
                      labelStyle: const TextStyle(color: kPrimary),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: kPrimary, width: 2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: kPrimary, width: 2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      fillColor: kBackground2,
                      filled: true,
                    ),
                  ),

                  const SizedBox(height: 40),

                  // CAMPO CONTRASEÑA
                  TextField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: 'Contraseña',
                      labelStyle: const TextStyle(color: kPrimary),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: kPrimary, width: 2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: kPrimary, width: 2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      fillColor: kBackground2,
                      filled: true,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: kPrimary,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 50),

                  // BOTÓN LOGIN
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kSecondary,
                      minimumSize: const Size(200, 50),
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: _loading ? null : _loginUser,
                    child: _loading
                        ? const CircularProgressIndicator(color: kBackground2)
                        : const Text(
                            'Iniciar sesión',
                            style: TextStyle(
                              fontSize: 24,
                              color: kBackground2,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),

                  const SizedBox(height: 30),

                  // BOTÓN IR A REGISTRO
                  TextButton(
                    onPressed: () => Navigator.pushNamed(context, '/register'),
                    child: Text.rich(
                      TextSpan(
                        text: '¿Aún no tiene una cuenta? ',
                        style: const TextStyle(
                          color: kText1,
                          fontSize: 18,
                        ),
                        children: [
                          TextSpan(
                            text: 'Registrarse',
                            style: const TextStyle(
                              color: kPrimary,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // LOGIN FIREBASE
  Future<void> _loginUser() async {
    final email = _emailController.text.trim();
    final pass = _passwordController.text.trim();

    if (email.isEmpty || pass.isEmpty) {
      _showMessage("Completa todos los campos");
      return;
    }

    setState(() => _loading = true);

    try {
      await AuthService().login(email, pass);

      if (!mounted) return;

      // ⬇️ IMPORTANTE: ir a la ruta base, limpiando el stack
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/',
        (route) => false,
      );
    } catch (e) {
      String msg;
      if (e is Exception) {
        msg = e.toString().replaceFirst('Exception: ', '');
      } else {
        msg = 'Error inesperado';
      }
      _showMessage(msg);
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }
  void _showMessage(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }
}
