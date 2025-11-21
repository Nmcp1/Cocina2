import 'package:flutter/material.dart';
import 'dart:ui';
import '../constants/theme.dart';

class EditWordDialog extends StatefulWidget {
  final String initialWord;
  final void Function(String word) onEdit;
  final void Function()? onDelete;

  const EditWordDialog({
    super.key,
    required this.initialWord,
    required this.onEdit,
    this.onDelete,
  });

  @override
  State<EditWordDialog> createState() => _EditWordDialogState();
}

class _EditWordDialogState extends State<EditWordDialog> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialWord);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Blur de fondo
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
              child: Container(
                color: Colors.black.withOpacity(0.05),
              ),
            ),
          ),
          // Modal principal
          Container(
            decoration: BoxDecoration(
              color: kBackground1,
              borderRadius: BorderRadius.circular(18),
            ),
            padding: const EdgeInsets.fromLTRB(24, 48, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Input y botón eliminar
                Row(
                  children: [
                    Expanded(
                      child: Material(
                        color: kBackground2,
                        borderRadius: BorderRadius.circular(12),
                        elevation: 2,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                          child: TextField(
                            controller: _controller,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Palabra personalizada',
                              hintStyle: TextStyle(fontSize: 18),
                            ),
                            style: const TextStyle(fontSize: 18),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Material(
                      color: kPrimary,
                      borderRadius: BorderRadius.circular(8),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(8),
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) => Dialog(
                              backgroundColor: Colors.transparent,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: kBackground1,
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                padding: const EdgeInsets.all(24),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Text(
                                      '¿Eliminar palabra?',
                                      style: TextStyle(
                                        color: kPrimary,
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: [
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: kBackground1,
                                            side: BorderSide(color: kSecondary, width: 2),
                                            elevation: 2,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                          ),
                                          onPressed: () => Navigator.pop(context),
                                          child: Text(
                                            'Cancelar',
                                            style: TextStyle(
                                              color: kSecondary,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18,
                                            ),
                                          ),
                                        ),
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: kSecondary,
                                            elevation: 2,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                          ),
                                          onPressed: () {
                                            Navigator.pop(context); // Cierra el modal de confirmación
                                            if (widget.onDelete != null) {
                                              widget.onDelete!();
                                            }
                                            Navigator.pop(context); // Cierra el modal de edición
                                          },
                                          child: const Text(
                                            'Eliminar',
                                            style: TextStyle(
                                              color: kBackground1,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                        child: const SizedBox(
                          width: 40,
                          height: 40,
                          child: Icon(Icons.delete, color: kBackground1, size: 28),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                // Botones
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kBackground1,
                        side: BorderSide(color: kSecondary, width: 2),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Volver',
                        style: TextStyle(
                          color: kSecondary,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kSecondary,
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {
                        final word = _controller.text.trim();
                        if (word.isNotEmpty) {
                          widget.onEdit(word);
                          Navigator.pop(context);
                        }
                      },
                      child: const Text(
                        'Editar',
                        style: TextStyle(
                          color: kBackground1,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Título sobresaliente
          Positioned(
            top: -32,
            left: 0,
            right: 0,
            child: Center(
              child: Material(
                color: kPrimary,
                borderRadius: BorderRadius.circular(12),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 32),
                  child: Text(
                    'Editar palabra',
                    style: const TextStyle(
                      color: kBackground1,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}