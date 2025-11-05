import 'package:flutter/material.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/bxs.dart';
import '../constants/theme.dart';

class CookViewOn extends StatefulWidget {
  final String clue;
  final String number;

  const CookViewOn({
    super.key,
    required this.clue,
    required this.number,
  });

  @override
  State<CookViewOn> createState() => _CookViewOnState();
}

class _CookViewOnState extends State<CookViewOn> {
  // Mantiene el estado de selección de cada palabra
  final Set<int> selectedIndices = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground1,
      body: Column(
        children: [
          // Header: solo Ronda y Turno Cocinero (sin ojo)
          Container(
            color: kPrimary,
            padding: const EdgeInsets.only(top: 60, left: 16, right: 16, bottom: 12),
            child: SizedBox(
              height: 40,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text.rich(
                      TextSpan(
                        text: 'Ronda ',
                        style: const TextStyle(
                          color: kBackground1,
                          fontSize: 18,
                          fontWeight: FontWeight.normal,
                        ),
                        children: [
                          TextSpan(
                            text: '1',
                            style: const TextStyle(
                              color: kBackground1,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Center(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kSecondary,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {},
                      child: const Text(
                        'Turno Cocinero',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Íconos y entregas
          Container(
            color: kBackground1,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Row(
                  children: [
                    _roundIcon(kSecondary, isYellow: true),
                    const SizedBox(width: 12),
                    _roundIcon(kBackground2, isYellow: false),
                    const SizedBox(width: 12),
                    _roundIcon(kBackground2, isYellow: false),
                  ],
                ),
                const Spacer(),
                Text.rich(
                  TextSpan(
                    text: 'Entregas ',
                    style: const TextStyle(
                      color: kText1,
                      fontSize: 18,
                      fontWeight: FontWeight.normal,
                    ),
                    children: [
                      TextSpan(
                        text: '0',
                        style: const TextStyle(
                          color: kText1,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Grid de palabras siempre ocultas y clickeables
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: GridView.builder(
                padding: EdgeInsets.zero,
                itemCount: 24,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 2.2,
                ),
                itemBuilder: (context, index) {
                  final isSelected = selectedIndices.contains(index);
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          selectedIndices.remove(index);
                        } else {
                          selectedIndices.add(index);
                        }
                      });
                    },
                    child: Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: kOcultas,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: kSecondary,
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
                              style: const TextStyle(
                                color: kText1,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ),
                        if (isSelected)
                          Positioned(
                            top: 6,
                            right: 6,
                            child: Container(
                              width: 18,
                              height: 18,
                              decoration: BoxDecoration(
                                color: kPrimary,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.18),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                                border: Border.all(
                                  color: Colors.white,
                                  width: 0.5,
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
          ),
          // Pista y número mostrados + botón enviar para volver
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
                        child: Container(
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          decoration: BoxDecoration(
                            color: kBackground2,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Text(
                            widget.clue,
                            style: const TextStyle(
                              color: kText1,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 1,
                        child: Container(
                          alignment: Alignment.center,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          decoration: BoxDecoration(
                            color: kBackground2,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Text(
                            widget.number,
                            style: const TextStyle(
                              color: kText1,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  decoration: BoxDecoration(
                    color: kSecondary,
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_forward, color: Colors.white),
                    onPressed: () {
                      Navigator.pop(context);
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

  Widget _roundIcon(Color color, {bool isYellow = false, double circleSize = 45, double iconSize = 32}) {
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