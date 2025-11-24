import 'package:flutter/material.dart';
import '/pages/welcome_screen.dart';
import '/pages/login_screen.dart';
import '/pages/register_screen.dart';
import '/pages/main_menu_screen.dart';
import '/pages/custom_words.dart';
import '/pages/how_to_play.dart';
import '/pages/top_screen.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Juego de Cocina',
      initialRoute: '/',
      routes: {
        '/': (context) => const WelcomeScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/menu': (context) => const MainMenuScreen(),
        '/palabras': (context) => const CustomWordsScreen(),
        '/comojugar': (context) => const HowToPlayScreen(),
        '/top': (context) => const TopScreen(),
      },
    );
  }
}
