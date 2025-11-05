// main.dart
import 'package:flutter/material.dart';
import 'game_logic.dart';

void main() {
  runApp(const CocinaGameApp());
}

class CocinaGameApp extends StatefulWidget {
  const CocinaGameApp({super.key});
  @override
  State<CocinaGameApp> createState() => _CocinaGameAppState();
}

class _CocinaGameAppState extends State<CocinaGameApp> {
  late Game game;
  bool handoverScreen = false;
  bool _loading = true;
  final TextEditingController _clueWordCtrl = TextEditingController();
  String? _status;

  @override
  void initState() {
    super.initState();
    _resetGame();
  }

  Future<void> _resetGame() async {
    setState(() {
      _loading = true;
      handoverScreen = false;
      _status = null;
      _clueWordCtrl.clear();
      game = Game(lives: 3, difficulty: Difficulty.easy);
    });

    await game.startGame(); // inicia con primera ronda (luego son infinitas)
    if (mounted) setState(() => _loading = false);
  }

  void _showSnack(String msg) => setState(() => _status = msg);
  void _toHandover() => setState(() => handoverScreen = true);
  void _fromHandover() => setState(() => handoverScreen = false);

  void _submitClue() {
    final word = _clueWordCtrl.text.trim();
    if (word.isEmpty) return _showSnack('Ingresa una pista válida.');
    game.giveClue(Clue(word, 1));
    _clueWordCtrl.clear();
    _showSnack('Pista dada: "$word"');
    _toHandover(); // pasa el teléfono
  }

  void _cookSelectCard(int index) {
    if (_loading || game.isGameOver) return;

    final res = game.chooseCard(index);

    // ¡OJO! NO restamos vidas aquí; solo mensajes/flujo.
    switch (res) {
      case SelectionResult.black:
        _showSnack('⚫ ¡Negro! Pierdes una vida.');
        break;
      case SelectionResult.correct:
        _showSnack('✅ Correcto.');
        break;
      case SelectionResult.neutral:
        _showSnack('🟡 Neutro: pierdes turno.');
        _toHandover();
        break;
      case SelectionResult.exceededRecipeColor:
      case SelectionResult.wrongColor:
        _showSnack('❌ Fallo. Pierdes una vida. Se reinicia la ronda.');
        _toHandover();
        break;
      case SelectionResult.alreadySelected:
        _showSnack('Carta ya revelada.');
        break;
    }

    if (game.isGameOver) {
      setState(() {});
      return;
    }

    // Si la ronda fue completada, el motor ya creó la siguiente.
    if (game.currentRound.finished && game.currentRound.recipe.isCompleted) {
      _showSnack('🎉 ¡Ronda superada!');
      _toHandover();
    }

    setState(() {});
  }

