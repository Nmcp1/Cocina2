// game_logic.dart

import 'dart:math';

enum PlayerType { chef, cook }
enum IngredientColor { red, blue, neutral }

enum Palabras {
  manzana,
  bicicleta,
  elefante,
  montana,
  guitarra,
  ventana,
  libro,
  reloj,
  playa,
  estrella,
  nube,
  perro,
  balon,
  arbol,
  ciudad,
  fuego,
  luna,
  camisa,
  flor,
  rio,
  tren,
  zapato,
  mariposa,
  carro,
}

class Ingredient {
  final String name;
  final IngredientColor color;
  bool selected = false;

  Ingredient(this.name, this.color);
}

class Recipe {
  final List<Ingredient> ingredients;

  Recipe(this.ingredients);

  /// Devuelve un conteo de cuántos ingredientes hay de cada color
  Map<IngredientColor, int> getColorCount() {
    final counts = <IngredientColor, int>{};
    for (var i in ingredients) {
      counts[i.color] = (counts[i.color] ?? 0) + 1;
    }
    return counts;
  }

  /// Verifica si la selección del cocinero coincide exactamente
  bool matchesSelection(List<Ingredient> selected) {
    final expected = getColorCount();
    final actual = <IngredientColor, int>{};

    for (var ing in selected) {
      actual[ing.color] = (actual[ing.color] ?? 0) + 1;
    }

    // Debe coincidir el número exacto de ingredientes por color
    // También verificamos que no hayan colores extras en `actual`
    if (expected.length != actual.length) return false;

    return expected.keys.every((color) => expected[color] == actual[color]);
  }
}

class Round {
  final int number;
  final List<Ingredient> allIngredients;
  final Recipe recipe;
  bool isChefTurn = true;
  bool isFinished = false;

  Round({
    required this.number,
    required this.allIngredients,
    required this.recipe,
  });

  /// Lógica para cambiar de turno
  void nextTurn() {
    isChefTurn = !isChefTurn;
  }

  /// Verifica si el cocinero acertó la receta
  bool checkCookSelection(List<Ingredient> selected) {
    isFinished = true;
    return recipe.matchesSelection(selected);
  }
}

class Player {
  final String name;
  final PlayerType type;

  Player(this.name, this.type);
}

class Clue {
  final String word;
  final int quantity;

  Clue(this.word, this.quantity);
}

class Game {
  int lives;
  int currentRoundIndex = 0;
  List<Round> rounds = [];
  bool isGameOver = false;

  Game({this.lives = 3});

  void startGame() {
    lives = 3;
    currentRoundIndex = 0;
    isGameOver = false;
    rounds = _generateRounds(5); // Por ejemplo, 5 rondas
  }

  /// Genera rondas aleatorias (puedes personalizar)
  List<Round> _generateRounds(int count) {
  final rnd = Random();
  final colors = IngredientColor.values;
  final palabras = Palabras.values;
  final List<Round> list = [];

  for (int i = 0; i < count; i++) {
    // Creamos una lista temporal de palabras y la barajamos
    final palabrasDisponibles = List<Palabras>.from(palabras)..shuffle(rnd);

    // Generamos 15 ingredientes aleatorios sin repetir palabras
    final allIngredients = List.generate(15, (index) {
      final color = colors[rnd.nextInt(colors.length)];
      final palabra = palabrasDisponibles[index % palabrasDisponibles.length];
      return Ingredient('${palabra.name}', color);
    });

    // Selección de ingredientes para la receta (2 rojos, 1 azul)
    final rojos = allIngredients.where((i) => i.color == IngredientColor.red).toList();
    final azules = allIngredients.where((i) => i.color == IngredientColor.blue).toList();

    final recipeIngredients = <Ingredient>[];
    recipeIngredients.addAll(rojos.take(2));
    recipeIngredients.addAll(azules.take(1));

    if (recipeIngredients.isEmpty && allIngredients.isNotEmpty) {
      recipeIngredients.add(allIngredients.first);
    }

    final recipe = Recipe(recipeIngredients);
    list.add(Round(number: i + 1, allIngredients: allIngredients, recipe: recipe));
  }

  return list;
}

  /// Retorna la ronda actual
  Round get currentRound => rounds[currentRoundIndex];

  /// Procesa el resultado del turno del cocinero
  void processCookSelection(List<Ingredient> selected) {
    final success = currentRound.checkCookSelection(selected);

    if (!success) {
      lives--;
      print('❌ Error: selección incorrecta. Vidas restantes: $lives');
    } else {
      print('✅ Ronda superada.');
    }

    if (lives <= 0) {
      isGameOver = true;
      print('💀 Juego terminado.');
      return;
    }

    nextRound();
  }

  /// Avanza a la siguiente ronda
  void nextRound() {
    if (currentRoundIndex < rounds.length - 1) {
      currentRoundIndex++;
      print('➡️ Avanzando a la ronda ${currentRoundIndex + 1}');
    } else {
      isGameOver = true;
      print('🏆 Juego completado con éxito!');
    }
  }
}
