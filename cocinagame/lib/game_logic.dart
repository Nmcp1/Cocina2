// game_logic.dart
import 'dart:math';
import 'dart:convert';
import 'package:http/http.dart' as http;

/// =============================
/// Enums y modelos base
/// =============================
enum PlayerType { chef, cook }
enum IngredientColor { red, blue, green, yellow, purple, neutral, black }

enum Difficulty { easy, medium, hard }

enum SelectionResult {
  correct,              // Color requerido y aún faltaba de ese color
  exceededRecipeColor,  // Color es de receta pero la cuota de ese color ya estaba completa -> arruina receta
  neutral,              // Neutro -> se pierde el turno
  wrongColor,           // Color NO pertenece a la receta -> arruina receta
  black,                // Negro -> fin de juego
  alreadySelected,      // Ya estaba revelada
}

class Ingredient {
  final String name;
  final IngredientColor color;
  bool revealed = false;

  Ingredient(this.name, this.color);
}

/// Representa la “receta”: cantidades requeridas por color.
/// No incluye negro ni neutral.
class Recipe {
  final Map<IngredientColor, int> required; // color -> cantidad requerida

  Recipe(this.required) {
    // Sanitiza: quita colores con 0
    required.removeWhere((_, v) => v <= 0);
  }

  bool get isCompleted => required.values.every((v) => v == 0);

  /// Intenta aplicar la selección de un ingrediente de cierto color.
  /// Devuelve:
  /// - SelectionResult.correct si ese color aún faltaba y se descuenta.
  /// - SelectionResult.exceededRecipeColor si el color pertenece a la receta pero ya estaba en 0.
  /// - SelectionResult.wrongColor si el color no pertenece a la receta.
  SelectionResult applySelectionColor(IngredientColor color) {
    if (color == IngredientColor.black) return SelectionResult.black;
    if (color == IngredientColor.neutral) return SelectionResult.neutral;

    if (required.containsKey(color)) {
      if (required[color]! > 0) {
        required[color] = required[color]! - 1;
        return SelectionResult.correct;
      } else {
        // El color pertenece a la receta, pero ya está completo -> excedente -> arruina receta
        return SelectionResult.exceededRecipeColor;
      }
    }
    // No está en la receta -> arruina receta
    return SelectionResult.wrongColor;
  }
}

class Clue {
  final String word;
  final int quantity; // número de intentos máximos del Cocinero en este turno

  Clue(this.word, this.quantity) : assert(quantity >= 1);
}

/// Palabras por defecto (fallback)
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

/// =============================
/// WordBank: sin repeticiones + API opcional
/// =============================
class WordBank {
  WordBank._();
  static final WordBank instance = WordBank._();

  /// Conjunto global de palabras ya usadas (no se repiten en todo el juego).
  final Set<String> _used = <String>{};

  /// Pool actual de palabras candidatas (sin usadas).
  final List<String> _pool = <String>[];

  bool _fetchedOnce = false;
  int _fallbackCounter = 1;
  final Random _rnd = Random();

  /// Llenar el pool desde el enum por defecto (sin repetir ya usadas).
  void _fillFromEnumIfNeeded() {
    if (_pool.isNotEmpty) return;
    final base = Palabras.values.map((e) => e.name).where((w) => !_used.contains(w)).toList();
    base.shuffle(_rnd);
    _pool.addAll(base);
  }

