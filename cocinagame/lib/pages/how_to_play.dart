import 'package:flutter/material.dart';
import '../constants/theme.dart';
import '../main_nav_bar.dart';

class HowToPlayScreen extends StatefulWidget {
  const HowToPlayScreen({super.key});

  @override
  State<HowToPlayScreen> createState() => _HowToPlayState();
}

class _HowToPlayState extends State<HowToPlayScreen> {
  int _selectedIndex = 3;

  void _onNavTap(int index) {
    setState(() {
      _selectedIndex = index;
      if (index == 0) {
        Navigator.pushNamed(context, '/menu');
      } else if (index == 1) {
        Navigator.pushNamed(context, '/palabras');
      } else if (index == 2) {
        Navigator.pushNamed(context, '/clasificaciones');
      } else if (index == 3) {
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground1,
      body: Row(
        children: const [
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Título rojo
                  Padding(
                    padding: EdgeInsets.only(bottom: 20),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Color(0xFF9C1C1C),
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 14),
                        child: Center(
                          child: Text(
                            'Cómo jugar',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Card de texto
                  Expanded(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                        boxShadow: [
                          BoxShadow(
                            color: Color.fromARGB(40, 0, 0, 0),
                            blurRadius: 6,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: Text(
                          'Generar texto de cómo jugar a COCINA2',
                          style: TextStyle(
                            fontSize: 16,
                            height: 1.4,
                            color: Colors.black87,
                          ),
                        ),
                      ),
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
