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
  final Set<int> selectedIndices = {};
  Round get round => widget.game.currentRound;

  int _correctThisTurn = 0;

  int _calculatePointsForCorrect(int n) {
    if (n <= 0) return 0;
    if (n == 1) return 1;
    return 5 * (n - 1);
  }

  void _endTurnAndAwardPoints() {
    final points = _calculatePointsForCorrect(_correctThisTurn);
    if (points > 0) {
      widget.game.score += points;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ganaste $points puntos este turno. Puntaje total: ${widget.game.score}')),
      );
    }
    _correctThisTurn = 0;
  }

  void _showGameOverDialog() {
    _endTurnAndAwardPoints();
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
        _correctThisTurn++;
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

    if (widget.game.isGameOver) {
      _showGameOverDialog();
      return;
    }

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
  }

  @override
  Widget build(BuildContext context) {
    final board = round.board;

    return Scaffold(
      backgroundColor: kBackground1,
      body: Column(
        children: [
          // HEADER con botón regresar, texto y puntaje alineado a la derecha
          Container(
            color: kPrimary,
            padding: const EdgeInsets.only(top: 55, left: 16, right: 16, bottom: 10),
            child: SizedBox(
              height: 60,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: kBackground1, size: 32),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  Center(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kSecondary,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 0),
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

          // FILA de vidas
           Container(
            color: kBackground1,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween, // <-- separa los extremos
              children: [
                // Íconos de ronda alineados a la izquierda
                Row(
                  children: [
                    _roundIcon(kSecondary, isYellow: true),
                    const SizedBox(width: 10),
                    _roundIcon(kSecondary, isYellow: true),
                    const SizedBox(width: 10),
                    _roundIcon(kSecondary, isYellow: true),
                  ],
                ),
                // Contenedor de puntaje alineado a la derecha
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  height: 40,
                  decoration: BoxDecoration(
                    color: kCebolla,
                    borderRadius: BorderRadius.circular(50),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.10),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      '${widget.game.score} PUNTOS', // <-- muestra el puntaje
                      style: const TextStyle(
                        color: kBackground1,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Receta
          _buildRecipeSummary(),

          // Grid de palabras con imágenes reveladas
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

                  String imageName(IngredientColor c) {
                    switch (c) {
                      case IngredientColor.kBeterraga:
                        return 'betarraga.png';
                      case IngredientColor.kCebolla:
                        return 'cebolla.png';
                      case IngredientColor.kChampinon:
                        return 'champiñon.png';
                      case IngredientColor.kPimenton:
                        return 'pimenton.png';
                      case IngredientColor.kTomate:
                        return 'tomate.png';
                      case IngredientColor.kZanahoria:
                        return 'zanahoria.png';
                      case IngredientColor.kOcultas:
                        return 'plato.png';
                      case IngredientColor.black:
                        return 'bomba.png';
                    }
                  }

                  Color ingredientBorderColor(IngredientColor c) {
                    switch (c) {
                      case IngredientColor.kBeterraga:
                        return kBeterraga;
                      case IngredientColor.kCebolla:
                        return kCebolla;
                      case IngredientColor.kChampinon:
                        return kChampinon;
                      case IngredientColor.kPimenton:
                        return kPimenton;
                      case IngredientColor.kTomate:
                        return kTomate;
                      case IngredientColor.kZanahoria:
                        return kZanahoria;
                      case IngredientColor.kOcultas:
                        return kOcultas;
                      case IngredientColor.black:
                        return Colors.black87;
                    }
                  }

                  return GestureDetector(
                    onTap: () => _handleTapOnCard(index),
                    child: Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: isSelected
                                ? kBackground1 // fondo blanco si revelado
                                : kOcultas,    // fondo ocultas si no revelado
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? ingredientBorderColor(ingredient.color) // borde según ingrediente si revelado
                                  : kSecondary, // borde normal si no revelado
                              width: 3,
                            ),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 6, offset: Offset(0, 2))
                            ],
                          ),
                          child: Center(
                            child: isSelected
                                ? Image.asset(
                                    'assets/images/${imageName(ingredient.color)}',
                                    width: 40,
                                    height: 40,
                                    fit: BoxFit.contain,
                                  )
                                : Text(
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
                      _endTurnAndAwardPoints();
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

  Widget _buildRecipeSummary() {
    final required = round.recipe.required;
    if (required.isEmpty) return const SizedBox.shrink();

    String imageName(IngredientColor c) {
      switch (c) {
        case IngredientColor.kBeterraga:
          return 'betarraga.png';
        case IngredientColor.kCebolla:
          return 'cebolla.png';
        case IngredientColor.kChampinon:
          return 'champiñon.png';
        case IngredientColor.kPimenton:
          return 'pimenton.png';
        case IngredientColor.kTomate:
          return 'tomate.png';
        case IngredientColor.kZanahoria:
          return 'zanahoria.png';
        case IngredientColor.kOcultas:
          return 'plato.png';
        case IngredientColor.black:
          return 'bomba.png';
      }
    }

    final entries = required.entries.toList();
    final difficulty = widget.game.difficulty;

    List<List<MapEntry<IngredientColor, int>>> rows;

    if (difficulty == Difficulty.hard && entries.length > 3) {
      rows = [
        entries.sublist(0, 3),
        entries.sublist(3),
      ];
    } else {
      rows = [entries];
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: rows.map((rowEntries) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: rowEntries.map((entry) {
              final color = entry.key;
              final count = entry.value;
              final img = imageName(color);

              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _ingredientBgColor(color),
                  borderRadius: BorderRadius.circular(50),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'assets/images/$img',
                      width: 40,
                      height: 40,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      'x$count',
                      style: const TextStyle(
                        color: kBackground1,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          );
        }).toList(),
      ),
    );
  }

  Color _ingredientBgColor(IngredientColor c) {
    switch (c) {
      case IngredientColor.kBeterraga:
        return kBeterraga;
      case IngredientColor.kCebolla:
        return kCebolla;
      case IngredientColor.kChampinon:
        return kChampinon;
      case IngredientColor.kPimenton:
        return kPimenton;
      case IngredientColor.kTomate:
        return kTomate;
      case IngredientColor.kOcultas:
        return kOcultas;
      case IngredientColor.kZanahoria:
        return kZanahoria;
      case IngredientColor.black:
        return Colors.black87;
    }
  }

  Widget _roundIcon(Color color, {bool isYellow = false, double circleSize = 40, double iconSize = 28}) {
    return Container(
      width: circleSize,
      height: circleSize,
      decoration: BoxDecoration(
        color: isYellow ? kSecondary : kBackground2,
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Center(
        child: Iconify(Bxs.book_heart, color: isYellow ? kBackground2 : kSecondary, size: iconSize),
      ),
    );
  }

  String _imageName(IngredientColor c) {
    switch (c) {
      case IngredientColor.kBeterraga:
        return 'betarraga.png';
      case IngredientColor.kCebolla:
        return 'cebolla.png';
      case IngredientColor.kChampinon:
        return 'champiñon.png';
      case IngredientColor.kPimenton:
        return 'pimenton.png';
      case IngredientColor.kTomate:
        return 'tomate.png';
      case IngredientColor.kZanahoria:
        return 'zanahoria.png';
      case IngredientColor.kOcultas:
        return 'plato.png';
      case IngredientColor.black:
        return 'bomba.png';
    }
  }
}
