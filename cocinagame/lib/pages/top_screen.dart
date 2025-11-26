import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../constants/theme.dart';
import '../main_nav_bar.dart';

class TopScreen extends StatefulWidget {
  const TopScreen({super.key});

  @override
  State<TopScreen> createState() => _TopScreenState();
}

class _TopScreenState extends State<TopScreen> {
  int _selectedIndex = 2;
  String _selectedDifficulty = 'Dificultad';
  List<Map<String, dynamic>> topPlayers = [];
  final List<String> difficulties = ['Dificultad', 'Fácil', 'Media', 'Difícil'];

  bool _isLoading = false; // <-- NUEVO

  @override
  void initState() {
    super.initState();
    _loadScores();
  }

  /// Mapea la etiqueta del dropdown a la key guardada en Firestore
  String? _difficultyKeyForFilter() {
    switch (_selectedDifficulty) {
      case 'Fácil':
        return 'easy';
      case 'Media':
        return 'medium';
      case 'Difícil':
        return 'hard';
      default:
        return null; // "Dificultad" => sin filtro
    }
  }

  Future<void> _loadScores() async {
    setState(() {
      _isLoading = true; // <-- NUEVO
    });
    try {
      Query query = FirebaseFirestore.instance.collection('scores');

      final diffKey = _difficultyKeyForFilter();
      if (diffKey != null) {
        // Filtrar por dificultad si se eligió una
        query = query.where('difficulty', isEqualTo: diffKey);
      }

      query = query.orderBy('score', descending: true).limit(50);

      final snapshot = await query.get();

      final data = snapshot.docs.asMap().entries.map((entry) {
        final index = entry.key;
        final doc = entry.value.data() as Map<String, dynamic>;

        return {
          'puesto': index + 1,
          'nombre': (doc['player_name'] ?? 'Sin nombre') as String,
          'puntaje': (doc['score'] ?? 0) as int,
        };
      }).toList();

      setState(() {
        topPlayers = data;
      });
    } catch (e) {
      debugPrint("Error cargando leaderboard: $e");
    } finally {
      setState(() {
        _isLoading = false; // <-- NUEVO
      });
    }
  }

  void _onNavTap(int index) {
    setState(() {
      _selectedIndex = index;
      if (index == 0) {
        Navigator.pushNamed(context, '/menu');
      } else if (index == 1) {
        Navigator.pushNamed(context, '/palabras');
      } else if (index == 2) {
        // Ya estás en esta pantalla
      } else if (index == 3) {
        Navigator.pushNamed(context, '/comojugar');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground1,
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 60, left: 16, right: 16, bottom: 16),
            width: double.infinity,
            child: Material(
              color: kPrimary,
              borderRadius: BorderRadius.circular(12),
              elevation: 2,
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Center(
                  child: Text(
                    'Clasificatorias',
                    style: TextStyle(
                      color: kBackground1,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Dropdown de dificultad
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.symmetric(horizontal: 132, vertical: 0),
            decoration: BoxDecoration(
              color: kBackground2,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedDifficulty,
                icon: const Icon(Icons.arrow_drop_down, color: kPrimary),
                style: const TextStyle(color: kText1, fontSize: 18, fontWeight: FontWeight.w500),
                dropdownColor: kBackground2,
                borderRadius: BorderRadius.circular(8),
                items: difficulties.map((dif) {
                  return DropdownMenuItem<String>(
                    value: dif,
                    child: Text(dif),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedDifficulty = value!;
                  });
                  _loadScores();
                },
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Tabla de clasificatoria
          Expanded(
            child: Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              decoration: BoxDecoration(
                color: kBackground2,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: kPrimary,
                      ),
                    )
                  : Column(
                      children: [
                        // Encabezado de tabla
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                          child: const Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: Text('Puesto', style: TextStyle(color: kText1, fontWeight: FontWeight.bold, fontSize: 18)),
                              ),
                              Expanded(
                                flex: 5,
                                child: Text('Nombre', style: TextStyle(color: kText1, fontWeight: FontWeight.bold, fontSize: 18)),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text('Puntaje', style: TextStyle(color: kText1, fontWeight: FontWeight.bold, fontSize: 18)),
                              ),
                            ],
                          ),
                        ),
                        const Divider(height: 1, thickness: 1, color: Colors.grey),

                        // Lista de jugadores
                        Expanded(
                          child: topPlayers.isEmpty
                              ? const Center(
                                  child: Text(
                                    "Sin datos para esta dificultad",
                                    style: TextStyle(color: kText1, fontSize: 18),
                                  ),
                                )
                              : ListView.builder(
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  itemCount: topPlayers.length,
                                  itemBuilder: (context, index) {
                                    final player = topPlayers[index];
                                    Widget puestoWidget;

                                    if (player['puesto'] == 1) {
                                      puestoWidget = Image.asset('assets/images/primero.png', width: 30, height: 30);
                                    } else if (player['puesto'] == 2) {
                                      puestoWidget = Image.asset('assets/images/segundo.png', width: 30, height: 30);
                                    } else if (player['puesto'] == 3) {
                                      puestoWidget = Image.asset('assets/images/tercero.png', width: 30, height: 30);
                                    } else if (player['puesto'] == 4) {
                                      puestoWidget = Image.asset('assets/images/cuarto.png', width: 30, height: 30);
                                    } else {
                                      puestoWidget = Text(
                                        '${player['puesto']}',
                                        style: const TextStyle(
                                          color: kText2,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20,
                                        ),
                                      );
                                    }

                                    return Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            flex: 2,
                                            child: Center(child: puestoWidget),
                                          ),
                                          Expanded(
                                            flex: 5,
                                            child: Text(
                                              player['nombre'],
                                              style: const TextStyle(
                                                color: kText1,
                                                fontSize: 20,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 3,
                                            child: Center(
                                              child: Text(
                                                '${player['puntaje']}',
                                                style: const TextStyle(
                                                  color: kText1,
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: MainNavBar(
        currentIndex: _selectedIndex,
        onTap: _onNavTap,
      ),
    );
  }
}
