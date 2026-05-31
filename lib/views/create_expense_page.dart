import 'package:flutter/material.dart';

import '../data/database/app_database.dart';

class CreateExpensePage extends StatefulWidget {
  final List<User> participants;

  const CreateExpensePage({
    super.key,
    required this.participants,
  });

  @override
  State<CreateExpensePage> createState() => _CreateExpensePageState();
}

class _CreateExpensePageState extends State<CreateExpensePage> {
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final valorController = TextEditingController();

  late List<int> selectedUserIds;

  @override
  void initState() {
    super.initState();
    selectedUserIds = widget.participants.map((user) => user.id).toList();
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    valorController.dispose();
    super.dispose();
  }

  void guardarDespesa() {
    final title = titleController.text.trim();
    final description = descriptionController.text.trim();
    final valor = double.tryParse(
      valorController.text.trim().replaceAll(',', '.'),
    );

    if (title.isEmpty || valor == null || valor <= 0 || selectedUserIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preenche os campos corretamente.')),
      );
      return;
    }

    Navigator.pop(context, {
      'title': title,
      'description': description.isEmpty ? null : description,
      'amountCents': (valor * 100).round(),
      'splitUserIds': selectedUserIds,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Criar Despesa'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                labelText: 'Título',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
            const SizedBox(height: 18),
            TextField(
              controller: descriptionController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Descrição opcional',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
            const SizedBox(height: 18),
            TextField(
              controller: valorController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                labelText: 'Valor (€)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Dividir despesa entre:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 8),
            ...widget.participants.map((user) {
              final isSelected = selectedUserIds.contains(user.id);

              return CheckboxListTile(
                value: isSelected,
                title: Text(user.name),
                subtitle: Text(user.email),
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                onChanged: (value) {
                  setState(() {
                    if (value == true) {
                      selectedUserIds.add(user.id);
                    } else {
                      selectedUserIds.remove(user.id);
                    }
                  });
                },
              );
            }),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Cancelar'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: guardarDespesa,
                    child: const Text('Guardar'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}