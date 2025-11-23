// lib/pages/chef_transicion.dart
import 'package:flutter/material.dart';
import '../constants/theme.dart';
import '../game_logic.dart';
import 'chef_view_on.dart';

class ChefTransicion extends StatelessWidget {
  final Game game;
  final int? puntosGanados; // <-- NUEVO: puntos ganados en el turno

  const ChefTransicion({
    super.key,
    required this.game,
    this.puntosGanados,
  });

  Round get round => game.currentRound;

  @override
  Widget build(BuildContext context) {
    final rondaActual = game.roundNumber;
    final recetasCompletadas = game.currentRoundIndex;
    final vidas = game.lives;
    final puntajeActual = game.score;
    final puntosTurno = puntosGanados ?? 0;

    return Scaffold(
      backgroundColor: kBackground1,
      body: Stack(
        children: [
          // Media elipse arriba igual que login
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
          // Texto COCINA2 sobre la elipse igual que login
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
          // Media elipse abajo (parte plana abajo, curva arriba)
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
                  // Mensaje destacado
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: kTomate,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      '¡Es el turno del Chef!',
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
                          '$puntajeActual Puntos',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        puntosTurno > 0 ? 'Ganaste +$puntosTurno Puntos' : '',
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
                      _circleInfo('Ronda', '$rondaActual'),
                      const SizedBox(width: 40),
                      _circleInfo('Recetas', '$recetasCompletadas'),
                      const SizedBox(width: 40),
                      _circleInfo('Vidas', '$vidas'),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Imagen estática de ingredientes
                  Image.asset(
                    'assets/images/transicion.png',
                    width: 300,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 30),
                  // ¿Eres el Chef?
                  const Text(
                    '¿Eres el Chef?',
                    style: TextStyle(
                      color: kText1,
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Botón grande
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 70, vertical: 10),
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
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ChefViewOn(game: game),
                            ),
                          );
                        },
                        child: const Text(
                          'Soy el Chef',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
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
