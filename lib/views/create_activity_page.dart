import 'package:flutter/material.dart';
import '../models/activity.dart';

class CreateActivityPage extends StatefulWidget {
  const CreateActivityPage({super.key});

  @override
  State<CreateActivityPage> createState() => _CreateActivityPageState();
}

class _CreateActivityPageState extends State<CreateActivityPage> {
  final nomeController = TextEditingController();
  final dataController = TextEditingController();
  final horaController = TextEditingController();
  final localController = TextEditingController();

  DateTime? dataSelecionada;
  TimeOfDay? horaSelecionada;

  @override
  void dispose() {
    nomeController.dispose();
    dataController.dispose();
    horaController.dispose();
    localController.dispose();
    super.dispose();
  }

  String formatarData(DateTime data) {
    final dia = data.day.toString().padLeft(2, '0');
    final mes = data.month.toString().padLeft(2, '0');
    final ano = data.year.toString();
    return '$dia/$mes/$ano';
  }

  String formatarHora(TimeOfDay hora) {
    final h = hora.hour.toString().padLeft(2, '0');
    final m = hora.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  Future<void> selecionarData() async {
    final DateTime? dataEscolhida = await showDatePicker(
      context: context,
      initialDate: dataSelecionada ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (dataEscolhida != null) {
      setState(() {
        dataSelecionada = dataEscolhida;
        dataController.text = formatarData(dataEscolhida);
      });
    }
  }

  Future<void> selecionarHora() async {
    final TimeOfDay? horaEscolhida = await showTimePicker(
      context: context,
      initialTime: horaSelecionada ?? TimeOfDay.now(),
    );

    if (horaEscolhida != null) {
      setState(() {
        horaSelecionada = horaEscolhida;
        horaController.text = formatarHora(horaEscolhida);
      });
    }
  }

  void guardarAtividade() {
    final nome = nomeController.text.trim();
    final data = dataController.text.trim();
    final hora = horaController.text.trim();
    final local = localController.text.trim();

    if (nome.isEmpty || data.isEmpty || hora.isEmpty || local.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Preenche todos os campos.'),
        ),
      );
      return;
    }

    final atividade = Activity(
      nome: nome,
      data: data,
      hora: hora,
      local: local,
    );

    Navigator.pop(context, atividade);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Criar Atividade'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: nomeController,
              decoration: InputDecoration(
                labelText: 'Nome da atividade',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
            const SizedBox(height: 18),
            TextField(
              controller: dataController,
              readOnly: true,
              onTap: selecionarData,
              decoration: InputDecoration(
                labelText: 'Data',
                suffixIcon: const Icon(Icons.calendar_today),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
            const SizedBox(height: 18),
            TextField(
              controller: horaController,
              readOnly: true,
              onTap: selecionarHora,
              decoration: InputDecoration(
                labelText: 'Hora',
                suffixIcon: const Icon(Icons.access_time),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
            const SizedBox(height: 18),
            TextField(
              controller: localController,
              decoration: InputDecoration(
                labelText: 'Local',
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
                      onPressed: guardarAtividade,
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