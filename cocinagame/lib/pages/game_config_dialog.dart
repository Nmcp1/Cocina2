import 'package:flutter/material.dart';
import 'dart:ui';
import '../constants/theme.dart';
import '../game_logic.dart';

class GameConfigDialog extends StatefulWidget {
  final void Function(Difficulty difficulty, bool useCustomWords) onConfirm;

  const GameConfigDialog({super.key, required this.onConfirm});

  @override
  State<GameConfigDialog> createState() => _GameConfigDialogState();
}

class _GameConfigDialogState extends State<GameConfigDialog> {
  Difficulty _selectedDifficulty = Difficulty.easy;
  bool _useCustomWords = false;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Blur de fondo
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
              child: Container(
                color: Colors.black.withOpacity(0.05), // opcional: leve oscurecimiento
              ),
            ),
          ),
          // Modal principal
          Container(
            decoration: BoxDecoration(
              color: kBackground1,
              borderRadius: BorderRadius.circular(18),
            ),
            padding: const EdgeInsets.fromLTRB(14, 48, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Dificultad
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Dificultad',
                      style: TextStyle(fontSize: 18, color: kText1),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _difficultyButton('Fácil', Difficulty.easy, kSecondary),
                        _difficultyButton('Media', Difficulty.medium, kPimenton),
                        _difficultyButton('Difícil', Difficulty.hard, kPrimary),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Palabras personalizadas
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Palabras personalizadas', style: TextStyle(fontSize: 18, color: kText1)),
                    Switch(
                      value: _useCustomWords,
                      activeThumbColor: kSecondary,
                      inactiveThumbColor: kChampinon,
                      onChanged: (val) => setState(() => _useCustomWords = val),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                // Botones
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kBackground1,
                        side: BorderSide(color: kSecondary, width: 2),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Volver',
                        style: TextStyle(
                          color: kSecondary,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kSecondary,
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {
                        widget.onConfirm(_selectedDifficulty, _useCustomWords);
                        Navigator.pop(context);
                      },
                      child: const Text(
                        'Jugar',
                        style: TextStyle(
                          color: kBackground1,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Título sobresaliente
          Positioned(
            top: -32,
            left: 0,
            right: 0,
            child: Center(
              child: Material(
                color: kPrimary,
                borderRadius: BorderRadius.circular(12),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 32),
                  child: Text(
                    'Configurar partida',
                    style: const TextStyle(
                      color: kBackground1,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _difficultyButton(String label, Difficulty value, Color color) {
    final bool selected = _selectedDifficulty == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedDifficulty = value),
      child: Container(
        constraints: const BoxConstraints(minWidth: 80, maxWidth: 100), // ancho fijo y pequeño
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8), // menos espacio interno
        decoration: BoxDecoration(
          color: selected ? color : kBackground1,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: color, width: 2),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: selected ? kBackground1 : color,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
      ),
    );
  }
}