import 'package:flutter/material.dart';
import '../constants/theme.dart';
import '../game_logic.dart';
import 'chef_view_on.dart';
import 'main_menu_screen.dart';

class GameOverScreen extends StatelessWidget {
  final int ronda;
  final int recetas;
  final int vidas;
  final int puntajeTotal;
  final int puntosGanadosTurno;
  final Game? previousGame;

  const GameOverScreen({
    super.key,
    required this.ronda,
    required this.recetas,
    required this.vidas,
    required this.puntajeTotal,
    required this.puntosGanadosTurno,
    this.previousGame,
  });

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
          // Texto COCINA2 arriba
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
          // Media elipse abajo
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: 150,
              decoration: BoxDecoration(
                color: kPrimary,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.elliptical(500, 200),
                  topRight: Radius.elliptical(500, 200),
                ),
              ),
            ),
          ),
          // Contenido principal
          Positioned(
            top: 180,
            left: 0,
            right: 0,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Mensaje de Game Over
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: kText1,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      '¡Fuera de la Cocina!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Puntaje actual y puntos ganados en el turno
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                        decoration: BoxDecoration(
                          color: kCebolla,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.10),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          '$puntajeTotal Puntos',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        puntosGanadosTurno > 0 ? 'Ganaste +$puntosGanadosTurno Puntos' : '',
                        style: const TextStyle(
                          color: kText1,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Datos de ronda, recetas, vidas
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _circleInfo('Ronda', '$ronda'),
                      const SizedBox(width: 40),
                      _circleInfo('Recetas', '$recetas'),
                      const SizedBox(width: 40),
                      _circleInfo('Vidas', '$vidas'),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Imagen bowl con ingredientes de game over
                  Image.asset(
                    'assets/images/fin.png',
                    width: 300,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 10),
                  // Botón Volver a jugar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 70, vertical: 8),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kSecondary,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () async {
                          // Reinicia el juego con la misma dificultad
                          if (previousGame != null) {
                            final newGame = Game(
                              lives: 3,
                              difficulty: previousGame!.difficulty,
                              useCustomWords: previousGame!.useCustomWords,
                            );
                            await newGame.startGame();
                            if (!context.mounted) return;
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ChefViewOn(game: newGame),
                              ),
                            );
                          }
                        },
                        child: const Text(
                          'Volver a jugar',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Botón Salir
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 70, vertical: 20),
                    child: SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          side: BorderSide(color: kSecondary, width: 2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (_) => const MainMenuScreen()),
                            (route) => false,
                          );
                        },
                        child: const Text(
                          'Salir',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: kSecondary,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _circleInfo(String label, String value) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Text(
              value,
              style: const TextStyle(
                color: kPrimary,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(
            color: kText2,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}