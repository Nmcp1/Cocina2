import 'package:flutter/material.dart';
import '../constants/theme.dart';

class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});

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
          // Contenido centrado
          Align(
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Trofeo arriba del logo
                Container(
                  margin: const EdgeInsets.only(bottom: 30),
                  decoration: BoxDecoration(
                    color: kBackground1,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.all(8),
                  child: Icon(
                    Icons.emoji_events,
                    color: kSecondary,
                    size: 32,
                  ),
                ),
                // Logo circular
                ClipOval(
                  child: SizedBox(
                    width: 220,
                    height: 220,
                    child: Image.asset(
                      'assets/images/logo_cocina2.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                // Botón Jugar
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kSecondary,
                    minimumSize: const Size(290, 50),
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pushNamed(context, '/chef'); // Navega a la vista chef_view_on
                  },
                  child: const Text(
                    'Jugar',
                    style: TextStyle(fontSize: 22, color: kBackground2, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 30),
                // Botón Palabras personalizadas
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kSecondary,
                    minimumSize: const Size(260, 50),
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    // Acción palabras personalizadas
                  },
                  child: const Text(
                    'Palabras personalizadas',
                    style: TextStyle(fontSize: 22, color: kBackground2, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 30),
                // Botón Cómo jugar
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kBackground1,
                    minimumSize: const Size(290, 50),
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: kSecondary)
                    ),
                  ),
                  onPressed: () {
                    // Acción cómo jugar
                  },
                  child: const Text(
                    'Cómo jugar',
                    style: TextStyle(fontSize: 22, color: kSecondary, fontWeight: FontWeight.bold),
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