// game_logic.dart
import 'dart:math';
import 'dart:convert';
import 'package:http/http.dart' as http;

/// =============================
/// Enums y modelos base
/// =============================

// const Color kBeterraga = Color(0xFFE75480)
// const Color kCebolla = Color(0xFF9B5DE5)
// const Color kChampinon = Color(0xFF8D6E63);
// const Color kPimenton = Color(0xFF2E7D32);
// const Color kTomate = Color(0xFFD62828);
// const Color kZanahoria = Color(0xFFF77F00);
// const Color kOcultas = Color(0xFFFFE98D);
// const Color kNoIngrediente = Color(0xFFC9ADA7);

enum IngredientColor { kBeterraga, kCebolla, kChampinon, kPimenton, kTomate, kZanahoria, kOcultas, black }

enum Difficulty { easy, medium, hard }

enum SelectionResult { correct, exceededRecipeColor, kOcultas, wrongColor, black, alreadySelected }

/// Ingrediente en el tablero
class Ingredient {
  final String name;
  final IngredientColor color;
  bool revealed = false;

  Ingredient(this.name, this.color);
}

/// Representa la receta actual
class Recipe {
  final Map<IngredientColor, int> required;

  Recipe(this.required) {
    // Limpia entradas inválidas
    required.removeWhere((_, v) => v <= 0);
  }

  bool get isCompleted => required.values.every((v) => v == 0);

  SelectionResult applySelectionColor(IngredientColor color) {
    if (color == IngredientColor.black) return SelectionResult.black;
    if (color == IngredientColor.kOcultas) return SelectionResult.kOcultas;

    if (required.containsKey(color)) {
      if (required[color]! > 0) {
        required[color] = required[color]! - 1;
        return SelectionResult.correct;
      } else {
        return SelectionResult.exceededRecipeColor;
      }
    }
    return SelectionResult.wrongColor;
  }
}

/// Pista del chef
class Clue {
  final String word;
  final int quantity; // reservado por si luego limitas selecciones

  Clue(this.word, this.quantity) : assert(quantity >= 1);
}

/// Palabras fallback
enum Palabras { manzana, bicicleta, elefante, montana, guitarra, ventana, libro, reloj, playa, estrella, nube, perro, balon, arbol, ciudad, fuego, luna, camisa, flor, rio, tren, zapato, mariposa, carro, gato, mar }

/// =============================
/// WordBank con recarga automática
/// =============================
class WordBank {
  WordBank._();
  static final WordBank instance = WordBank._();

  final Set<String> _used = {}; // Palabras ya usadas
  final List<String> _pool = []; // Pool de palabras disponibles
  final List<String> _base = []; // Snapshot de las palabras base
  bool _fetchedOnce = false;
  int _fallbackCounter = 1;
  final Random _rnd = Random();

  void _ensureBase() {
    if (_base.isEmpty) {
      final base = Palabras.values.map((e) => e.name).toList();
      base.shuffle(_rnd);
      _base.addAll(base);
    }
  }

  void _refillPool() {
    _ensureBase();
    // Limpia las palabras usadas y recarga el pool
    _used.clear(); // Limpia todas las palabras usadas

    final candidates = List<String>.from(_base);
    candidates.shuffle(_rnd);

    _pool
      ..clear()
      ..addAll(candidates); // Recarga el pool con todas las palabras base
  }

  Future<void> tryFetchOnce() async {
    if (_fetchedOnce) return;
    _fetchedOnce = true;

    Future<List<String>?> tryEndpoint(String url) async {
      try {
        final res = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 2));
        if (res.statusCode == 200) {
          final data = jsonDecode(res.body);
          if (data is List) {
            final words = data.whereType<String>().map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
            if (words.isNotEmpty) return words;
          }
        }
      } catch (_) {}
      return null;
    }

    final api = await tryEndpoint('http://localhost:8000/api/words') ??
        await tryEndpoint('http://localhost:8000/words');

    if (api != null && api.isNotEmpty) {
      final seen = <String>{};
      final normalized = <String>[];
      for (final w in api) {
        final k = w.toLowerCase();
        if (seen.add(k)) normalized.add(w);
      }
      normalized.shuffle(_rnd);
      _base
        ..clear()
        ..addAll(normalized);
    } else {
      _ensureBase(); // Si no se obtiene de la API, usa las palabras locales
    }

    _refillPool(); // Recarga el pool con las palabras obtenidas
  }

  String nextWord() {
    if (_pool.isEmpty) {
      _refillPool();
    }
    while (_pool.isNotEmpty) {
      final w = _pool.removeAt(0); // Toma la primera palabra del pool
      _used.add(w); // Marca la palabra como usada
      return w;
    }
    // Defensa final: si no hay palabras disponibles, genera una palabra por defecto
    return 'ingrediente_${_fallbackCounter++}';
  }

  void reset() {
    _used.clear(); // Limpia las palabras usadas
    _pool.clear(); // Limpia el pool de palabras
    _fallbackCounter = 1;
    // _base se mantiene igual; es el conjunto de palabras originales
  }
}

