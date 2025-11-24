import 'package:flutter/material.dart';
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

  // Simulación de datos de clasificatoria
  final List<Map<String, dynamic>> topPlayers = [
    {'puesto': 1, 'nombre': 'Nombre', 'recetas': 9},
    {'puesto': 2, 'nombre': 'Nombre', 'recetas': 9},
    {'puesto': 3, 'nombre': 'Nombre', 'recetas': 9},
    {'puesto': 4, 'nombre': 'Nombre', 'recetas': 8},
    {'puesto': 5, 'nombre': 'Nombre', 'recetas': 8},
    {'puesto': 6, 'nombre': 'Nombre', 'recetas': 6},
    {'puesto': 7, 'nombre': 'Nombre', 'recetas': 7},
    {'puesto': 8, 'nombre': 'Nombre', 'recetas': 7},
    {'puesto': 9, 'nombre': 'Nombre', 'recetas': 7},
    {'puesto': 10, 'nombre': 'Nombre', 'recetas': 5},
    {'puesto': 11, 'nombre': 'Nombre', 'recetas': 4},
    {'puesto': 12, 'nombre': 'Nombre', 'recetas': 3},
  ];

  final List<String> difficulties = ['Dificultad', 'Fácil', 'Media', 'Difícil'];

  void _onNavTap(int index) {
    setState(() {
      _selectedIndex = index;
      if (index == 0) {
        Navigator.pushNamed(context, '/menu');
      } else if (index == 1) {
        Navigator.pushNamed(context, '/palabras');
      } else if (index == 2) {
        // Ya estás en Top
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
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Center(
                  child: Text(
                    'Clasificatorias',
                    style: const TextStyle(
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
            padding: const EdgeInsets.symmetric(horizontal: 135, vertical: 0),
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
                    // Aquí podrías filtrar los datos según la dificultad
                  });
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
              child: Column(
                children: [
                  // Encabezado de tabla
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                    child: Row(
                      children: const [
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
                          child: Text('Recetas', style: TextStyle(color: kText1, fontWeight: FontWeight.bold, fontSize: 18)),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1, thickness: 1, color: Colors.grey),
                  // Lista de jugadores
                  Expanded(
                    child: ListView.builder(
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
                            style: TextStyle(
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
                                    '${player['recetas']}',
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