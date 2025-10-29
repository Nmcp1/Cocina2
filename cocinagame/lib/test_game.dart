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
  bool handoverScreen = false; // Pantalla "pasa el teléfono"
  final TextEditingController _clueWordCtrl = TextEditingController();
  int _clueQty = 1;
  String? _status; // mensajes breves de estado (última acción)

  @override
  void initState() {
    super.initState();
    game = Game(lives: 3, difficulty: Difficulty.easy);
    game.startGame(roundCount: 5);
  }

  @override
  void dispose() {
    _clueWordCtrl.dispose();
    super.dispose();
  }

  void _showSnack(String msg) {
    setState(() => _status = msg);
  }

  void _toHandover() {
    setState(() {
      handoverScreen = true;
    });
  }

  void _fromHandover() {
    // Sale de pantalla de entrega y CONTINÚA el turno que corresponda
    setState(() {
      handoverScreen = false;
    });
  }

  void _submitClue() {
    final word = _clueWordCtrl.text.trim();
    final qty = _clueQty;
    if (word.isEmpty || qty < 1) {
      _showSnack('Ingresa una pista válida (palabra y cantidad >= 1)');
      return;
    }
    game.giveClue(Clue(word, qty));
    _clueWordCtrl.clear();
    _showSnack('Pista dada: "$word" $qty');
    _toHandover(); // pasar el teléfono al Cocinero
  }

  void _cookSelectCard(int index) {
    if (game.isGameOver) return;
    final res = game.chooseCard(index);

    switch (res) {
      case SelectionResult.black:
        _showSnack('⚫ ¡Negro! Fin del juego.');
        break;
      case SelectionResult.correct:
        _showSnack('✅ Correcto.');
        break;
      case SelectionResult.neutral:
        _showSnack('🟡 Neutro: pierdes el turno.');
        _toHandover(); // vuelve al Chef
        break;
      case SelectionResult.exceededRecipeColor:
        _showSnack('🚫 Exceso de color de receta. -1 vida, cambia la receta.');
        _toHandover();
        break;
      case SelectionResult.wrongColor:
        _showSnack('❌ Color incorrecto. -1 vida, cambia la receta.');
        _toHandover();
        break;
      case SelectionResult.alreadySelected:
        _showSnack('Carta ya revelada.');
        break;
    }

    if (!game.isGameOver && game.currentRound.finished) {
      // Ronda superada -> si no hay más rondas, el propio Game marca fin
      if (!game.isGameOver) {
        _showSnack('🎉 ¡Ronda superada! Avanzando…');
        _toHandover(); // entrega al Chef para nueva pista en próxima ronda
      }
    }

    setState(() {}); // refresca tablero/vidas/picks
  }

  void _cookStops() {
    game.cookStops(); // termina su turno sin gastar todos los picks
    _showSnack('✋ El cocinero se plantó.');
    _toHandover(); // vuelve al Chef
  }

  @override
  Widget build(BuildContext context) {
    if (game.isGameOver) {
      final won = game.lives > 0;
      return MaterialApp(
        home: Scaffold(
          backgroundColor: Colors.black,
          body: Center(
            child: Text(
              won ? '🏆 ¡Juego completado!\nVidas restantes: ${game.lives}'
                  : '💀 Juego terminado\nVidas: ${game.lives}',
              style: const TextStyle(color: Colors.white, fontSize: 24),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    final round = game.currentRound;

    Widget body;

    // Pantalla de entrega del teléfono
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
            ElevatedButton(
              onPressed: _fromHandover,
              child: const Text('Listo'),
            ),
          ],
        ),
      );
    }
    // Turno del Chef: ve colores, da pista (palabra + cantidad)
    else if (round.isChefTurn) {
      body = SingleChildScrollView(
        child: Column(
          children: [
            Text('Ronda ${round.number} — Turno del Chef',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text('Vidas: ${game.lives}  •  Dificultad: ${game.difficulty.name.toUpperCase()}'),
            const SizedBox(height: 12),

            // Tablero visible para el Chef (con colores)
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

            // Pista
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
                _QtyStepper(
                  value: _clueQty,
                  onChanged: (v) => setState(() => _clueQty = v),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: _submitClue,
                  icon: const Icon(Icons.campaign),
                  label: const Text('Dar pista'),
                ),
                const SizedBox(width: 12),
                OutlinedButton(
                  onPressed: () {
                    // Mostrar receta esperada (solo para debug del Chef)
                    final r = round.recipe.required;
                    final items = r.entries
                        .map((e) => '${e.key.name}:${e.value}')
                        .join(', ');
                    _showSnack('Receta: { $items }');
                    setState(() {});
                  },
                  child: const Text('Ver receta (debug)'),
                ),
              ],
            ),
          ],
        ),
      );
    }
    // Turno del Cocinero: ve SOLO texto; selecciona hasta picksRemaining
    else {
      final picks = round.picksRemaining;
      final clue = round.activeClue;
      body = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Ronda ${round.number} — Turno del Cocinero',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text('Vidas: ${game.lives}', textAlign: TextAlign.center),
          const SizedBox(height: 6),
          if (clue != null)
            Text('Pista: "${clue.word}"  •  Intentos: $picks',
                textAlign: TextAlign.center),
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
              onPressed: () {
                setState(() {
                  game.startGame(roundCount: 5);
                  handoverScreen = false;
                  _status = null;
                  _clueQty = 1;
                  _clueWordCtrl.clear();
                });
              },
              icon: const Icon(Icons.restart_alt),
              tooltip: 'Reiniciar',
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: body,
        ),
        bottomNavigationBar: (_status == null)
            ? null
            : Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.85),
                ),
                child: Text(
                  _status!,
                  style: const TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ),
      ),
    );
  }

  // Paleta para el tablero del Chef
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
        return Colors.orange; // se distingue fácil
      case IngredientColor.black:
        return Colors.black;
    }
  }
}

class _QtyStepper extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;
  const _QtyStepper({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          tooltip: 'Menos',
          onPressed: value > 1 ? () => onChanged(value - 1) : null,
          icon: const Icon(Icons.remove_circle_outline),
        ),
        Text('$value', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        IconButton(
          tooltip: 'Más',
          onPressed: () => onChanged(value + 1),
          icon: const Icon(Icons.add_circle_outline),
        ),
      ],
    );
  }
}
