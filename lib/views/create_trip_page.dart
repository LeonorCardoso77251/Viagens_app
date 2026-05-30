import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

import '../data/database/app_database.dart';
import '../data/database/database_provider.dart';

import '../widgets/trips/trip_form_fields.dart';
import '../widgets/trips/participant_card.dart';
import '../widgets/trips/destination_option_field.dart';

class CreateTripPage extends StatefulWidget {
  const CreateTripPage({super.key});

  @override
  State<CreateTripPage> createState() => _CreateTripPageState();
}

class _CreateTripPageState extends State<CreateTripPage> {
  final _nomeController = TextEditingController();
  final _descricaoController = TextEditingController();
  final _destinoController = TextEditingController();
  final _destinoOpcaoController = TextEditingController();

  DateTime? _dataInicioSelecionada;
  DateTime? _dataFimSelecionada;

  // MODO: true = destino fixo, false = votação
  bool _modoDestinoFixo = true;

  final List<User> _participantes = [];
  List<User> _todosUsers = [];

  // OPÇÕES DE DESTINO (modo votação)
  final List<String> _opcoesDestino = [];

  @override
  void initState() {
    super.initState();
    _carregarUsers();
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _descricaoController.dispose();
    _destinoController.dispose();
    _destinoOpcaoController.dispose();
    super.dispose();
  }

  Future<void> _carregarUsers() async {
    final users = await appDatabase.usersDao.getAllUsers();
    setState(() => _todosUsers = users);
  }

  Future<void> _selecionarDataInicio() async {
    final data = await showDatePicker(
      context: context,
      initialDate: _dataInicioSelecionada ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (data != null) setState(() => _dataInicioSelecionada = data);
  }

  Future<void> _selecionarDataFim() async {
    final data = await showDatePicker(
      context: context,
      initialDate:
          _dataFimSelecionada ?? _dataInicioSelecionada ?? DateTime.now(),
      firstDate: _dataInicioSelecionada ?? DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (data != null) setState(() => _dataFimSelecionada = data);
  }

  void _adicionarOpcaoDestino() {
    final nome = _destinoOpcaoController.text.trim();

    if (nome.isEmpty) return;

    final jaExiste = _opcoesDestino.any(
      (o) => o.toLowerCase() == nome.toLowerCase(),
    );

    if (jaExiste) return;

    setState(() {
      _opcoesDestino.add(nome);
      _destinoOpcaoController.clear();
    });
  }

  void _removerOpcaoDestino(String nome) {
    setState(() => _opcoesDestino.remove(nome));
  }

  void _removerParticipante(User user) {
    setState(() => _participantes.remove(user));
  }

  Future<void> _guardarViagem() async {
    final nome = _nomeController.text.trim();
    final descricao = _descricaoController.text.trim();
    final destino = _destinoController.text.trim();

    // VALIDAÇÃO BASE
    if (nome.isEmpty ||
        _dataInicioSelecionada == null ||
        _dataFimSelecionada == null ||
        descricao.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preenche todos os campos.')),
      );
      return;
    }

    // VALIDAÇÃO MODO
    if (_modoDestinoFixo && destino.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Indica o destino da viagem.')),
      );
      return;
    }

    if (!_modoDestinoFixo && _opcoesDestino.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Adiciona pelo menos duas opções de destino.'),
        ),
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
      destination: _modoDestinoFixo ? destino : null,
      startDate: _dataInicioSelecionada!,
      endDate: _dataFimSelecionada!,
      createdByUserId: user.id,
    );

    // ADICIONAR PARTICIPANTES
    for (final participante in _participantes) {
      if (participante.id == user.id) continue;

      await appDatabase.tripsDao.addUserToTrip(
        tripId: trip.id,
        userId: participante.id,
      );
    }

    // ADICIONAR OPÇÕES DE DESTINO (modo votação)
    if (!_modoDestinoFixo) {
      for (final opcao in _opcoesDestino) {
        await appDatabase.destinationOptionsDao.addDestinationOption(
          tripId: trip.id,
          destinationName: opcao,
          createdByUserId: user.id,
        );
      }
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
              // CAMPOS BASE
              TripFormFields(
                nomeController: _nomeController,
                descricaoController: _descricaoController,
                dataInicioSelecionada: _dataInicioSelecionada,
                dataFimSelecionada: _dataFimSelecionada,
                onSelecionarDataInicio: _selecionarDataInicio,
                onSelecionarDataFim: _selecionarDataFim,
              ),

              const SizedBox(height: 24),

              // TOGGLE MODO DESTINO
              Row(
                children: [
                  const Expanded(child: Text('Modo de destino')),
                  SegmentedButton<bool>(
                    segments: const [
                      ButtonSegment(
                        value: true,
                        label: Text('Fixo'),
                        icon: Icon(Icons.place),
                      ),
                      ButtonSegment(
                        value: false,
                        label: Text('Votação'),
                        icon: Icon(Icons.how_to_vote_outlined),
                      ),
                    ],
                    selected: {_modoDestinoFixo},
                    onSelectionChanged: (value) {
                      setState(() => _modoDestinoFixo = value.first);
                    },
                  ),
                ],
              ),

              const SizedBox(height: 18),

              // DESTINO FIXO
              if (_modoDestinoFixo)
                TextField(
                  controller: _destinoController,
                  decoration: InputDecoration(
                    labelText: 'Destino',
                    prefixIcon: const Icon(Icons.place_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),

              // OPÇÕES DE DESTINO (modo votação)
              if (!_modoDestinoFixo) ...[
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _destinoOpcaoController,
                        decoration: InputDecoration(
                          labelText: 'Adicionar opção de destino',
                          prefixIcon: const Icon(Icons.place_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onSubmitted: (_) => _adicionarOpcaoDestino(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton.filled(
                      onPressed: _adicionarOpcaoDestino,
                      icon: const Icon(Icons.add),
                    ),
                  ],
                ),

                if (_opcoesDestino.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  ..._opcoesDestino.map(
                    (nome) => DestinationOptionField(
                      name: nome,
                      onRemover: () => _removerOpcaoDestino(nome),
                    ),
                  ),
                ],
              ],

              const SizedBox(height: 18),

              // AUTOCOMPLETE PARTICIPANTES
              Autocomplete<User>(
                displayStringForOption: (User user) => user.name,

                optionsBuilder: (textEditingValue) {
                  if (textEditingValue.text.isEmpty) {
                    return const Iterable<User>.empty();
                  }

                  return _todosUsers.where((user) {
                    final jaExiste = _participantes.any((p) => p.id == user.id);

                    return !jaExiste &&
                        user.name.toLowerCase().contains(
                          textEditingValue.text.toLowerCase(),
                        );
                  });
                },

                onSelected: (User user) {
                  setState(() => _participantes.add(user));
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

              if (_participantes.isNotEmpty) ...[
                const SizedBox(height: 8),
                ..._participantes.map(
                  (user) => ParticipantCard(
                    user: user,
                    onRemover: () => _removerParticipante(user),
                  ),
                ),
              ],

              const SizedBox(height: 28),

              // BOTÕES
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 52,
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancelar'),
                      ),
                    ),
                  ),

                  const SizedBox(width: 16),

                  Expanded(
                    child: SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _guardarViagem,
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
