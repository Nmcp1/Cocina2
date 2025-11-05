// game_logic.dart
import 'dart:math';
import 'dart:convert';
import 'package:http/http.dart' as http;

/// =============================
/// Enums y modelos base
/// =============================

enum IngredientColor { red, blue, green, yellow, purple, neutral, black }
enum Difficulty { easy, medium, hard }

enum SelectionResult {
  correct,
  exceededRecipeColor,
  neutral,
  wrongColor,
  black,
  alreadySelected,
}

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
    if (color == IngredientColor.neutral) return SelectionResult.neutral;

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
enum Palabras {
  manzana, bicicleta, elefante, montana, guitarra, ventana, libro, reloj,
  playa, estrella, nube, perro, balon, arbol, ciudad, fuego, luna, camisa,
  flor, rio, tren, zapato, mariposa, carro
}

/// =============================
/// WordBank con recarga automática
/// =============================
class WordBank {
  WordBank._();
  static final WordBank instance = WordBank._();

  final Set<String> _used = {};
  final List<String> _pool = [];
  final List<String> _base = []; // snapshot de fuente (API o enum)
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
    // Si ya se usaron todas, permite reciclar limpiando usados
    if (_used.length >= _base.length) {
      _used.clear();
    }
    final candidates = _base.where((w) => !_used.contains(w)).toList()
      ..shuffle(_rnd);
    _pool
      ..clear()
      ..addAll(candidates.isEmpty ? _base : candidates);
  }

  Future<void> tryFetchOnce() async {
    if (_fetchedOnce) return;
    _fetchedOnce = true;

    Future<List<String>?> _tryEndpoint(String url) async {
      try {
        final res = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 2));
        if (res.statusCode == 200) {
          final data = jsonDecode(res.body);
          if (data is List) {
            final words = data
                .whereType<String>()
                .map((s) => s.trim())
                .where((s) => s.isNotEmpty)
                .toList();
            if (words.isNotEmpty) return words;
          }
        }
      } catch (_) {}
      return null;
    }

    final api = await _tryEndpoint('http://localhost:8000/api/words') ??
        await _tryEndpoint('http://localhost:8000/words');

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
      _ensureBase(); // cae al enum local
    }

    _refillPool();
  }

  String nextWord() {
    if (_pool.isEmpty) {
      _refillPool();
    }
    while (_pool.isNotEmpty) {
      final w = _pool.removeAt(0);
      if (_used.add(w)) return w; // retorna primera no usada
    }
    // Defensa final (debería usarse raramente)
    return 'ingrediente_${_fallbackCounter++}';
  }

  void reset() {
    _used.clear();
    _pool.clear();
    _fallbackCounter = 1;
    // _base se mantiene (snapshot de API/enum); _pool se repuebla al pedir palabras
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

  Round({
    required this.number,
    required this.board,
    required this.difficulty,
    Random? rnd,
  }) : _rnd = rnd ?? Random() {
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
      if (ing.color == IngredientColor.neutral || ing.color == IngredientColor.black) continue;
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
    final distinct = availableColors.isEmpty
        ? 1
        : min(maxDistinct, availableColors.length);

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
      final best = (boardCount.entries.toList()
            ..sort((a, b) => b.value.compareTo(a.value)))
          .first;
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
  bool isGameOver = false;

  final Difficulty difficulty;
  final Random _rnd;
  final List<Round> rounds = [];

  Game({this.lives = 3, this.difficulty = Difficulty.easy, Random? rnd})
      : _rnd = rnd ?? Random();

  int get roundNumber => currentRoundIndex + 1;

  Future<void> startGame({int roundCount = 1}) async {
    // Se inicia con una ronda; luego serán infinitas
    lives = 3;
    currentRoundIndex = 0;
    isGameOver = false;

    WordBank.instance.reset();
    await WordBank.instance.tryFetchOnce();

    rounds
      ..clear()
      ..add(Round(
        number: 1,
        board: _generateBoard(),
        difficulty: difficulty,
        rnd: _rnd,
      ));
  }

  Round get currentRound => rounds[currentRoundIndex];

  void giveClue(Clue clue) {
    if (isGameOver) return;
    currentRound.giveClue(clue);
  }

  /// Centraliza aquí TODAS las vidas:
  /// - Negro: pierde vida y fin del juego
  /// - Fallo (wrong/exceeded): pierde vida y se reinicia MISMA ronda (nuevo tablero/receta)
  /// - Completa receta: avanza a siguiente ronda (infinita)
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
        _resetCurrentRound(); // nueva receta/tablero, mismo número
      }
      return res;
    }

    // ✅ Completa receta → nueva ronda (infinita)
    if (round.recipe.isCompleted) {
      round.finished = true;
      _nextRound();
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
    rounds.add(Round(
      number: currentRoundIndex + 1,
      board: _generateBoard(),
      difficulty: difficulty,
      rnd: _rnd,
    ));
  }

  /// Construye un tablero de 18 cartas
  /// - 1 negro (2 en hard)
  /// - EASY: solo 2 colores no neutrales + neutrales opcionales
  List<Ingredient> _generateBoard() {
    final board = <Ingredient>[];

    final int blacks = (difficulty == Difficulty.hard) ? 2 : 1;
    for (int b = 0; b < blacks; b++) {
      board.add(Ingredient(_pickWord(), IngredientColor.black));
    }

    int remaining = 18 - board.length;

    final nonNeutral = IngredientColor.values
        .where((c) => c != IngredientColor.black && c != IngredientColor.neutral)
        .toList();

    List<IngredientColor> palette;
    if (difficulty == Difficulty.easy) {
      nonNeutral.shuffle(_rnd);
      final two = nonNeutral.take(2).toList(); // solo 2 colores
      palette = [...two, IngredientColor.neutral]; // neutrales opcionales
    } else {
      palette = [...nonNeutral, IngredientColor.neutral];
    }

    for (int k = 0; k < remaining; k++) {
      final color = palette[_rnd.nextInt(palette.length)];
      board.add(Ingredient(_pickWord(), color));
    }

    board.shuffle(_rnd);
    return board;
  }

  String _pickWord() => WordBank.instance.nextWord();
}
