// lib/pages/chef_transicion.dart
import 'package:flutter/material.dart';
import '../constants/theme.dart';
import '../game_logic.dart';
import 'chef_view_on.dart';

class ChefTransicion extends StatelessWidget {
  final Game game;

  const ChefTransicion({super.key, required this.game});

  Round get round => game.currentRound;

  @override
  Widget build(BuildContext context) {
    final rondaActual = game.roundNumber;
    final recetasCompletadas = game.currentRoundIndex; // 0 en ronda 1, 1 en ronda 2, etc.
    final esTurnoChef = round.isChefTurn;

    // Colores que componen la receta (sin repetir)
    final recetaColors = round.recipe.required.keys.toList();

    // Ingredientes que faltan (color + cantidad > 0)
    final faltantes = round.recipe.required.entries
        .where((e) => e.value > 0)
        .toList();

    return Scaffold(
      backgroundColor: kBackground1,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Card(
            color: kBackground2,
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Transición de turno',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: kText1,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Info principal
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _infoChip('Ronda', '$rondaActual'),
                      _infoChip('Recetas\ncompletadas', '$recetasCompletadas'),
                      _infoChip('Vidas', '${game.lives}'),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // A quién le toca
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: kPrimary.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      esTurnoChef
                          ? 'Le toca al CHEF'
                          : 'Le toca al COCINERO (pero estás en pantalla de transición del Chef)',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: kText1,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Receta actual (solo qué colores participan)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Receta actual (colores involucrados):',
                      style: const TextStyle(
                        color: kText1,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  if (recetaColors.isEmpty)
                    const Text(
                      'Sin información de receta para esta ronda.',
                      style: TextStyle(color: kText2, fontSize: 13),
                    )
                  else
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: recetaColors
                          .map((c) => Chip(
                                label: Text(
                                  _colorName(c),
                                  style: TextStyle(
                                    color: c == IngredientColor.kOcultas
                                        ? kText1
                                        : kBackground2,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                backgroundColor: _ingredientBgColor(c),
                              ))
                          .toList(),
                    ),

                  const SizedBox(height: 16),

                  // Ingredientes que faltan
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Ingredientes que faltan:',
                      style: const TextStyle(
                        color: kText1,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  if (faltantes.isEmpty)
                    const Text(
                      'No falta ningún ingrediente.\n¡La receta está completa!',
                      style: TextStyle(color: kText2, fontSize: 13),
                    )
                  else
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: faltantes
                          .map(
                            (e) => Chip(
                              label: Text(
                                '${_colorName(e.key)} x${e.value}',
                                style: TextStyle(
                                  color: e.key == IngredientColor.kOcultas
                                      ? kText1
                                      : kBackground2,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              backgroundColor: _ingredientBgColor(e.key),
                            ),
                          )
                          .toList(),
                    ),

                  const SizedBox(height: 24),

                  // Botón continuar
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kSecondary,
                        foregroundColor: kBackground2,
                        padding: const EdgeInsets.symmetric(vertical: 14),
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
                        'Continuar al turno del Chef',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _infoChip(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: kText2,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: kSecondary.withOpacity(0.15),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            value,
            style: const TextStyle(
              color: kText1,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  String _colorName(IngredientColor c) {
    switch (c) {
      case IngredientColor.kBeterraga:
        return 'Betarraga';
      case IngredientColor.kCebolla:
        return 'Cebolla';
      case IngredientColor.kChampinon:
        return 'Champiñón';
      case IngredientColor.kPimenton:
        return 'Pimentón';
      case IngredientColor.kTomate:
        return 'Tomate';
      case IngredientColor.kZanahoria:
        return 'Zanahoria';
      case IngredientColor.kOcultas:
        return 'Neutro';
      case IngredientColor.black:
        return 'Negro';
    }
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
      case IngredientColor.kZanahoria:
        return kZanahoria;
      case IngredientColor.kOcultas:
        return kOcultas;
      case IngredientColor.black:
        return Colors.black87;
    }
  }
}
