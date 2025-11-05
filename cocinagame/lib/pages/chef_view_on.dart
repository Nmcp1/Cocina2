import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/bxs.dart';
import 'package:iconify_flutter/icons/mdi.dart';
import '../constants/theme.dart';
import 'cook_view_on.dart';

class ChefViewOn extends StatefulWidget {
  const ChefViewOn({super.key});

  @override
  State<ChefViewOn> createState() => _ChefViewOnState();
}

class _ChefViewOnState extends State<ChefViewOn> {
  bool _showOcultas = false;
  String _clue = '';
  String _number = '';
  final TextEditingController _clueController = TextEditingController();
  final TextEditingController _numberController = TextEditingController();

  // Colores originales (24 palabras)
  final List<Color> wordColorsOriginal = [
    kSecondary, kSecondary, kSecondary,
    kBeterraga, kCebolla, kCebolla,
    kCebolla, kOcultas, kBeterraga,
    kOcultas, kSecondary, kBeterraga,
    kBeterraga, kCebolla, kText1,
    kSecondary, kSecondary, kOcultas,
    kBeterraga, kCebolla, kOcultas,
    kSecondary, kSecondary, kSecondary,
  ];

  @override
  Widget build(BuildContext context) {
    final List<Color> wordColors = _showOcultas
        ? List<Color>.filled(wordColorsOriginal.length, kOcultas)
        : wordColorsOriginal;

    return Scaffold(
      backgroundColor: kBackground1,
      body: Column(
        children: [
          // Header: salir, turno, ojo
          Container(
            color: kPrimary,
            padding: const EdgeInsets.only(top: 55, left: 16, right: 16, bottom: 10),
            child: SizedBox(
              height: 50,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Botón salir
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: kBackground1, size: 32),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  // Botón Turno Chef centrado
                  Center(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kSecondary,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 0),
                      ),
                      onPressed: () {},
                      child: const Text(
                        'Turno Chef',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ),
                  // Ojo alineado a la derecha
                  Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _showOcultas = !_showOcultas;
                        });
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: kBackground1,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Iconify(
                            _showOcultas ? Mdi.eye_off : Mdi.eye,
                            color: kSecondary,
                            size: 32,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Segunda fila: íconos, timer, contadores
          Container(
            color: kBackground1,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                // Íconos circulares
                _roundIcon(kSecondary, isYellow: true),
                const SizedBox(width: 10),
                _roundIcon(kSecondary, isYellow: true),
                const SizedBox(width: 10),
                _roundIcon(kSecondary, isYellow: true),
                const SizedBox(width: 22),
                // Timer
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: kCebolla,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Text(
                    '05:00',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(width: 36),
                // Contador 1
                Container(
                  width: 48,
                  height: 40,
                  decoration: BoxDecoration(
                    color: kBackground2,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.10),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Iconify(kBowl, size: 32, color: kPrimary),
                      const SizedBox(width: 2),
                      const Text(
                        '0',
                        style: TextStyle(
                          color: kText1,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Contador 2
                Container(
                  width: 48,
                  height: 40,
                  decoration: BoxDecoration(
                    color: kBackground2,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.10),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.track_changes, color: kSecondary, size: 22),
                      const SizedBox(width: 2),
                      const Text(
                        '1',
                        style: TextStyle(
                          color: kText1,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Grid de palabras
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: GridView.builder(
                padding: EdgeInsets.zero,
                itemCount: wordColors.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 2.2,
                ),
                itemBuilder: (context, index) {
                  final color = wordColors[index];
                  final bool isOcultas = color == kOcultas;
                  return Container(
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isOcultas ? kSecondary : (color == kSecondary ? kSecondary : Colors.transparent),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        'Palabra',
                        style: TextStyle(
                          color: isOcultas ? kText1 : kBackground1,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          // Input pista y número + ícono enviar a la derecha
          Container(
            color: kPrimary,
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
            child: Row(
              children: [
                Expanded(
                  flex: 4,
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: TextField(
                          controller: _clueController,
                          decoration: InputDecoration(
                            hintText: 'Ingrese la pista',
                            hintStyle: const TextStyle(color: kText2),
                            filled: true,
                            fillColor: kBackground2,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 1,
                        child: TextField(
                          controller: _numberController,
                          decoration: InputDecoration(
                            hintText: 'Nº',
                            hintStyle: const TextStyle(color: kText2),
                            filled: true,
                            fillColor: kBackground2,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // Ícono enviar
                Container(
                  decoration: BoxDecoration(
                    color: kSecondary,
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_forward, color: Colors.white),
                    onPressed: () {
                      // Validar campos requeridos
                      if (_clueController.text.trim().isEmpty ||
                          _numberController.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Debes ingresar la pista y el número.'),
                          ),
                        );
                        return;
                      }
                      setState(() {
                        _clue = _clueController.text.trim();
                        _number = _numberController.text.trim();
                        _showOcultas = false;
                      });

                      // Navegar a la vista del cocinero y pasar los datos
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CookViewOn(
                            clue: _clue,
                            number: _number,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _roundIcon(Color color, {bool isYellow = false, double circleSize = 40, double iconSize = 28}) {
    return Container(
      width: circleSize,
      height: circleSize,
      decoration: BoxDecoration(
        color: isYellow ? kSecondary : kBackground2,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Iconify(
          Bxs.book_heart,
          color: isYellow ? kBackground2 : kSecondary,
          size: iconSize,
        ),
      ),
    );
  }
}