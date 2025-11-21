import 'package:flutter/material.dart';
import 'dart:ui';
import '../constants/theme.dart';

class AddWordDialog extends StatefulWidget {
  final void Function(String word) onAdd;

  const AddWordDialog({super.key, required this.onAdd});

  @override
  State<AddWordDialog> createState() => _AddWordDialogState();
}

class _AddWordDialogState extends State<AddWordDialog> {
  final TextEditingController _controller = TextEditingController();

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
                // Input
                Material(
                  color: kBackground2,
                  borderRadius: BorderRadius.circular(12),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Ingrese la palabra',
                        hintStyle: TextStyle(fontSize: 18),
                      ),
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                ),
                const SizedBox(height:40),
                // Botones alineados como en configurar partida
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
                        if (_controller.text.trim().isNotEmpty) {
                          widget.onAdd(_controller.text.trim());
                          Navigator.pop(context);
                        }
                      },
                      child: const Text(
                        'Agregar',
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
          // Título sobresaliente igual que configurar partida
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
                    'Agregar palabra',
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