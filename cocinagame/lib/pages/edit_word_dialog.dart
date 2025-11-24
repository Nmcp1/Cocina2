import 'package:flutter/material.dart';
import 'package:cocinagame/constants/theme.dart';

class EditWordDialog extends StatefulWidget {
  final String initialWord;
  final Function(String) onEdit;
  final VoidCallback onDelete;

  const EditWordDialog({
    super.key,
    required this.initialWord,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<EditWordDialog> createState() => _EditWordDialogState();
}

class _EditWordDialogState extends State<EditWordDialog> {
  late TextEditingController _controller;
  bool _loading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialWord);
  }

  Future<void> _handleSave() async {
    final newWord = _controller.text.trim();

    if (newWord.isEmpty) {
      setState(() => _errorMessage = "La palabra no puede estar vacía.");
      return;
    }

    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      await widget.onEdit(newWord);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      setState(() => _errorMessage = "Error al guardar cambios: $e");
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _handleDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Confirmar eliminación"),
        content: const Text("¿Seguro que deseas eliminar esta palabra?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Eliminar"),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => _loading = true);
      try {
        widget.onDelete();
        if (mounted) Navigator.pop(context);
      } catch (e) {
        setState(() => _errorMessage = "Error al eliminar: $e");
      } finally {
        if (mounted) setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: kBackground1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text(
        'Editar palabra',
        style: TextStyle(color: kPrimary, fontWeight: FontWeight.bold),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _controller,
            decoration: const InputDecoration(
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
        TextButton(
          onPressed: _loading ? null : _handleDelete,
          child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: kPrimary,
            foregroundColor: kBackground1,
          ),
          onPressed: _loading ? null : _handleSave,
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
