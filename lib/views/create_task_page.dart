import 'package:flutter/material.dart';
import '../models/task.dart';

class CreateTaskPage extends StatefulWidget {
  final List<String> participantes;

  const CreateTaskPage({super.key, required this.participantes});

  @override
  State<CreateTaskPage> createState() => _CreateTaskPageState();
}

class _CreateTaskPageState extends State<CreateTaskPage> {
  final descricaoController = TextEditingController();
  String? responsavelSelecionado;

  @override
  void dispose() {
    descricaoController.dispose();
    super.dispose();
  }

  void guardarTarefa() {
    final descricao = descricaoController.text.trim();
    final responsavel = responsavelSelecionado;

    if (descricao.isEmpty || responsavel == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Preenche todos os campos.'),
        ),
      );
      return;
    }

    final tarefa = Task(
      descricao: descricao,
      responsavel: responsavel,
    );

    Navigator.pop(context, tarefa);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Criar Tarefa'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: descricaoController,
              decoration: InputDecoration(
                labelText: 'Descrição da tarefa',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
            const SizedBox(height: 18),
            DropdownButtonFormField<String>(
              value: responsavelSelecionado,
              items: widget.participantes.map((participante) {
                return DropdownMenuItem<String>(
                  value: participante,
                  child: Text(participante),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  responsavelSelecionado = value;
                });
              },
              decoration: InputDecoration(
                labelText: 'Responsável',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 52,
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('Cancelar'),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      onPressed: guardarTarefa,
                      child: const Text('Guardar'),
                    ),
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