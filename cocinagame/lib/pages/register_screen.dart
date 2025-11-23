import 'package:flutter/material.dart';
import '../constants/theme.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

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
          // Contenido centrado
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
                    'Crear una cuenta',
                    style: TextStyle(
                      fontSize: 32,
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
                  const SizedBox(height: 30),
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
                  const SizedBox(height: 30),
                  // Confirmar contraseña
                  TextField(
                    obscureText: _obscureConfirm,
                    decoration: InputDecoration(
                      labelText: 'Confirmar contraseña',
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
                          _obscureConfirm ? Icons.visibility_off : Icons.visibility,
                          color: kPrimary,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureConfirm = !_obscureConfirm;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
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
                      // Acción de registrarse
                    },
                    child: const Text(
                      'Registrarse',
                      style: TextStyle(fontSize: 24, color: kBackground2, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 30),
                  TextButton(
                    onPressed: () => Navigator.pushNamed(context, '/login'),
                    child: Text.rich(
                      TextSpan(
                        text: '¿Ya tiene una cuenta? ',
                        style: const TextStyle(
                          color: kText1,
                          fontWeight: FontWeight.normal,
                          fontSize: 18,
                        ),
                        children: [
                          TextSpan(
                            text: 'Iniciar sesión',
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