/// =============================
/// Ronda
/// =============================
class Round {
  final int number;
  final List<Ingredient> board;
  final Difficulty difficulty;

  bool isChefTurn = true;
  bool finished = false;

  late Recipe recipe;
  Clue? activeClue;

  final Random _rnd;
  final List<SelectionResult> _currentSelections = [];

  Round({required this.number, required this.board, required this.difficulty, Random? rnd}) : _rnd = rnd ?? Random() {
    recipe = _generateRecipeForBoard();
  }

  void giveClue(Clue clue) {
    if (finished) return;
    activeClue = clue;
    isChefTurn = false; // turno del cocinero
    _currentSelections.clear();
  }

  SelectionResult selectCard(int index) {
    if (finished || isChefTurn) return SelectionResult.alreadySelected;
    if (index < 0 || index >= board.length) throw RangeError('Índice fuera de rango');

    final card = board[index];
    if (card.revealed) return SelectionResult.alreadySelected;

    card.revealed = true;
    final res = recipe.applySelectionColor(card.color);
    _currentSelections.add(res);
    return res;
  }

  /// Plantarse: vuelve turno al Chef. Solo cierra la ronda si ya quedó completa.
  void cookStops() {
    if (isChefTurn || finished) return;

    if (recipe.isCompleted) {
      finished = true;
    }

    activeClue = null;
    isChefTurn = true;
    _currentSelections.clear();
  }

  /// Receta consistente con tablero
  /// - Easy: hasta 2 colores; total mínimo 5
  /// - Medium/Hard: más colores, total mínimo 5
  Recipe _generateRecipeForBoard() {
    final boardCount = <IngredientColor, int>{};
    for (final ing in board) {
      if (ing.color == IngredientColor.kOcultas || ing.color == IngredientColor.black) continue;
      boardCount[ing.color] = (boardCount[ing.color] ?? 0) + 1;
    }

    int maxDistinct;
    const int minTotalRequired = 5;

    switch (difficulty) {
      case Difficulty.easy:
        maxDistinct = 2; // receta con 1..2 colores
        break;
      case Difficulty.medium:
        maxDistinct = 4;
        break;
      case Difficulty.hard:
        maxDistinct = 5;
        break;
    }

    final availableColors = boardCount.keys.toList()..shuffle(_rnd);
    final distinct = availableColors.isEmpty ? 1 : min(maxDistinct, availableColors.length);

    final chosenColors = availableColors.take(distinct).toList();
    final req = <IngredientColor, int>{};
    int remaining = minTotalRequired;

    // al menos 1 por color elegido (si hay disponibilidad)
    for (final color in chosenColors) {
      final avail = boardCount[color] ?? 0;
      if (avail <= 0) continue;
      req[color] = 1;
      remaining -= 1;
      if (remaining <= 0) break;
    }

    // reparte resto sin pasar disponibilidad
    while (remaining > 0 && chosenColors.isNotEmpty) {
      bool added = false;
      for (final color in chosenColors) {
        final avail = boardCount[color] ?? 0;
        final cur = req[color] ?? 0;
        if (cur < avail) {
          req[color] = cur + 1;
          remaining--;
          added = true;
          if (remaining == 0) break;
        }
      }
      if (!added) break;
    }

    // Garantiza una receta válida
    if (req.isEmpty && boardCount.isNotEmpty) {
      final best = (boardCount.entries.toList()..sort((a, b) => b.value.compareTo(a.value))).first;
      req[best.key] = min(minTotalRequired, best.value);
    }

    return Recipe(req);
  }
}

/// =============================
/// Juego (rondas infinitas + fallo reinicia misma ronda)
/// =============================
class Game {
  int lives;
  int currentRoundIndex = 0;
  int score = 0;
  bool isGameOver = false;

  final Difficulty difficulty;
  final bool useCustomWords; // <-- agrega esto
  final Random _rnd;
  final List<Round> rounds = [];

  Game({
    this.lives = 3,
    this.difficulty = Difficulty.easy,
    this.useCustomWords = false, // <-- y aquí
    Random? rnd,
  }) : _rnd = rnd ?? Random();

