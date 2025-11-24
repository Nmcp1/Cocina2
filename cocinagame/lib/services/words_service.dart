import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class WordsService {
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;

  /// Ruta: users / uid / palabras
  CollectionReference<Map<String, dynamic>> _userWords() {
    final uid = _auth.currentUser!.uid;
    return _db.collection('users').doc(uid).collection('palabras');
  }

  /// LEER palabras en tiempo real
  Stream<QuerySnapshot<Map<String, dynamic>>> getWordsStream() {
    return _userWords().orderBy('createdAt', descending: false).snapshots();
  }

  /// AGREGAR palabra
  Future<void> addWord(String palabra) async {
    await _userWords().add({
      'palabra': palabra,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// EDITAR palabra
  Future<void> editWord(String docId, String newWord) async {
    await _userWords().doc(docId).update({
      'palabra': newWord,
    });
  }

  /// ELIMINAR palabra
  Future<void> deleteWord(String docId) async {
    await _userWords().doc(docId).delete();
  }
}
