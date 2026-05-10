import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

import '../data/database/app_database.dart';
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

  // PARTICIPANTES
  final List<User> participantes = [];

  // TODOS USERS
  List<User> todosUsers = [];

  DateTime? dataInicioSelecionada;
  DateTime? dataFimSelecionada;

  @override
  void initState() {
    super.initState();

    carregarUsers();
  }

  Future<void> carregarUsers() async {
    final users = await appDatabase.usersDao.getAllUsers();

    setState(() {
      todosUsers = users;
    });
  }

  @override
  void dispose() {
    nomeController.dispose();

    inicioController.dispose();

    fimController.dispose();

    descricaoController.dispose();

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

  void removerParticipante(User user) {
    setState(() {
      participantes.remove(user);
    });
  }

  Future<void> guardarViagem() async {
    final nome = nomeController.text.trim();

    final descricao = descricaoController.text.trim();

    // VALIDAÇÃO
    if (nome.isEmpty ||
        dataInicioSelecionada == null ||
        dataFimSelecionada == null ||
        descricao.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preenche todos os campos.')),
      );

      return;
    }

    // UTILIZADOR FIREBASE
    final firebaseUser = firebase_auth.FirebaseAuth.instance.currentUser;

    if (firebaseUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Utilizador não autenticado.')),
      );

      return;
    }

    // UTILIZADOR SQLITE
    final user = await appDatabase.usersDao.getUserByFirebaseUid(
      firebaseUser.uid,
    );

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao carregar utilizador.')),
      );

      return;
    }

    // CRIAR VIAGEM
    final trip = await appDatabase.tripsDao.createTrip(
      name: nome,

      description: descricao,

      startDate: dataInicioSelecionada!,

      endDate: dataFimSelecionada!,

      createdByUserId: user.id,
    );

    // ADICIONAR PARTICIPANTES
    for (final participante in participantes) {
      if (participante.id == user.id) {
        continue;
      }

      await appDatabase.tripsDao.addUserToTrip(
        tripId: trip.id,

        userId: participante.id,
      );
    }

    if (!mounted) return;

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
              // NOME
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

              // DATA INÍCIO
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

              // DATA FIM
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

              // DESCRIÇÃO
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

              // AUTOCOMPLETE
              Autocomplete<User>(
                displayStringForOption: (User user) => user.name,

                optionsBuilder: (textEditingValue) {
                  if (textEditingValue.text.isEmpty) {
                    return const Iterable<User>.empty();
                  }

                  return todosUsers.where((User user) {
                    return user.name.toLowerCase().contains(
                      textEditingValue.text.toLowerCase(),
                    );
                  });
                },

                onSelected: (User user) {
                  final jaExiste = participantes.any((p) => p.id == user.id);

                  if (jaExiste) {
                    return;
                  }

                  setState(() {
                    participantes.add(user);
                  });
                },

                fieldViewBuilder:
                    (context, controller, focusNode, onEditingComplete) {
                      return TextField(
                        controller: controller,

                        focusNode: focusNode,

                        decoration: InputDecoration(
                          labelText: 'Adicionar participante',

                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),

                          suffixIcon: const Icon(Icons.search),
                        ),
                      );
                    },
              ),

              const SizedBox(height: 12),

              // PARTICIPANTES
              if (participantes.isNotEmpty)
                Column(
                  children: participantes.map<Widget>((User user) {
                    return Card(
                      child: ListTile(
                        leading: const Icon(Icons.person),

                        title: Text(user.name),

                        subtitle: Text(user.email),

                        trailing: IconButton(
                          icon: const Icon(Icons.delete),

                          onPressed: () {
                            removerParticipante(user);
                          },
                        ),
                      ),
                    );
                  }).toList(),
                ),

              const SizedBox(height: 28),

              // BOTÕES
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
                        onPressed: guardarViagem,

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
