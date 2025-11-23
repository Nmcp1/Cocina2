import 'package:flutter/material.dart';
import '../constants/theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground1,
      body: Stack(
        children: [
          // Media elipse arriba
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
                  bottomLeft: Radius.elliptical(500, 200),
                  bottomRight: Radius.elliptical(500, 200),
                ),
              ),
            ),
          ),
          // Texto COCINA2 sobre la elipse
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
          // Contenido centrado sin ovalado
          Positioned(
            top: 180,
            left: 0,
            right: 0,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ClipOval(
                    child: SizedBox(
                      width: 200, // radio 100 * 2
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
                  // Usuario
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'Usuario',
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
                  // Contraseña
                  TextField(
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
                          _obscurePassword ? Icons.visibility_off : Icons.visibility,
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
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kSecondary,
                      minimumSize: const Size(200, 50),
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pushNamed(context, '/menu'); // Navega al main menu
                    },
                    child: const Text(
                      'Iniciar sesión',
                      style: TextStyle(fontSize: 24, color: kBackground2, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 30),
                  TextButton(
                    onPressed: () => Navigator.pushNamed(context, '/register'),
                    child: Text.rich(
                      TextSpan(
                        text: '¿Aún no tiene una cuenta? ',
                        style: const TextStyle(
                          color: kText1,
                          fontWeight: FontWeight.normal,
                          fontSize: 18,
                        ),
                        children: [
                          TextSpan(
                            text: 'Registrarse',
                            style: const TextStyle(
                              color: kText1,
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
}