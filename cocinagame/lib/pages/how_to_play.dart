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
        Navigator.pushNamed(context, '/top');
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
            margin: const EdgeInsets.only(
                top: 60, left: 16, right: 16, bottom: 16),
            width: double.infinity,
            child: Material(
              color: kPrimary,
              borderRadius: BorderRadius.circular(12),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Center(
                  child: Text(
                    '¿Cómo jugar?',
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
          Expanded(
            child: Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              width: double.infinity,
              constraints: const BoxConstraints(minHeight: 300), // Mantiene altura mínima
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: Text(
                    '''
Cocina2 (Edición 2 jugadores)

OBJETIVO
Completar la receta secreta seleccionando los ingredientes correctos según sus colores ocultos.
El Chef conoce los colores. El Cocinero solo ve los textos.
Si el jugador selecciona el ingrediente negro, el juego termina inmediatamente.

COMPONENTES
• Tarjetas de ingredientes con texto visible y color oculto.

COLORES POSIBLES
• Receta (color correcto): avanza en la receta.
• Incorrecto: pierdes la receta y 1 vida.
• Neutro: no aporta; pierdes un turno.
• Negro: ingrediente tóxico; fin del juego.

CÓMO JUGAR
1. Prepara un tablero 3×6 con 18 cartas.
2. El Chef ve la receta (colores requeridos y sus cantidades).
3. El Cocinero solo ve los textos.

TURNO
1. El Chef da 1 palabra + 1 número (ej: “Fruta 2”).
   Debe relacionar textos y colores correctos de la receta.
2. El Cocinero elige cartas una a una.
3. Tras cada elección se revela el color y se aplica la regla.
4. Se juega con 3 vidas.

OBJETIVO
Completar todos los colores de la receta antes de:
• Perder las 3 vidas,
• Tocar la bomba.

REGLAS DE COLOR
• Color de receta:
  - Si aún está pendiente → correcto, avanza.
  - Si ya fue completado → receta arruinada, pierdes 1 vida.

• Color neutro:
  - No está en la receta → receta arruinada y pierdes 1 vida.

• Negro:
  - Fin inmediato del juego.

CONSEJO PRÁCTICO
El Chef debe conectar significado y color en la pista.  
Si dudas, planta. Si caes en negro, adiós cocina.

ROLES
CHEF
• Conoce la receta completa.
• Da la pista de 1 palabra + número.

COCINERO
• Solo ve los textos.
• Elige tarjetas basándose en la pista.

TURNO DE JUEGO
• Correcta → avanza progresión.
• Neutra → pierdes turno.
• Incorrecta → pierdes 1 vida.
• Negra → derrota inmediata.

FIN DEL JUEGO
Victoria:
• Se completan todos los colores antes de perder vidas.

Derrota:
• Se toca negro.
• Se pierden las 3 vidas.

NIVELES DE DIFICULTAD

FÁCIL
• Receta: 1–2 colores.
• Mínimo 4 cartas del color de receta.
• Al menos 5 colores distintos en tablero.
• 1 carta negra.

MEDIO
• Receta: 2–4 colores.
• Mínimo 3 cartas requeridas.
• Al menos 4 colores distintos en tablero.
• 1 carta negra.

DIFÍCIL
• Receta: 3–5 colores.
• Mínimo 3 colores de receta presentes.
• 2 cartas negras.
• Al menos 4 colores distintos totales.
                    ''',
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.4,
                      color: Colors.black87,
                    ),
                  ),
                ),
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
