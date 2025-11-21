import 'package:flutter/material.dart';
import '../constants/theme.dart';
import '../main_nav_bar.dart';
import '../game_logic.dart';
import 'chef_view_on.dart';
import 'game_config_dialog.dart';

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
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kSecondary,
                    minimumSize: const Size(290, 50),
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
                            difficulty: difficulty, // <-- aquí se pasa la dificultad seleccionada
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