import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cocinagame/game_logic.dart';

class ScoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> saveGameScore(Game game) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('No hay usuario logueado, no se puede guardar el puntaje.');
    }

    final data = game.exportScore(
      playerName: user.displayName ?? user.email ?? 'Anónimo',
    );

    await _db.collection('scores').add({
      ...data, // player_name + score
      'userId': user.uid,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