  void _cookStops() {
    if (_loading) return;

    game.cookStops(); // NO quita vidas; solo cambia turno (o avanza si estaba completa)

    if (game.isGameOver) {
      _showSnack('💀 Juego terminado');
      setState(() {});
      return;
    }

    _showSnack('✋ El cocinero se plantó.');
    _toHandover(); // vuelve al Chef para nueva pista
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (_loading || game.rounds.isEmpty) {
      return const MaterialApp(
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 12),
                Text('Preparando la cocina...'),
              ],
            ),
          ),
        ),
      );
    }

    if (game.isGameOver) {
      return MaterialApp(
        home: Scaffold(
          backgroundColor: Colors.black,
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  '💀 Juego terminado',
                  style: TextStyle(color: Colors.white, fontSize: 24),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'Rondas alcanzadas: ${game.roundNumber}',
                  style: const TextStyle(color: Colors.white70, fontSize: 16),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  icon: const Icon(Icons.restart_alt),
                  label: const Text('Reiniciar'),
                  onPressed: _resetGame,
                ),
              ],
            ),
          ),
        ),
      );
    }

    final round = game.currentRound;
    Widget body;

    if (handoverScreen) {
      body = Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              round.isChefTurn
                  ? '📱 Pasa el teléfono al Chef 👨‍🍳'
                  : '📱 Pasa el teléfono al Cocinero 👨‍🍳',
              style: const TextStyle(fontSize: 22),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _fromHandover, child: const Text('Listo')),
          ],
        ),
      );
    } else if (round.isChefTurn) {
      final recipe = round.recipe;
      body = SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Ronda ${game.roundNumber} — Turno del Chef',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text('Vidas: ${game.lives}'),
            const SizedBox(height: 12),

            // === Receta actual ===
            Card(
              color: Colors.yellow.shade50,
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('📜 Receta actual:',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    if (recipe.required.isEmpty)
                      const Text('— (sin requisitos) —')
                    else
                      ...recipe.required.entries.map((e) {
                        final color = _colorFor(e.key);
                        return Row(
                          children: [
                            Container(width: 20, height: 20, color: color),
                            const SizedBox(width: 8),
                            Text('${e.key.name} → ${e.value} restantes',
                                style: const TextStyle(fontSize: 16)),
                          ],
                        );
                      }),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: List.generate(round.board.length, (i) {
                final ing = round.board[i];
                final color = _colorFor(ing.color);
                return Container(
                  width: 110,
                  height: 60,
                  decoration: BoxDecoration(
                    color: ing.revealed ? Colors.grey.shade400 : color,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Text(
                    ing.name,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: ing.revealed ? Colors.black87 : Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: Text('Dar pista', style: Theme.of(context).textTheme.titleMedium),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _clueWordCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Palabra',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: _submitClue,
                  icon: const Icon(Icons.campaign),
                  label: const Text('Dar pista'),
                ),
              ],
            ),
          ],
        ),
      );
    } else {
      final clue = round.activeClue;
      body = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Ronda ${game.roundNumber} — Turno del Cocinero',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text('Vidas: ${game.lives}', textAlign: TextAlign.center),
          const SizedBox(height: 6),
          if (clue != null) Text('Pista: "${clue.word}"', textAlign: TextAlign.center),
          const SizedBox(height: 12),
          Expanded(
            child: SingleChildScrollView(
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: List.generate(round.board.length, (i) {
                  final ing = round.board[i];
                  final revealed = ing.revealed;
                  return GestureDetector(
                    onTap: revealed ? null : () => _cookSelectCard(i),
                    child: Container(
                      width: 110,
                      height: 60,
                      decoration: BoxDecoration(
                        color: revealed ? Colors.grey.shade300 : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          width: 2,
                          color: revealed ? Colors.grey : Colors.black26,
                        ),
                      ),
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: Text(
                        ing.name,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.black87,
                          fontWeight: revealed ? FontWeight.w600 : FontWeight.w500,
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              OutlinedButton.icon(
                onPressed: _cookStops,
                icon: const Icon(Icons.stop_circle_outlined),
                label: const Text('Plantarse'),
              ),
            ],
          ),
        ],
      );
    }

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Juego de Cocina 👨‍🍳'),
          actions: [
            IconButton(
              icon: const Icon(Icons.restart_alt),
              tooltip: 'Reiniciar',
              onPressed: _resetGame,
            ),
          ],
        ),
        body: Padding(padding: const EdgeInsets.all(16.0), child: body),
        bottomNavigationBar: (_status == null)
            ? null
            : Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.black.withOpacity(0.85)),
                child: Text(
                  _status!,
                  style: const TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ),
      ),
    );
  }

  Color _colorFor(IngredientColor c) {
    switch (c) {
      case IngredientColor.red:
        return Colors.red;
      case IngredientColor.blue:
        return Colors.blue;
      case IngredientColor.green:
        return Colors.green;
      case IngredientColor.yellow:
        return Colors.yellow[700]!;
      case IngredientColor.purple:
        return Colors.purple;
      case IngredientColor.neutral:
        return Colors.orange;
      case IngredientColor.black:
        return Colors.black;
    }
  }
}
