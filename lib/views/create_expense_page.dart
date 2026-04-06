import 'package:flutter/material.dart';
import '../models/expense.dart';

class CreateExpensePage extends StatefulWidget {
  const CreateExpensePage({super.key});

  @override
  State<CreateExpensePage> createState() => _CreateExpensePageState();
}

class _CreateExpensePageState extends State<CreateExpensePage> {
  final descricaoController = TextEditingController();
  final valorController = TextEditingController();
  final pagoPorController = TextEditingController();

  @override
  void dispose() {
    descricaoController.dispose();
    valorController.dispose();
    pagoPorController.dispose();
    super.dispose();
  }

  void guardarDespesa() {
    final descricao = descricaoController.text.trim();
    final valor = double.tryParse(valorController.text.trim());
    final pagoPor = pagoPorController.text.trim();

    if (descricao.isEmpty || valor == null || pagoPor.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Preenche todos os campos corretamente.'),
        ),
      );
      return;
    }

    final despesa = Expense(
      descricao: descricao,
      valor: valor,
      pagoPor: pagoPor,
    );

    Navigator.pop(context, despesa);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Criar Despesa'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: descricaoController,
              decoration: InputDecoration(
                labelText: 'Descrição',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
            const SizedBox(height: 18),
            TextField(
              controller: valorController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Valor (€)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
            const SizedBox(height: 18),
            TextField(
              controller: pagoPorController,
              decoration: InputDecoration(
                labelText: 'Pago por',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
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