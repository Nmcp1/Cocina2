// game_logic.dart
import 'dart:math';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


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
  final int quantity;

  Clue(this.word, this.quantity) : assert(quantity >= 1);
}

/// Palabras base
enum Palabras { manzana, bicicleta, elefante, montana, guitarra, ventana, libro, reloj, playa, estrella, nube, perro, balon, arbol, ciudad, fuego, luna, camisa, flor, rio, tren, zapato, mariposa, carro, gato, mar }

/// Banco de palabras
class WordBank {
  WordBank._();
  static final WordBank instance = WordBank._();

  final Set<String> _used = {};
  final List<String> _pool = [];
  final List<String> _base = [];
  bool _fetchedOnce = false;
  int _fallbackCounter = 1;
  final Random _rnd = Random();

  bool useCustomWords = false;

  void configure({required bool useCustom}) {
    useCustomWords = useCustom;
    _fetchedOnce = false;
  }

  List<String> _loadBaseWords() {
    final seen = <String>{};
    final result = <String>[];

    for (final p in Palabras.values) {
      final name = p.name.trim();
      if (name.isEmpty) continue;
      if (seen.add(name.toLowerCase())) {
        result.add(name);
      }
    }
    return result;
  }

  void _refillPool() {
    if (_base.isEmpty) {
      _base.addAll(_loadBaseWords());
    }
    var remaining = _base.where((w) => !_used.contains(w)).toList();

    if (remaining.isEmpty) {
      _used.clear();
      remaining = List<String>.from(_base);
    }

    remaining.shuffle(_rnd);

    _pool
      ..clear()
      ..addAll(remaining);
  }

  Future<void> tryFetchOnce() async {
    if (_fetchedOnce) return;
    _fetchedOnce = true;

    List<String> finalWords = _loadBaseWords();
    final seen = finalWords.map((e) => e.toLowerCase()).toSet();

    if (useCustomWords) {
      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          final doc = await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .collection('custom_data')
              .doc('words')
              .get();

          final data = doc.data();
          if (data != null && data['words'] is List) {
            final List<dynamic> customDyn = data['words'];

            for (final dynamic w in customDyn) {
              if (w is! String) continue;
              final trimmed = w.trim();
              if (trimmed.isEmpty) continue;

              final lower = trimmed.toLowerCase();
              if (!seen.contains(lower)) {
                seen.add(lower);
                finalWords.add(trimmed);
              }
            }
          }
        }
      } catch (_) {
      }
    }

    finalWords.shuffle(_rnd);
    _base
      ..clear()
      ..addAll(finalWords);

    _refillPool();
  }

  String nextWord() {
    if (_pool.isEmpty) {
      _refillPool();
    }

    if (_pool.isNotEmpty) {
      final w = _pool.removeAt(0);
      _used.add(w);       // 👈 se marca como usada
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

    if (recipe.isCompleted) {
      finished = true;
    }

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
    // Garantiza una receta válida
    if (req.isEmpty && boardCount.isNotEmpty) {
      final best = (boardCount.entries.toList()..sort((a, b) => b.value.compareTo(a.value))).first;
      req[best.key] = min(minTotalRequired, best.value);
    }

    return Recipe(req);
  }
}

class Game {
  int lives;
  int currentRoundIndex = 0;
  int score = 0;
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
    score = 0;
    WordBank.instance.reset();

    WordBank.instance.configure(useCustom: useCustomWords);

    await WordBank.instance.tryFetchOnce();

    // Iniciar primera ronda
    rounds
      ..clear()
      ..add(
        Round(
          number: 1,
          board: _generateBoard(),
          difficulty: difficulty,
          rnd: _rnd,
        ),
      );
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
      round.finished = true;
      return res;
    }

    if (res == SelectionResult.wrongColor ||
        res == SelectionResult.exceededRecipeColor) {
      loseLife();
      if (!isGameOver) {
        _resetCurrentRound();
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
    rounds.add(
      Round(
        number: currentRoundIndex + 1,
        board: _generateBoard(),
        difficulty: difficulty,
        rnd: _rnd,
      ),
    );
  }

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
      IngredientColor.kZanahoria,
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

// Exportar puntuación
Map<String, dynamic> exportScore({required String playerName}) {
  String difficultyKey;
  switch (difficulty) {
    case Difficulty.easy:
      difficultyKey = 'easy';
      break;
    case Difficulty.medium:
      difficultyKey = 'medium';
      break;
    case Difficulty.hard:
      difficultyKey = 'hard';
      break;
  }

  return {
    'player_name': playerName,
    'score': score,
    'difficulty': difficultyKey,
  };
}
}

