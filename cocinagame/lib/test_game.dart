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
  bool isTransition = false;
  List<Ingredient> selectedIngredients = [];

  @override
  void initState() {
    super.initState();
    game = Game(lives: 3);
    game.startGame();
  }

  void _nextPhase() {
    setState(() {
      if (isTransition) {
        isTransition = false;
        game.currentRound.nextTurn();
      } else {
        isTransition = true;
      }
    });
  }

  void _onSelectIngredient(Ingredient ingredient) {
    if (!selectedIngredients.contains(ingredient)) {
      setState(() {
        ingredient.selected = true;
        selectedIngredients.add(ingredient);
      });

      if (selectedIngredients.length == 3) {
        game.processCookSelection(selectedIngredients);
        Future.delayed(const Duration(seconds: 2), () {
          if (!mounted) return;
          setState(() {
            selectedIngredients.clear();
            isTransition = false;
          });
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (game.isGameOver) {
      return MaterialApp(
        home: Scaffold(
          backgroundColor: Colors.black,
          body: Center(
            child: Text(
              '💀 Juego terminado\nVidas: ${game.lives}',
              style: const TextStyle(color: Colors.white, fontSize: 24),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    final round = game.currentRound;

    Widget body;

    // Pantalla de transición
    if (isTransition) {
      body = Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '📱 Pasa el teléfono al cocinero 👨‍🍳',
              style: TextStyle(fontSize: 22),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _nextPhase,
              child: const Text('Listo'),
            ),
          ],
        ),
      );
    }
    // Turno del chef
    else if (round.isChefTurn) {
      body = Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Ronda ${round.number} — Turno del Chef',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: round.allIngredients.map((ing) {
              Color color;
              switch (ing.color) {
                case IngredientColor.red:
                  color = Colors.red;
                  break;
                case IngredientColor.blue:
                  color = Colors.blue;
                  break;
                default:
                  color = Colors.grey;
              }
              return Container(
                width: 100,
                height: 50,
                color: color,
                alignment: Alignment.center,
                child: Text(ing.name,
                    style: const TextStyle(color: Colors.white, fontSize: 14)),
              );
            }).toList(),
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: _nextPhase,
            child: const Text('Pasar turno al cocinero'),
          ),
        ],
      );
    }
    // Turno del cocinero
    else {
      body = Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Ronda ${round.number} — Turno del Cocinero\nVidas: ${game.lives}',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: round.allIngredients.map((ing) {
              final color = ing.selected ? Colors.green : Colors.grey[400];
              return GestureDetector(
                onTap: () => _onSelectIngredient(ing),
                child: Container(
                  width: 100,
                  height: 50,
                  color: color,
                  alignment: Alignment.center,
                  child: Text(ing.name,
                      style: const TextStyle(color: Colors.black)),
                ),
              );
            }).toList(),
          ),
        ],
      );
    }

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Juego de Cocina 👨‍🍳')),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: body,
        ),
      ),
    );
  }
}
