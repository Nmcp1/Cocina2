import 'package:flutter/material.dart';
import 'add_word_dialog.dart';
import 'edit_word_dialog.dart';
import '../constants/theme.dart';
import '../main_nav_bar.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';
import 'package:diacritic/diacritic.dart';

// Firebase
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CustomWordsScreen extends StatefulWidget {
  const CustomWordsScreen({super.key});

  @override
  State<CustomWordsScreen> createState() => _CustomWordsScreenState();
}

class _CustomWordsScreenState extends State<CustomWordsScreen> {
  int _selectedIndex = 1;
  final TextEditingController _searchController = TextEditingController();
  List<String> customWords = [];
  bool _isLoading = false; // <-- NUEVO

  // Palabras filtradas según el buscador
  List<String> get filteredWords {
    final query = removeDiacritics(_searchController.text.trim().toLowerCase());
    if (query.isEmpty) return customWords;
    return customWords
        .where((word) =>
            removeDiacritics(word.toLowerCase()).contains(query))
        .toList();
  }

  void _onNavTap(int index) {
    setState(() {
      _selectedIndex = index;
      if (index == 0) {
        Navigator.pushNamed(context, '/menu');
      } else if (index == 1) {
        // Ya estás en palabras personalizadas
      } else if (index == 2) {
        Navigator.pushNamed(context, '/top');
      } else if (index == 3) {
        Navigator.pushNamed(context, '/comojugar');
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {}); // Actualiza la vista al escribir en el buscador
    });
    _loadWords();
  }

  /// Referencia al documento de palabras del usuario actual:
  /// users/{uid}/custom_data/words
  DocumentReference<Map<String, dynamic>>? get _userWordsDoc {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;
    return FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('custom_data')
        .doc('words');
  }

  Future<void> _loadWords() async {
    setState(() {
      _isLoading = true; // <-- NUEVO
    });
    try {
      final docRef = _userWordsDoc;
      if (docRef == null) {
        debugPrint('No hay usuario logueado, no se cargan palabras.');
        return;
      }

      final snapshot = await docRef.get();
      if (snapshot.exists) {
        final data = snapshot.data();
        final List<dynamic> wordsDynamic = data?['words'] ?? [];
        setState(() {
          customWords = List<String>.from(wordsDynamic);
        });
      } else {
        setState(() {
          customWords = [];
        });
      }
    } catch (e) {
      debugPrint('Error cargando palabras personalizadas: $e');
    } finally {
      setState(() {
        _isLoading = false; // <-- NUEVO
      });
    }
  }

  Future<void> _saveWords() async {
    try {
      final docRef = _userWordsDoc;
      if (docRef == null) {
        debugPrint('No hay usuario logueado, no se guardan palabras.');
        return;
      }

      await docRef.set(
        {
          'words': customWords,
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
    } catch (e) {
      debugPrint('Error guardando palabras personalizadas: $e');
    }
  }

  // Al agregar palabra
  void _addWord(String word) {
    setState(() {
      customWords.add(word);
    });
    _saveWords();
  }

  // Al editar palabra
  void _editWord(int index, String newWord) {
    setState(() {
      customWords[index] = newWord;
    });
    _saveWords();
  }

  // Al eliminar palabra
  void _deleteWord(int index) {
    setState(() {
      customWords.removeAt(index);
    });
    _saveWords();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Center(
                  child: Text(
                    'Palabras personalizadas',
                    style: TextStyle(
                      color: kBackground1,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Buscador y botón agregar
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(8),
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
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(
                        MingCuteIcons.mgc_search_3_fill,
                        color: kPrimary,
                        size: 26,
                      ),
                      hintText: 'Buscar palabra',
                      hintStyle: const TextStyle(color: kText2),
                      filled: true,
                      fillColor: kBackground1,
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 0, horizontal: 8),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide:
                            const BorderSide(color: kPrimary, width: 1),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide:
                            const BorderSide(color: kPrimary, width: 1),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Material(
                  color: kSecondary,
                  borderRadius: BorderRadius.circular(8),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => AddWordDialog(
                          onAdd: (word) {
                            _addWord(word);
                          },
                        ),
                      );
                    },
                    child: const SizedBox(
                      width: 40,
                      height: 40,
                      child: Icon(Icons.add,
                          color: kBackground1, size: 28),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Lista de palabras personalizadas
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
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: kPrimary,
                      ),
                    )
                  : (filteredWords.isEmpty
                      ? const Center(
                          child: Text(
                            'No hay palabras personalizadas',
                            style: TextStyle(
                              color: kText2,
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        )
                      : ListView.separated(
                          padding:
                              const EdgeInsets.symmetric(vertical: 12),
                          itemCount: filteredWords.length,
                          physics:
                              const BouncingScrollPhysics(),
                          separatorBuilder: (_, __) => Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8),
                            child: Divider(
                              height: 14,
                              thickness: 1,
                              color:
                                  Colors.grey.withOpacity(0.65),
                            ),
                          ),
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              child: Row(
                                children: [
                                  // Ícono personalizado
                                  Container(
                                    width: 34,
                                    height: 34,
                                    decoration: const BoxDecoration(
                                      color: Colors.transparent,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Image.asset(
                                        'assets/images/icon_word.png',
                                        width: 32,
                                        height: 32,
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      filteredWords[index],
                                      style: const TextStyle(
                                        color: kText1,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  // Botón editar para cada palabra
                                  Material(
                                    color: kPrimary,
                                    borderRadius:
                                        BorderRadius.circular(8),
                                    child: InkWell(
                                      borderRadius:
                                          BorderRadius.circular(8),
                                      onTap: () {
                                        showDialog(
                                          context: context,
                                          builder: (context) =>
                                              EditWordDialog(
                                            initialWord:
                                                filteredWords[index],
                                            onEdit: (newWord) {
                                              final originalIndex =
                                                  customWords.indexOf(
                                                      filteredWords[
                                                          index]);
                                              if (originalIndex != -1) {
                                                _editWord(originalIndex,
                                                    newWord);
                                              }
                                            },
                                            onDelete: () {
                                              final originalIndex =
                                                  customWords.indexOf(
                                                      filteredWords[
                                                          index]);
                                              if (originalIndex != -1) {
                                                _deleteWord(
                                                    originalIndex);
                                              }
                                            },
                                          ),
                                        );
                                      },
                                      child: const SizedBox(
                                        width: 32,
                                        height: 32,
                                        child: Icon(Icons.edit,
                                            color: kBackground1,
                                            size: 22),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        )),
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
