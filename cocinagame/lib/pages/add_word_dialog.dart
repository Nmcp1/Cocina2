import 'package:flutter/material.dart';
import 'package:cocinagame/constants/theme.dart';

class AddWordDialog extends StatefulWidget {
  final Function(String) onAdd;

  const AddWordDialog({super.key, required this.onAdd});

  @override
  State<AddWordDialog> createState() => _AddWordDialogState();
}

class _AddWordDialogState extends State<AddWordDialog> {
  final TextEditingController _controller = TextEditingController();
  bool _loading = false;
  String? _errorMessage;

  Future<void> _handleAdd() async {
    final word = _controller.text.trim();

    if (word.isEmpty) {
      setState(() => _errorMessage = "La palabra no puede estar vacía.");
      return;
    }

    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      await widget.onAdd(word);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      setState(() => _errorMessage = "Error al agregar palabra: $e");
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: kBackground1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text(
        'Agregar palabra',
        style: TextStyle(color: kPrimary, fontWeight: FontWeight.bold),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _controller,
            decoration: const InputDecoration(
              hintText: 'Escribe una nueva palabra',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 10),
          if (_errorMessage != null)
            Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.red, fontSize: 14),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _loading ? null : () => Navigator.pop(context),
          child: const Text('Cancelar', style: TextStyle(color: kText1)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: kPrimary,
            foregroundColor: kBackground1,
          ),
          onPressed: _loading ? null : _handleAdd,
          child: _loading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: kBackground1,
                  ),
                )
              : const Text('Guardar'),
        ),
      ],
    );
  }
}