  int get roundNumber => currentRoundIndex + 1;

  Future<void> startGame({int roundCount = 1}) async {
    // Se inicia con una ronda; luego serán infinitas
    lives = 3;
    currentRoundIndex = 0;
    isGameOver = false;

    WordBank.instance.reset(); // Limpia las palabras al inicio del juego
    await WordBank.instance.tryFetchOnce(); // Intenta cargar palabras desde la API

    rounds
      ..clear()
      ..add(Round(number: 1, board: _generateBoard(), difficulty: difficulty, rnd: _rnd));
  }

  Round get currentRound => rounds[currentRoundIndex];

  void giveClue(Clue clue) {
    if (isGameOver) return;
    currentRound.giveClue(clue);
  }

  SelectionResult chooseCard(int index) {
    if (isGameOver) return SelectionResult.alreadySelected;

    final round = currentRound;
    final res = round.selectCard(index);

    // ⚫ Negro → pierde vida y fin
    if (res == SelectionResult.black) {
      loseLife();
      isGameOver = true;
      round.finished = true;
      return res;
    }

    // ❌ Fallo → pierde vida y reinicia esta ronda
    if (res == SelectionResult.wrongColor || res == SelectionResult.exceededRecipeColor) {
      loseLife();
      if (!isGameOver) {
        _resetCurrentRound(); // Reinicia la ronda (nuevo tablero y receta)
      }
      return res;
    }

    // ✅ Receta completada → nueva ronda (infinita)
    if (round.recipe.isCompleted) {
      round.finished = true;
      WordBank.instance._refillPool(); // Recarga las palabras al terminar la ronda
      _nextRound(); // Avanza a la siguiente ronda
      return res;
    }

    // 🟡 Neutro o ✅ correcto parcial
    return res;
  }

  /// Plantarse: vuelve al Chef; si ya estaba completa, avanza
  void cookStops() {
    if (isGameOver) return;

    final round = currentRound;
    final wasCompletedBefore = round.recipe.isCompleted;

    round.cookStops();

    if (!wasCompletedBefore && round.finished && round.recipe.isCompleted) {
      _nextRound();
    }
  }

  void loseLife() {
    lives--;
    if (lives <= 0) {
      isGameOver = true;
    }
  }

  /// Reinicia completamente la ronda actual tras un fallo
  void _resetCurrentRound() {
    final current = currentRound;
    rounds[currentRoundIndex] = Round(
      number: current.number, // mismo número
      board: _generateBoard(),
      difficulty: difficulty,
      rnd: _rnd,
    );
  }

  /// Avanza a la siguiente ronda (infinitas)
  void _nextRound() {
    currentRoundIndex++;
    rounds.add(Round(number: currentRoundIndex + 1, board: _generateBoard(), difficulty: difficulty, rnd: _rnd));
  }

  /// Construye un tablero de 18 cartas
  /// - 1 negro (2 en hard)
  /// - EASY: solo 2 colores no neutrales + neutrales opcionales
  List<Ingredient> _generateBoard() {
    final board = <Ingredient>[];

    int totalCards;
    switch (difficulty) {
      case Difficulty.hard:
        totalCards = 21;
        break;
      case Difficulty.medium:
      case Difficulty.easy:
        totalCards = 24;
        break;
    }

    final int blacks = (difficulty == Difficulty.hard) ? 2 : 1;
    for (int b = 0; b < blacks; b++) {
      board.add(Ingredient(_pickWord(), IngredientColor.black));
    }

    int remaining = totalCards - board.length;

    final nonNeutral = <IngredientColor>[
      IngredientColor.kBeterraga,
      IngredientColor.kCebolla,
      IngredientColor.kChampinon,
      IngredientColor.kPimenton,
      IngredientColor.kTomate,
      IngredientColor.kZanahoria
    ];

    List<IngredientColor> palette;
    if (difficulty == Difficulty.easy) {
      nonNeutral.shuffle(_rnd);
      final two = nonNeutral.take(2).toList(); // solo 2 colores
      palette = [...two, IngredientColor.kOcultas]; // neutrales opcionales
    } else {
      palette = [...nonNeutral, IngredientColor.kOcultas];
    }

    for (int k = 0; k < remaining; k++) {
      final color = palette[_rnd.nextInt(palette.length)];
      board.add(Ingredient(_pickWord(), color));
    }

    board.shuffle(_rnd);
    return board;
  }

  String _pickWord() => WordBank.instance.nextWord();

  //exportar puntuacion
  Map<String, dynamic> exportScore({required String playerName}) {
  return {
    'player_name': playerName,
    'score': score,
  };
  }
}