  /// Intenta una sola vez traer palabras desde API local.
  /// Si el endpoint existe y devuelve lista no vacía, reemplaza el pool base.
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
      } catch (_) {
        // Silencioso: si falla, seguimos con fallback.
      }
      return null;
    }

    // Prueba /api/words y luego /words
    final candidates =
        await _tryEndpoint('http://localhost:8000/api/words') ??
        await _tryEndpoint('http://localhost:8000/words');

    if (candidates != null && candidates.isNotEmpty) {
      // Reemplaza el pool con palabras únicas que no estén usadas
      final unique = <String>{};
      final filtered = <String>[];
      for (final w in candidates) {
        final lw = w.trim();
        if (lw.isEmpty) continue;
        final key = lw.toLowerCase();
        if (!unique.contains(key) && !_used.contains(lw)) {
          unique.add(key);
          filtered.add(lw);
        }
      }
      if (filtered.isNotEmpty) {
        _pool
          ..clear()
          ..addAll(filtered..shuffle(_rnd));
      }
    }

    // Si la API no trajo nada, dejamos que el enum llene el pool on-demand
  }

  /// Entrega la siguiente palabra **única**.
  /// Si se agotan, genera una palabra nueva única (`ingrediente_#`).
  String nextWord() {
    if (_pool.isEmpty) {
      _fillFromEnumIfNeeded();
    }
    // Busca una palabra que no esté usada
    while (_pool.isNotEmpty) {
      final w = _pool.removeAt(0);
      if (_used.add(w)) {
        return w;
      }
    }
    // Si llegamos aquí, no hay más en enum ni API: generar únicas sintéticas.
    String gen() => 'ingrediente_${_fallbackCounter++}';
    String candidate = gen();
    while (_used.contains(candidate)) {
      candidate = gen();
    }
    _used.add(candidate);
    return candidate;
  }

  /// Resetea el banco (por si reinicias juego).
  void reset() {
    _used.clear();
    _pool.clear();
    _fetchedOnce = false;
    _fallbackCounter = 1;
  }
}

/// =============================
/// Ronda
/// =============================
class Round {
  final int number;
  final List<Ingredient> board; // 18 ingredientes
  final Difficulty difficulty;

  // Estado de turno
  bool isChefTurn = true;
  bool finished = false;

  // Receta dinámica de la ronda (puede cambiar cuando se “arruina”)
  late Recipe recipe;

  // Pista activa y selecciones disponibles en este turno
  Clue? activeClue;
  int picksRemaining = 0;

  final Random _rnd;

  Round({
    required this.number,
    required this.board,
    required this.difficulty,
    Random? rnd,
  }) : _rnd = rnd ?? Random() {
    recipe = _generateRecipeForBoard();
  }

  /// Chef entrega pista (palabra + número)
  void giveClue(Clue clue) {
    if (finished) return;
    activeClue = clue;
    picksRemaining = clue.quantity;
    isChefTurn = false; // pasa el turno al Cocinero
  }

  /// Cocinero elige carta por índice del tablero (0..17)
  /// Se aplica la regla de color; retorna el resultado para que el UI reaccione.
  SelectionResult selectCard(int index) {
    if (finished) return SelectionResult.alreadySelected;
    if (isChefTurn) return SelectionResult.alreadySelected; // No es su turno

    if (index < 0 || index >= board.length) {
      throw RangeError('Índice fuera de rango del tablero');
    }

    final card = board[index];
    if (card.revealed) return SelectionResult.alreadySelected;

    // Revela
    card.revealed = true;

    // Aplica reglas de color
    final res = recipe.applySelectionColor(card.color);

    // Reglas de término inmediato
    if (res == SelectionResult.black) {
      finished = true; // Fin inmediato de la ronda (y del juego, lo marca Game)
      return res;
    }

    if (res == SelectionResult.neutral) {
      // Se pierde el turno (no vidas). Termina turno actual.
      _endCookTurn();
      return res;
    }

    if (res == SelectionResult.correct) {
      // Avance de receta
      picksRemaining = (picksRemaining - 1).clamp(0, 9999);
      if (recipe.isCompleted) {
        finished = true; // Ronda superada
        return res;
      }
      if (picksRemaining == 0) {
        _endCookTurn();
      }
      return res;
    }

    // exceededRecipeColor o wrongColor → arruina receta: pierdes 1 vida y se cambia la receta
    _endCookTurn(changeRecipe: true);
    return res;
  }

  /// El Cocinero decide plantarse antes de gastar todos los picks
  void cookStops() {
    if (!isChefTurn && !finished) {
      _endCookTurn();
    }
  }

  /// Cierra turno del Cocinero y vuelve al Chef
  void _endCookTurn({bool changeRecipe = false}) {
    activeClue = null;
    picksRemaining = 0;
    isChefTurn = true;
    if (!finished && changeRecipe) {
      recipe = _generateRecipeForBoard(); // nueva receta
    }
  }

