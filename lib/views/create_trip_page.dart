import 'package:flutter/material.dart';
import '../models/trip.dart';
import '../data/database/database_provider.dart';

class CreateTripPage extends StatefulWidget {
  const CreateTripPage({super.key});

  @override
  State<CreateTripPage> createState() => _CreateTripPageState();
}

class _CreateTripPageState extends State<CreateTripPage> {
  final nomeController = TextEditingController();
  final inicioController = TextEditingController();
  final fimController = TextEditingController();
  final descricaoController = TextEditingController();
  final participanteController = TextEditingController();

  final List<String> participantes = [];

  DateTime? dataInicioSelecionada;
  DateTime? dataFimSelecionada;

  @override
  void dispose() {
    nomeController.dispose();
    inicioController.dispose();
    fimController.dispose();
    descricaoController.dispose();
    participanteController.dispose();
    super.dispose();
  }

  String formatarData(DateTime data) {
    final dia = data.day.toString().padLeft(2, '0');
    final mes = data.month.toString().padLeft(2, '0');
    final ano = data.year.toString();
    return '$dia/$mes/$ano';
  }

  Future<void> selecionarDataInicio() async {
    final DateTime? dataEscolhida = await showDatePicker(
      context: context,
      initialDate: dataInicioSelecionada ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (dataEscolhida != null) {
      setState(() {
        dataInicioSelecionada = dataEscolhida;
        inicioController.text = formatarData(dataEscolhida);
      });
    }
  }

  Future<void> selecionarDataFim() async {
    final DateTime? dataEscolhida = await showDatePicker(
      context: context,
      initialDate:
          dataFimSelecionada ?? dataInicioSelecionada ?? DateTime.now(),
      firstDate: dataInicioSelecionada ?? DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (dataEscolhida != null) {
      setState(() {
        dataFimSelecionada = dataEscolhida;
        fimController.text = formatarData(dataEscolhida);
      });
    }
  }

  void adicionarParticipante() {
    final nome = participanteController.text.trim();

    if (nome.isEmpty) {
      return;
    }

    setState(() {
      participantes.add(nome);
      participanteController.clear();
    });
  }

  void removerParticipante(String participante) {
    setState(() {
      participantes.remove(participante);
    });
  }

  Future<void> guardarViagem() async {
    final nome = nomeController.text.trim();
    final descricao = descricaoController.text.trim();

    if (nome.isEmpty ||
        dataInicioSelecionada == null ||
        dataFimSelecionada == null ||
        descricao.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preenche todos os campos.')),
      );
      return;
    }

    final user = await appDatabase.usersDao.getUserByEmail(
      'demo@unitrip.local',
    );

    await appDatabase.tripsDao.createTrip(
      name: nome,
      description: descricao,
      startDate: dataInicioSelecionada!,
      endDate: dataFimSelecionada!,
      createdByUserId: user!.id,
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Criar Viagem'), centerTitle: false),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: nomeController,
                decoration: InputDecoration(
                  labelText: 'Nome da viagem',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              TextField(
                controller: inicioController,
                readOnly: true,
                onTap: selecionarDataInicio,
                decoration: InputDecoration(
                  labelText: 'Data de início',
                  suffixIcon: const Icon(Icons.calendar_today),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              TextField(
                controller: fimController,
                readOnly: true,
                onTap: selecionarDataFim,
                decoration: InputDecoration(
                  labelText: 'Data de fim',
                  suffixIcon: const Icon(Icons.calendar_today),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              TextField(
                controller: descricaoController,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: 'Descrição',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              TextField(
                controller: participanteController,
                decoration: InputDecoration(
                  labelText: 'Adicionar participante',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: adicionarParticipante,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              if (participantes.isNotEmpty)
                Column(
                  children: participantes.map((participante) {
                    return Card(
                      child: ListTile(
                        leading: const Icon(Icons.person),
                        title: Text(participante),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            removerParticipante(participante);
                          },
                        ),
                      ),
                    );
                  }).toList(),
                ),
              const SizedBox(height: 28),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 52,
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text('Cancelar'),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        onPressed: guardarViagem,
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text('Guardar'),
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
  }
}
