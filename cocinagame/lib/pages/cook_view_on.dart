import 'package:flutter/material.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/bxs.dart';
import '../constants/theme.dart';
import '../game_logic.dart';
import 'chef_transicion.dart';

class CookViewOn extends StatefulWidget {
  final Game game;
  final String clue;
  final String number;

  const CookViewOn({super.key, required this.game, required this.clue, required this.number});

  @override
  State<CookViewOn> createState() => _CookViewOnState();
}

class _CookViewOnState extends State<CookViewOn> {
  // Mantiene el estado de selección de cada palabra
  final Set<int> selectedIndices = {};
  Round get round => widget.game.currentRound;

  // ⭐ NUEVO: Aciertos por turno
  int _correctThisTurn = 0;

  // ⭐ NUEVO: Cálculo de puntuación por turno
  int _calculatePointsForCorrect(int n) {
    if (n <= 0) return 0;
    if (n == 1) return 1;
    return 5 * (n - 1); // 2→5, 3→10, 4→15, etc.
  }

  // ⭐ NUEVO: Sumar puntos, mostrar mensaje y reiniciar turno
  void _endTurnAndAwardPoints() {
    final points = _calculatePointsForCorrect(_correctThisTurn);
    if (points > 0) {
      widget.game.score += points;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ganaste $points puntos este turno. Puntaje total: ${widget.game.score}')),
      );
    }

    _correctThisTurn = 0; // reiniciar turno
  }
  // ------------------------------------------------------------

  void _showGameOverDialog() {
    _endTurnAndAwardPoints(); // ⭐ NUEVO
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Fin del juego'),
        content: Text('Te quedaste sin vidas.\nRonda alcanzada: ${widget.game.roundNumber}\nPuntos: ${widget.game.score}'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Aceptar'),
          ),
        ],
      ),
    );
  }

  void _handleTapOnCard(int index) {
    final beforeRoundNumber = widget.game.roundNumber;
    final result = widget.game.chooseCard(index);

    setState(() {
      selectedIndices.clear();
      for (int i = 0; i < round.board.length; i++) {
        if (round.board[i].revealed) {
          selectedIndices.add(i);
        }
      }
    });

    String msg;
    switch (result) {
      case SelectionResult.correct:
        msg = '¡Correcto! Esta palabra era de la receta.';
        _correctThisTurn++; // ⭐ NUEVO
        break;
      case SelectionResult.kOcultas:
        msg = 'Carta neutra, pierdes el turno.';
        break;
      case SelectionResult.wrongColor:
        msg = 'No era de la receta. Pierdes una vida.';
        break;
      case SelectionResult.exceededRecipeColor:
        msg = 'Te pasaste con ese color. Pierdes una vida.';
        break;
      case SelectionResult.black:
        msg = '¡NEGRO! Pierdes una vida.';
        break;
      case SelectionResult.alreadySelected:
        msg = 'Esa carta ya estaba seleccionada.';
        break;
    }

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

    // Si el juego terminó
    if (widget.game.isGameOver) {
      _showGameOverDialog();
      return;
    }

    // ⭐ NUEVO: Termina turno por error, exceso o carta neutra
    if (result == SelectionResult.wrongColor ||
        result == SelectionResult.exceededRecipeColor ||
        result == SelectionResult.kOcultas) {
      _endTurnAndAwardPoints();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ChefTransicion(game: widget.game),
        ),
      );
      return;
    }

    // ⭐ NUEVO: Receta completada
    if (widget.game.roundNumber > beforeRoundNumber) {
      _endTurnAndAwardPoints();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ChefTransicion(game: widget.game),
        ),
      );
      return;
    }

    // Caso correcto parcial → turno continúa
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground1,
      body: Column(
        children: [
          // HEADER (no modificado)
          Container(
            color: kPrimary,
            padding: const EdgeInsets.only(top: 60, left: 16, right: 16, bottom: 12),
            child: SizedBox(
              height: 40,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text.rich(
                      TextSpan(
                        text: 'Ronda ',
                        style: const TextStyle(color: kBackground1, fontSize: 18),
                        children: [
                          TextSpan(
                            text: '${widget.game.roundNumber}',
                            style: const TextStyle(color: kBackground1, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Center(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kSecondary,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () {},
                      child: const Text(
                        'Turno Cocinero',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // RESTO DEL CÓDIGO SIN CAMBIOS...

          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: GridView.builder(
                padding: EdgeInsets.zero,
                itemCount: round.board.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 2.2,
                ),
                itemBuilder: (context, index) {
                  final ingredient = round.board[index];
                  final isSelected = ingredient.revealed;

                  return GestureDetector(
                    onTap: () => _handleTapOnCard(index),
                    child: Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: kOcultas,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: kSecondary, width: 2),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 6, offset: Offset(0, 2))
                            ],
                          ),
                          child: Center(
                            child: Text(
                              ingredient.name,
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: kText1, fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                          ),
                        ),
                        if (isSelected)
                          Positioned(
                            top: 6,
                            right: 6,
                            child: Container(
                              width: 18,
                              height: 18,
                              decoration: BoxDecoration(
                                color: kPrimary,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 0.5),
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),

          // BOTÓN PASAR TURNO
          Container(
            color: kPrimary,
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
            child: Row(
              children: [
                Expanded(
                  flex: 4,
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Container(
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          decoration: BoxDecoration(color: kBackground2, borderRadius: BorderRadius.circular(5)),
                          child: Text(widget.clue, style: const TextStyle(color: kText1, fontSize: 18, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 1,
                        child: Container(
                          alignment: Alignment.center,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          decoration: BoxDecoration(color: kBackground2, borderRadius: BorderRadius.circular(5)),
                          child: Text(widget.number, style: const TextStyle(color: kText1, fontSize: 18, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  decoration: BoxDecoration(color: kSecondary, borderRadius: BorderRadius.circular(50)),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_forward, color: Colors.white),
                    onPressed: () {
                      widget.game.cookStops();
                      _endTurnAndAwardPoints(); // ⭐ NUEVO
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChefTransicion(game: widget.game),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _roundIcon(Color color,
      {bool isYellow = false, double circleSize = 45, double iconSize = 32}) {
    return Container(
      width: circleSize,
      height: circleSize,
      decoration: BoxDecoration(
        color: isYellow ? kSecondary : kBackground2,
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 6, offset: Offset(0, 2))],
      ),
      child: Center(
        child: Iconify(Bxs.book_heart, color: isYellow ? kBackground2 : kSecondary, size: iconSize),
      ),
    );
  }
}
