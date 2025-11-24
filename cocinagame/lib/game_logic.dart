import 'dart:math';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// =============================
/// Enums y modelos base
/// =============================

enum IngredientColor { kBeterraga, kCebolla, kChampinon, kPimenton, kTomate, kZanahoria, kOcultas, black }

enum Difficulty { easy, medium, hard }

enum SelectionResult { correct, exceededRecipeColor, kOcultas, wrongColor, black, alreadySelected }

class Ingredient {
  final String name;
  final IngredientColor color;
  bool revealed = false;

  Ingredient(this.name, this.color);
}

class Recipe {
  final Map<IngredientColor, int> required;

  Recipe(this.required) {
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

class Clue {
  final String word;
  final int quantity;

  Clue(this.word, this.quantity) : assert(quantity >= 1);
}

enum Palabras { manzana, bicicleta, elefante, montana, guitarra, ventana, libro, reloj, playa, estrella, nube, perro, balon, arbol, ciudad, fuego, luna, camisa, flor, rio, tren, zapato, mariposa, carro, gato, mar }

/// =============================
/// WordBank
/// =============================
class WordBank {
  WordBank._();
  static final WordBank instance = WordBank._();

  final Set<String> _used = {};
  final List<String> _pool = [];
  final List<String> _base = [];
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
    _used.clear();
    final candidates = List<String>.from(_base);
    candidates.shuffle(_rnd);
    _pool
      ..clear()
      ..addAll(candidates);
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
      _ensureBase();
    }

    _refillPool();
  }

  String nextWord() {
    if (_pool.isEmpty) _refillPool();
    while (_pool.isNotEmpty) {
      final w = _pool.removeAt(0);
      _used.add(w);
      return w;
    }
    return 'ingrediente_${_fallbackCounter++}';
  }

  void reset() {
    _used.clear();
    _pool.clear();
    _fallbackCounter = 1;
  }
}

/// =============================
/// Round
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

  Round({required this.number, required this.board, required this.difficulty, Random? rnd})
      : _rnd = rnd ?? Random() {
    recipe = _generateRecipeForBoard();
  }

  void giveClue(Clue clue) {
    if (finished) return;
    activeClue = clue;
    isChefTurn = false;
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

  void cookStops() {
    if (isChefTurn || finished) return;
    if (recipe.isCompleted) finished = true;
    activeClue = null;
    isChefTurn = true;
    _currentSelections.clear();
  }

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
        maxDistinct = 2;
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

    for (final color in chosenColors) {
      final avail = boardCount[color] ?? 0;
      if (avail <= 0) continue;
      req[color] = 1;
      remaining -= 1;
      if (remaining <= 0) break;
    }

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
/// Game
/// =============================
class Game {
  int lives;
  int currentRoundIndex = 0;
  bool isGameOver = false;

  final Difficulty difficulty;
  final bool useCustomWords;
  final Random _rnd;
  final List<Round> rounds = [];

  Game({
    this.lives = 3,
    this.difficulty = Difficulty.easy,
    this.useCustomWords = false,
    Random? rnd,
  }) : _rnd = rnd ?? Random();

  int get roundNumber => currentRoundIndex + 1;

  Future<void> startGame({int roundCount = 1}) async {
    lives = 3;
    currentRoundIndex = 0;
    isGameOver = false;

    WordBank.instance.reset();
    await WordBank.instance.tryFetchOnce();

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

    if (res == SelectionResult.black) {
      loseLife();
      isGameOver = true;
      _saveScoreToFirestore();
      round.finished = true;
      return res;
    }

    if (res == SelectionResult.wrongColor || res == SelectionResult.exceededRecipeColor) {
      loseLife();
      if (!isGameOver) {
        _resetCurrentRound();
      } else {
        _saveScoreToFirestore();
      }
      return res;
    }

    if (round.recipe.isCompleted) {
      round.finished = true;
      WordBank.instance._refillPool();
      _nextRound();
      return res;
    }

    return res;
  }

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
      _saveScoreToFirestore();
    }
  }

  void _resetCurrentRound() {
    final current = currentRound;
    rounds[currentRoundIndex] = Round(
      number: current.number,
      board: _generateBoard(),
      difficulty: difficulty,
      rnd: _rnd,
    );
  }

  void _nextRound() {
    currentRoundIndex++;
    rounds.add(Round(number: currentRoundIndex + 1, board: _generateBoard(), difficulty: difficulty, rnd: _rnd));
  }

  List<Ingredient> _generateBoard() {
    final board = <Ingredient>[];

    final int blacks = (difficulty == Difficulty.hard) ? 2 : 1;
    for (int b = 0; b < blacks; b++) {
      board.add(Ingredient(_pickWord(), IngredientColor.black));
    }

    int remaining = 18 - board.length;
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
      final two = nonNeutral.take(2).toList();
      palette = [...two, IngredientColor.kOcultas];
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

  /// =============================
  /// 🔥 Guarda puntaje en Firestore
  /// =============================
  Future<void> _saveScoreToFirestore() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      final name = user?.email ?? 'Anónimo';
      final score = currentRoundIndex * 100; // ejemplo simple: 100 pts por ronda

      await FirebaseFirestore.instance.collection('leaderboard').add({
        'user': name,
        'score': score,
        'date': FieldValue.serverTimestamp(),
      });

      print('Puntaje guardado correctamente: $score');
    } catch (e) {
      print('Error al guardar puntaje: $e');
    }
  }
}