  /// Genera una receta válida según dificultad y tablero actual (sin contar negros/neutral)
  Recipe _generateRecipeForBoard() {
    // Colores candidatos (sin neutral ni black)
    final usableColors = IngredientColor.values
        .where((c) => c != IngredientColor.neutral && c != IngredientColor.black)
        .toList();

    // Conteo disponible por color en el tablero
    final boardCount = <IngredientColor, int>{};
    for (final ing in board) {
      if (ing.color == IngredientColor.neutral || ing.color == IngredientColor.black) continue;
      boardCount[ing.color] = (boardCount[ing.color] ?? 0) + 1;
    }

    // Reglas por dificultad
    int minDistinct;
    int maxDistinct;
    int minTotalRequired;
    switch (difficulty) {
      case Difficulty.easy:
        minDistinct = 1; // 1 a 2 colores
        maxDistinct = 2;
        minTotalRequired = 4; // “al menos 4 cartas de los colores de la receta”
        break;
      case Difficulty.medium:
        minDistinct = 2; // 2 a 4 colores
        maxDistinct = 4;
        minTotalRequired = 3; // “al menos 3 cartas de colores requeridos”
        break;
      case Difficulty.hard:
        minDistinct = 3; // 3 a 5 colores
        maxDistinct = 5;
        minTotalRequired = 3; // “al menos 3 colores presentes”
        break;
    }

    // Elige cuántos colores distintos tendrá la receta
    final availableColors = boardCount.keys.toList()..shuffle(_rnd);
    final distinct = availableColors.isEmpty
        ? 1
        : (_rnd.nextInt((maxDistinct - minDistinct) + 1) + minDistinct)
            .clamp(1, availableColors.length);

    final chosenColors = availableColors.take(distinct).toList();

    // Asigna cantidades por color sin exceder disponibilidad y cumpliendo mínimo total
    final req = <IngredientColor, int>{};
    int remainingMinTotal = minTotalRequired;

    for (int i = 0; i < chosenColors.length; i++) {
      final color = chosenColors[i];
      final avail = boardCount[color] ?? 0;
      if (avail <= 0) {
        req[color] = 0;
        continue;
      }

      // Reparte al menos 1 por color si es posible
      final minForThis = (difficulty == Difficulty.easy && i == 0) ? 2 : 1; // pequeño sesgo en fácil
      final minPick = min(avail, minForThis);
      int give = minPick;

      // Intenta agregar algo más aleatorio sin pasar disponibilidad
      final extraRoom = max(0, avail - give);
      if (extraRoom > 0) {
        give += _rnd.nextInt(extraRoom + 1); // 0..extraRoom
      }

      req[color] = give;
      remainingMinTotal -= give;
    }

    // Si no llegamos al mínimo total requerido, reparte incrementando colores con disponibilidad
    while (remainingMinTotal > 0) {
      bool added = false;
      for (final color in chosenColors) {
        final avail = boardCount[color] ?? 0;
        if ((req[color] ?? 0) < avail) {
          req[color] = (req[color] ?? 0) + 1;
          remainingMinTotal--;
          added = true;
          if (remainingMinTotal <= 0) break;
        }
      }
      if (!added) break; // no hay más espacio
    }

    // Limpia ceros
    req.removeWhere((_, v) => v <= 0);

    // Fallback si quedó vacía (tablero extraño), pide 1 del color más abundante
    if (req.isEmpty && boardCount.isNotEmpty) {
      final best = boardCount.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      req[best.first.key] = 1;
    }

    return Recipe(req);
  }
}

/// =============================
/// Juego (varias rondas)
/// =============================
class Game {
  int lives;
  int currentRoundIndex = 0;
  bool isGameOver = false;

  final Difficulty difficulty;
  final Random _rnd;
  List<Round> rounds = [];

  Game({
    this.lives = 3,
    this.difficulty = Difficulty.easy,
    Random? rnd,
  }) : _rnd = rnd ?? Random();

