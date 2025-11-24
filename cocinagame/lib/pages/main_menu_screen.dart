import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:cocinagame/constants/theme.dart';
import 'package:cocinagame/main_nav_bar.dart';
import 'package:cocinagame/services/auth_service.dart';

// Funcionalidad del juego
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
  bool _isLoggingOut = false;

  @override
  void initState() {
    super.initState();

    // 🔒 Usuario NO logueado → enviar al login
    if (FirebaseAuth.instance.currentUser == null) {
      Future.microtask(() {
        Navigator.pushReplacementNamed(context, '/login');
      });
    }
  }

  Future<void> _logoutUser() async {
    setState(() => _isLoggingOut = true);
    try {
      await AuthService().logout();
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cerrar sesión: ${e.toString().replaceFirst('Exception: ', '')}')),
      );
    } finally {
      if (!mounted) return;
      setState(() => _isLoggingOut = false);
    }
  }

  // ⭐ Navegación inferior
  void _onNavTap(int index) {
    setState(() => _selectedIndex = index);

    if (index == 0) {
      Navigator.pushNamed(context, '/menu');
    } else if (index == 1) {
      Navigator.pushNamed(context, '/palabras');
    } else if (index == 2) {
      Navigator.pushNamed(context, '/clasificaciones');
    } else if (index == 3) {
      Navigator.pushNamed(context, '/comojugar');
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: kBackground1,

        // ⭐ AppBar moderna
        appBar: AppBar(
          backgroundColor: kPrimary,
          elevation: 3,
          centerTitle: true,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.elliptical(400, 90),
              bottomRight: Radius.elliptical(400, 90),
            ),
          ),
          title: const Text(
            'Menú Principal',
            style: TextStyle(
              color: kBackground1,
              fontWeight: FontWeight.bold,
              fontSize: 26,
            ),
          ),
          actions: [
            IconButton(
              icon: _isLoggingOut
                  ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: kBackground1, strokeWidth: 2))
                  : const Icon(Icons.logout, color: kBackground1),
              onPressed: _isLoggingOut ? null : () => _logoutUser(),
            ),
          ],
        ),

        // ⭐ CONTENIDO MODERNO + FUNCIONALIDAD DE JUEGO
        body: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 40),

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

              const SizedBox(height: 25),

              const Text(
                "¡Bienvenido!",
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: kText1,
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                "Selecciona una opción en la barra inferior",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  color: kPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 40),

              // ⭐ BOTÓN JUGAR (funcionalidad original fusionada)
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: kSecondary,
                  minimumSize: const Size(220, 55),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => GameConfigDialog(
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
                  "Jugar",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: kBackground1,
                  ),
                ),
              ),

              const SizedBox(height: 30),

              TextButton(
                onPressed: _isLoggingOut ? null : () => _logoutUser(),
                child: const Text(
                  "Cerrar sesión",
                  style: TextStyle(
                    color: kPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),

        // ⭐ BARRA DE NAVEGACIÓN INFERIOR
        bottomNavigationBar: MainNavBar(
          currentIndex: _selectedIndex,
          onTap: _onNavTap,
        ),
      ),
    );
  }
}
