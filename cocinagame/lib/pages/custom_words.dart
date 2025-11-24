import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:cocinagame/pages/add_word_dialog.dart';
import 'package:cocinagame/pages/edit_word_dialog.dart';
import 'package:cocinagame/constants/theme.dart';
import 'package:cocinagame/main_nav_bar.dart';

class CustomWordsScreen extends StatefulWidget {
  const CustomWordsScreen({super.key});

  @override
  State<CustomWordsScreen> createState() => _CustomWordsScreenState();
}

class _CustomWordsScreenState extends State<CustomWordsScreen> {
  final TextEditingController _searchController = TextEditingController();

  int _selectedIndex = 1;

  /// Resultado del buscador
  String searchQuery = "";

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        searchQuery = _searchController.text.trim();
      });
    });
  }

  // --------------------------------------------------------------------
  // FIRESTORE: Referencia
  // --------------------------------------------------------------------
  CollectionReference<Map<String, dynamic>> _wordsRef() {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('palabras'); // <-- NUEVO NOMBRE FINAL
  }

  // --------------------------------------------------------------------
  // CRUD FIRESTORE
  // --------------------------------------------------------------------

  Future<void> _addWord(String word) async {
    await _wordsRef().add({
      'palabra': word,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> _editWord(String id, String newWord) async {
    await _wordsRef().doc(id).update({'palabra': newWord});
  }

  Future<void> _deleteWord(String id) async {
    await _wordsRef().doc(id).delete();
  }

  // --------------------------------------------------------------------
  // NAV BAR
  // --------------------------------------------------------------------

  void _onNavTap(int index) {
    setState(() => _selectedIndex = index);

    if (index == 0) {
      Navigator.pushNamed(context, '/menu');
    } else if (index == 2) {
      Navigator.pushNamed(context, '/clasificaciones');
    } else if (index == 3) {
      Navigator.pushNamed(context, '/comojugar');
    }
  }

  // --------------------------------------------------------------------
  // UI
  // --------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground1,
      body: Column(
        children: [
          // ------------------ TÍTULO -------------------
          Container(
            margin: const EdgeInsets.only(top: 60, left: 16, right: 16, bottom: 16),
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

          // ------------------ BUSCADOR + AGREGAR -------------------
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
                      prefixIcon: const Icon(Icons.search, color: kPrimary),
                      hintText: 'Buscar palabra',
                      hintStyle: const TextStyle(color: kText2),
                      filled: true,
                      fillColor: kBackground2,
                      contentPadding:
                          const EdgeInsets.symmetric(vertical: 0, horizontal: 8),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: kPrimary, width: 2),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: kPrimary, width: 2),
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
                        builder: (_) => AddWordDialog(
                          onAdd: (word) => _addWord(word),
                        ),
                      );
                    },
                    child: const SizedBox(
                      width: 40,
                      height: 40,
                      child: Icon(Icons.add, color: kBackground1, size: 28),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ------------------ LISTA (StreamBuilder) -------------------
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
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
              child: StreamBuilder<QuerySnapshot>(
                stream: _wordsRef()
                    .orderBy('createdAt', descending: false)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Text(
                        'Sin palabras aún…\nUsa el botón + para agregar',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: kText2, fontSize: 18),
                      ),
                    );
                  }

                  final docs = snapshot.data!.docs;

                  // Aplicar buscador
                  final filtered = docs.where((doc) {
                    final text = doc['palabra'] ?? '';
                    return text.toLowerCase().contains(searchQuery.toLowerCase());
                  }).toList();

                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => Divider(
                      height: 16,
                      thickness: 1,
                      color: Colors.grey.withOpacity(0.6),
                    ),
                    itemBuilder: (context, index) {
                      final doc = filtered[index];
                      final wordId = doc.id;
                      final text = doc['palabra'] ?? '';

                      return ListTile(
                        leading: Image.asset(
                          'assets/images/icon_word.png',
                          width: 32,
                          height: 32,
                        ),
                        title: Text(
                          text,
                          style: const TextStyle(
                            fontSize: 18,
                            color: kText1,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        trailing: Material(
                          color: kPrimary,
                          borderRadius: BorderRadius.circular(8),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(8),
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (_) => EditWordDialog(
                                  initialWord: text,
                                  onEdit: (newWord) => _editWord(wordId, newWord),
                                  onDelete: () => _deleteWord(wordId),
                                ),
                              );
                            },
                            child: const SizedBox(
                              width: 32,
                              height: 32,
                              child: Icon(Icons.edit,
                                  color: kBackground1, size: 22),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
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
