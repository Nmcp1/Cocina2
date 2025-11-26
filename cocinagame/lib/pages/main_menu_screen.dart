import 'package:flutter/material.dart';
import '../constants/theme.dart';
import '../main_nav_bar.dart';
import '../game_logic.dart';
import 'chef_view_on.dart';
import 'game_config_dialog.dart';
import 'package:cocinagame/services/auth_service.dart';


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
        Navigator.pushNamed(context, '/top');
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
                const SizedBox(height: 85),
                ClipOval(
                  child: SizedBox(
                    width: 250,
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
                  onPressed: () async {
                    showDialog(
                      context: context,
                      builder: (context) => GameConfigDialog(
                        onConfirm: (difficulty, useCustomWords) async {
                          final game = Game(
                            lives: 3,
                            difficulty: difficulty,
                            useCustomWords: useCustomWords,
                          );
                          try {
                            await game.startGame();
                          } catch (e) {
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error al iniciar el juego: $e')),
                            );
                            return;
                          }
                          if (!context.mounted) return;
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ChefViewOn(game: game),
                            ),
                          );
                        },
                      ),
                    );
                  },
                  child: const Text(
                    'Jugar',
                    style: TextStyle(fontSize: 24, color: kBackground2, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 40),
                TextButton(
                  onPressed: () async {
                    try {
                      await AuthService().signOut(); // cerrar sesión Firebase

                      if (!context.mounted) return;

                      // 👇 Ir a la ruta base y limpiar todo el stack
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/',
                        (route) => false,
                      );
                    } catch (e) {
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error al cerrar sesión: $e')),
                      );
                    }
                  },
                  child: const Text(
                    'Cerrar sesión',
                    style: TextStyle(
                      color: kBackground1,
                      fontSize: 18,
                    ),
                  ),
                )

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