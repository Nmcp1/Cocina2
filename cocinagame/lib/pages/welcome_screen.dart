import 'package:flutter/material.dart';
import 'package:cocinagame/constants/theme.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

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
              height: 180,
              decoration: BoxDecoration(
                color: kPrimary,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.elliptical(400, 250),
                  bottomRight: Radius.elliptical(400, 250),
                ),
              ),
            ),
          ),

          // TÍTULO SUPERIOR
          Positioned(
            top: 65,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                "COCINA2",
                style: const TextStyle(
                  fontSize: 48,
                  color: kBackground1,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          // CONTENIDO CENTRAL
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 160),

                  // LOGO CIRCULAR
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

                  const SizedBox(height: 30),

                  const Text(
                    "Bienvenido",
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: kText1,
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
                    onPressed: () {
                      Navigator.pushNamed(context, '/login');
                    },
                    child: const Text(
                      "Iniciar Sesión",
                      style: TextStyle(
                        fontSize: 22,
                        color: kBackground1,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  // BOTÓN REGISTRO
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(200, 50),
                      side: const BorderSide(color: kPrimary, width: 2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pushNamed(context, '/register');
                    },
                    child: const Text(
                      "Registrarse",
                      style: TextStyle(
                        fontSize: 22,
                        color: kPrimary,
                        fontWeight: FontWeight.bold,
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
