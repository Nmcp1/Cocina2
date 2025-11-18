import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/bxs.dart';
import 'package:iconify_flutter/icons/mdi.dart';
import '../constants/theme.dart';
import '../game_logic.dart';
import 'cook_view_on.dart';
import 'cook_transicion.dart';

class ChefViewOn extends StatefulWidget {
  final Game game;

  const ChefViewOn({super.key, required this.game});

  @override
  State<ChefViewOn> createState() => _ChefViewOnState();
}

class _ChefViewOnState extends State<ChefViewOn> {
  bool _showOcultas = false; // true = ocultar colores (no las palabras)
  String _clue = '';
  String _number = '';
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

          // FILA 2 (iconos, timer, etc) — igual que lo tenías
          Container(
            color: kBackground1,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                _roundIcon(kSecondary, isYellow: true),
                const SizedBox(width: 10),
                _roundIcon(kSecondary, isYellow: true),
                const SizedBox(width: 10),
                _roundIcon(kSecondary, isYellow: true),
                const SizedBox(width: 22),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(color: kCebolla, borderRadius: BorderRadius.circular(16)),
                  child: const Text(
                    '05:00',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                const SizedBox(width: 36),
                Container(
                  width: 48,
                  height: 40,
                  decoration: BoxDecoration(
                    color: kBackground2,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.10), blurRadius: 4, offset: const Offset(0, 2))],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Iconify(kBowl, size: 32, color: kPrimary),
                      const SizedBox(width: 2),
                      Text(
                        '${widget.game.currentRoundIndex}',
                        style: TextStyle(color: kText1, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 48,
                  height: 40,
                  decoration: BoxDecoration(
                    color: kBackground2,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.10), blurRadius: 4, offset: const Offset(0, 2))],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.track_changes, color: kSecondary, size: 22),
                      SizedBox(width: 2),
                      Text(
                        '${widget.game.roundNumber}', // Aquí se utiliza el número de ronda dinámicamente
                        style: TextStyle(color: kText1, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ],
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

    String colorName(IngredientColor c) {
      switch (c) {
        case IngredientColor.kBeterraga:
          return 'Betarraga';
        case IngredientColor.kCebolla:
          return 'Cebolla';
        case IngredientColor.kChampinon:
          return 'Champinon';
        case IngredientColor.kPimenton:
          return 'Pimenton';
        case IngredientColor.kTomate:
          return 'Tomate';
        case IngredientColor.kOcultas:
          return 'Neutro';
        case IngredientColor.kZanahoria:
          return "Zanahoria";
        case IngredientColor.black:
          return 'Negro';
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Receta de esta ronda:',
            style: TextStyle(color: kText1, fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: required.entries.map((entry) {
              final color = entry.key;
              final count = entry.value;
              final bg = _ingredientBgColor(color);

              return Chip(
                label: Text(
                  '${colorName(color)} x$count',
                  style: TextStyle(color: color == IngredientColor.kOcultas ? kText1 : kBackground2, fontWeight: FontWeight.w600),
                ),
                backgroundColor: bg,
              );
            }).toList(),
          ),
        ],
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
