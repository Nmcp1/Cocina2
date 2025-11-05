import 'package:flutter/material.dart';
import '../constants/theme.dart';
import '../main_nav_bar.dart';

class MainMenuScreen extends StatefulWidget {
  const MainMenuScreen({super.key});

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen> {
  int _selectedIndex = 0;

  void _onNavTap(int index) {
    setState(() {
      _selectedIndex = index;
      if (index == 0) {
        Navigator.pushNamed(context, '/menu');
      } else if (index == 1) {
        Navigator.pushNamed(context, '/palabras');
      } else if (index == 2) {
        Navigator.pushNamed(context, '/clasificaciones');
      } else if (index == 3) {
        Navigator.pushNamed(context, '/comojugar');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kTomate,
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
                const SizedBox(height: 100),
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
                    Navigator.pushNamed(context, '/chef');
                  },
                  child: const Text(
                    'Jugar',
                    style: TextStyle(fontSize: 22, color: kBackground2, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: MainNavBar(
        currentIndex: _selectedIndex,
        onTap: _onNavTap,
      ),
    );
  }
}