  void startGame({int roundCount = 5}) {
    lives = 3;
    currentRoundIndex = 0;
    isGameOver = false;

    // Intenta poblar WordBank desde la API local (no bloquea la generación inicial).
    // Si la API responde, surtirá efecto en rondas futuras y/o siguientes partidas.
    WordBank.instance.tryFetchOnce();

    rounds = _generateRounds(roundCount);
  }

  Round get currentRound => rounds[currentRoundIndex];

  /// Chef da pista en la ronda actual
  void giveClue(Clue clue) {
    if (isGameOver) return;
    currentRound.giveClue(clue);
  }

  /// Cocinero elige carta -> retorna resultado y aplica efectos de juego (vidas, fin, avance)
  SelectionResult chooseCard(int index) {
    if (isGameOver) return SelectionResult.alreadySelected;

    final res = currentRound.selectCard(index);

    // Efectos a nivel de juego según resultado
    switch (res) {
      case SelectionResult.black:
        isGameOver = true; // fin inmediato
        break;
      case SelectionResult.exceededRecipeColor:
      case SelectionResult.wrongColor:
        // Pierdes una vida y la ronda cambia de receta (la ronda ya lo hace).
        lives--;
        if (lives <= 0) {
          isGameOver = true;
        }
        break;
      case SelectionResult.neutral:
      case SelectionResult.correct:
      case SelectionResult.alreadySelected:
        // No cambios de vidas aquí
        break;
    }

    // Si la ronda terminó por completar receta, avanza
    if (!isGameOver && currentRound.finished) {
      _nextRound();
    }

    return res;
  }

  void cookStops() {
    if (!isGameOver) currentRound.cookStops();
  }

  void _nextRound() {
    if (currentRoundIndex < rounds.length - 1) {
      currentRoundIndex++;
    } else {
      isGameOver = true; // juego completado con éxito
    }
  }

  /// =============================
  /// Generación de rondas/tableros
  /// =============================
  List<Round> _generateRounds(int count) {
    final List<Round> out = [];

    for (int i = 0; i < count; i++) {
      // 18 cartas
      final List<Ingredient> board = [];

      // Decide cantidad de negros por dificultad
      final int blacks =
          (difficulty == Difficulty.hard) ? 2 : 1; // fácil/medio = 1, difícil = 2

      // Empezamos agregando negros (palabras únicas)
      for (int b = 0; b < blacks; b++) {
        board.add(Ingredient(_pickWord(), IngredientColor.black));
      }

      // El resto: mezcla de colores (incluyendo neutrales)
      int remaining = 18 - board.length;

      // Asegura al menos N colores distintos no negros ni neutrales en el tablero
      int minDistinctNonNeutral;
      switch (difficulty) {
        case Difficulty.easy:
          minDistinctNonNeutral = 5;
          break;
        case Difficulty.medium:
          minDistinctNonNeutral = 4;
          break;
        case Difficulty.hard:
          minDistinctNonNeutral = 4;
          break;
      }

      final usableColors = IngredientColor.values
          .where((c) => c != IngredientColor.black)
          .toList();
      final nonNeutralColors =
          usableColors.where((c) => c != IngredientColor.neutral).toList();

      // Semilla de variedad: 1 carta de varios colores no neutrales
      nonNeutralColors.shuffle(_rnd);
      final seedCount = min(minDistinctNonNeutral, nonNeutralColors.length);
      for (int s = 0; s < seedCount && remaining > 0; s++) {
        board.add(Ingredient(_pickWord(), nonNeutralColors[s]));
        remaining--;
      }

      // Rellena el resto con mezcla aleatoria incluyendo neutrales
      for (int k = 0; k < remaining; k++) {
        final color = usableColors[_rnd.nextInt(usableColors.length)];
        board.add(Ingredient(_pickWord(), color));
      }

      // Baraja tablero
      board.shuffle(_rnd);

      out.add(Round(
        number: i + 1,
        board: board,
        difficulty: difficulty,
        rnd: _rnd,
      ));
    }

    return out;
  }

  /// Palabra única desde WordBank (sin repeticiones globales).
  String _pickWord() {
    return WordBank.instance.nextWord();
  }
}
