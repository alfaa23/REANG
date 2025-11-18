// Lokasi: lib/screens/ecomerce/admin/dialog_input_resi.dart

import 'package:flutter/material.dart';

class DialogInputResi extends StatefulWidget {
  final Function(String) onSubmit;

  const DialogInputResi({super.key, required this.onSubmit});

  @override
  State<DialogInputResi> createState() => _DialogInputResiState();
}

class _DialogInputResiState extends State<DialogInputResi> {
  final _formKey = GlobalKey<FormState>();
  final _resiController = TextEditingController();

  @override
  void dispose() {
    _resiController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      widget.onSubmit(_resiController.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final keyboardPadding = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        20,
        20,
        20 + keyboardPadding + bottomPadding, // Aman dari keyboard & bottom bar
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Input Resi Pengiriman',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _resiController,
              decoration: const InputDecoration(
                labelText: 'Nomor Resi',
                hintText: 'Masukkan nomor resi di sini...',
                border: OutlineInputBorder(),
              ),
              autofocus: true, // Langsung fokus
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Nomor resi tidak boleh kosong';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _submit,
              icon: const Icon(Icons.send_outlined),
              label: const Text('Kirim Pesanan'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
