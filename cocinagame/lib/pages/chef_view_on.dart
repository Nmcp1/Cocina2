import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/bxs.dart';
import 'package:iconify_flutter/icons/mdi.dart';
import '../constants/theme.dart';
import '../game_logic.dart';
import 'cook_transicion.dart';

class ChefViewOn extends StatefulWidget {
  final Game game;

  const ChefViewOn({super.key, required this.game});

  @override
  State<ChefViewOn> createState() => _ChefViewOnState();
}

class _ChefViewOnState extends State<ChefViewOn> {
  bool _showOcultas = false;
  final TextEditingController _clueController = TextEditingController();
  final TextEditingController _numberController = TextEditingController();

  Round get round => widget.game.currentRound;

  // ⛔ Esta lista ya NO define el color lógico, solo la podrías borrar si quieres
  final List<Color> wordColorsOriginal = [kSecondary, kSecondary, kSecondary, kBeterraga, kCebolla, kCebolla, kCebolla, kOcultas, kBeterraga, kOcultas, kSecondary, kBeterraga, kBeterraga, kCebolla, kText1, kSecondary, kSecondary, kOcultas, kBeterraga, kCebolla, kOcultas, kSecondary, kSecondary, kSecondary];

  @override
  Widget build(BuildContext context) {
    final board = round.board;
    final int visibleCount = board.length;

    return Scaffold(
      backgroundColor: kBackground1,
      body: Column(
        children: [
          // HEADER
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
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kSecondary,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 0),
                          ),
                          onPressed: () {},
                          child: const Text(
                            'Turno Chef',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _showOcultas = !_showOcultas;
                        });
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: kBackground1,
                          shape: BoxShape.circle,
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 6, offset: const Offset(0, 2))],
                        ),
                        child: Center(child: Iconify(_showOcultas ? Mdi.eye_off : Mdi.eye, color: kSecondary, size: 32)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // FILA 2
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

          // Receta (igual que antes si quieres mantenerla)
          _buildRecipeSummary(),

          // 🔥 Grid de palabras — AHORA basado en Ingredient.color
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: GridView.builder(
                padding: EdgeInsets.zero,
                itemCount: visibleCount,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, mainAxisSpacing: 16, crossAxisSpacing: 16, childAspectRatio: 2.2),
                itemBuilder: (context, index) {
                  final ingredient = board[index];
                  final IngredientColor ingColor = ingredient.color;

                  final bool hideColors = _showOcultas;
                  final Color bgColor = hideColors ? kBackground2 : _ingredientBgColor(ingColor);
                  final Color textColor = hideColors ? kText1 : (ingColor == IngredientColor.kOcultas ? kText1 : kBackground2);
                  final Color borderColor = hideColors ? kSecondary : Colors.transparent;

                  return Container(
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: borderColor, width: 2),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 6, offset: const Offset(0, 2))],
                    ),
                    child: Center(
                      child: Text(
                        ingredient.name,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // INPUT DE PISTA + NÚMERO (igual que ya tenías)
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
                        child: TextField(
                          controller: _clueController,
                          decoration: InputDecoration(
                            hintText: 'Ingrese la pista',
                            hintStyle: const TextStyle(color: kText2),
                            filled: true,
                            fillColor: kBackground2,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(5), borderSide: BorderSide.none),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 1,
                        child: TextField(
                          controller: _numberController,
                          decoration: InputDecoration(
                            hintText: 'Nº',
                            hintStyle: const TextStyle(color: kText2),
                            filled: true,
                            fillColor: kBackground2,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(5), borderSide: BorderSide.none),
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
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
                      final clueText = _clueController.text.trim();
                      final numberText = _numberController.text.trim();

                      if (clueText.isEmpty || numberText.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Debes ingresar la pista y el número.')),
                        );
                        return;
                      }

                      final qty = int.tryParse(numberText);
                      if (qty == null || qty <= 0) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('El número debe ser un entero positivo.')),
                        );
                        return;
                      }

                      // Enviar la pista al modelo
                      widget.game.giveClue(Clue(clueText, qty));

                      // Ir a la pantalla de transición hacia el Cocinero
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CookTransicion(
                            game: widget.game,
                            clue: clueText,
                            number: numberText,
                          ),
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

  // ============ helpers =============

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
      // Tres arriba, el resto abajo
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
}
