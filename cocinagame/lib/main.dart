import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'firebase_options.dart';         // 👈 generado por FlutterFire

import 'pages/welcome_screen.dart';
import 'pages/login_screen.dart';
import 'pages/register_screen.dart';
import 'pages/main_menu_screen.dart';
import 'pages/custom_words.dart';
import 'pages/how_to_play.dart';
import 'pages/top_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 👇 INICIALIZAR FIREBASE ANTES DE USARLO (muy importante en web)
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

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
        '/': (context) => const AuthWrapper(),
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

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData) {
          return const MainMenuScreen();   // usuario logeado → menú
        }

        return const WelcomeScreen();      // sin usuario → pantalla inicial
      },
    );
  }
}
