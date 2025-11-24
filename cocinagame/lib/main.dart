import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:cocinagame/firebase_options.dart';

// Páginas
import 'package:cocinagame/pages/welcome_screen.dart';
import 'package:cocinagame/pages/login_screen.dart';
import 'package:cocinagame/pages/register_screen.dart';
import 'package:cocinagame/pages/main_menu_screen.dart';
import 'package:cocinagame/pages/custom_words.dart';
import 'package:cocinagame/pages/how_to_play.dart';

//import 'package:cocinagame/pages/how_to_play.dart';
// Servicios
import 'package:cocinagame/services/auth_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = AuthService();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Juego de Cocina',

      // ⭐ Control central de flujo de autenticación
      home: StreamBuilder(
        stream: auth.authState,
        builder: (context, snapshot) {
          // Cargando Firebase
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          
          if (snapshot.hasData) {
            return const MainMenuScreen();
          }

          
          return const WelcomeScreen();
        },
      ),

      // ⭐ Navegación con rutas nombradas
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/menu': (context) => const MainMenuScreen(),
        '/palabras': (context) => const CustomWordsScreen(),
        '/comojugar': (context) => const HowToPlayScreen(),
      },
    );
  }
}
