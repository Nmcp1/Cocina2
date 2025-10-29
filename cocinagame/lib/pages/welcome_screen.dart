import 'package:flutter/material.dart';
import '../constants/theme.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPrimary,
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
                color: kBackground1,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.elliptical(400, 250),
                  bottomRight: Radius.elliptical(400, 250),
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
                  color: kPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          // Contenido ovalado central
          Align(
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ClipOval(
                  child: SizedBox(
                    width: 250, // radio 125 * 2
                    height: 250,
                    child: Image.asset(
                      'assets/images/logo_cocina2.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 60),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kSecondary,
                    minimumSize: const Size(200, 50),
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () => Navigator.pushNamed(context, '/login'),
                  child: const Text(
                    'Iniciar sesión',
                    style: TextStyle(fontSize: 24, color: kBackground2, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 40),
                TextButton(
                  onPressed: () => Navigator.pushNamed(context, '/register'),
                  child: Text.rich(
                    TextSpan(
                      text: '¿Aún no tienes una cuenta? ',
                      style: const TextStyle(
                        color: kBackground1,
                        fontWeight: FontWeight.normal,
                        fontSize: 18,
                      ),
                      children: [
                        TextSpan(
                          text: 'Regístrate',
                          style: const TextStyle(
                            color: kBackground1,
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
        ],
      ),
    );
  }
}