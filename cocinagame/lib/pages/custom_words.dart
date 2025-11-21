import 'package:flutter/material.dart';
import 'add_word_dialog.dart';
import 'edit_word_dialog.dart';
import '../constants/theme.dart';
import '../main_nav_bar.dart';

class CustomWordsScreen extends StatefulWidget {
  const CustomWordsScreen({super.key});

  @override
  State<CustomWordsScreen> createState() => _CustomWordsScreenState();
}

class _CustomWordsScreenState extends State<CustomWordsScreen> {
  int _selectedIndex = 1;
  final TextEditingController _searchController = TextEditingController();

  final List<String> customWords = List.generate(8, (index) => 'Palabra personalizada');

  void _onNavTap(int index) {
    setState(() {
      _selectedIndex = index;
      if (index == 0) {
        Navigator.pushNamed(context, '/menu');
      } else if (index == 1) {
      } else if (index == 2) {
        Navigator.pushNamed(context, '/top');
      } else if (index == 3) {
        Navigator.pushNamed(context, '/comojugar');
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
            margin: const EdgeInsets.only(top: 60, left: 16, right: 16, bottom: 16),
            width: double.infinity,
            child: Material(
              color: kPrimary,
              borderRadius: BorderRadius.circular(12),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Center(
                  child: Text(
                    'Palabras personalizadas',
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
                      prefixIcon: const Icon(Icons.search, color: kPrimary),
                      hintText: 'Buscar palabra',
                      hintStyle: const TextStyle(color: kText2),
                      filled: true,
                      fillColor: kBackground2,
                      contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 8),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: kPrimary, width: 2),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: kPrimary, width: 2),
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
                            setState(() {
                              customWords.add(word);
                            });
                          },
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
          // Lista de palabras personalizadas
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
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(vertical: 12),
                itemCount: customWords.length,
                physics: const BouncingScrollPhysics(), // <-- scroll suave
                separatorBuilder: (_, __) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Divider(
                    height: 14,
                    thickness: 1,
                    color: Colors.grey.withOpacity(0.65),
                  ),
                ),
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), // puedes ajustar vertical aquí también
                    child: Row(
                      children: [
                        // Ícono personalizado
                        Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: Colors.transparent, // Sin fondo, la imagen ya lo tiene
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
                            customWords[index],
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
                          borderRadius: BorderRadius.circular(8),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(8),
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (context) => EditWordDialog(
                                  initialWord: customWords[index],
                                  onEdit: (newWord) {
                                    setState(() {
                                      customWords[index] = newWord;
                                    });
                                  },
                                  onDelete: () {
                                    setState(() {
                                      customWords.removeAt(index);
                                    });
                                    // Solo cierra los modales, no navega fuera de la pantalla
                                  },
                                ),
                              );
                            },
                            child: const SizedBox(
                              width: 32,
                              height: 32,
                              child: Icon(Icons.edit, color: kBackground1, size: 22),
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
        ],
      ),
      bottomNavigationBar: MainNavBar(
        currentIndex: _selectedIndex,
        onTap: _onNavTap,
      ),
    );
  }
}