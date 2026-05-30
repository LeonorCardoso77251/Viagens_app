import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

import '../data/database/app_database.dart';
import '../data/database/database_provider.dart';
import '../data/database/dao/destination_options_dao.dart';

import 'trip_tasks_page.dart';
import 'trip_itinerary_page.dart';
import 'trip_expenses_page.dart';
import '../widgets/trips/trip_header.dart';
import '../widgets/trips/trip_participants_list.dart';
import '../widgets/trips/trip_section_button.dart';
import '../widgets/trips/trip_voting_panel.dart';

class TripDetailsPage extends StatefulWidget {
  final Trip trip;

  const TripDetailsPage({super.key, required this.trip});

  @override
  State<TripDetailsPage> createState() => _TripDetailsPageState();
}

class _TripDetailsPageState extends State<TripDetailsPage> {
  bool _editMode = false;

  // CONTROLLERS DE EDIÇÃO
  late final TextEditingController _nomeController;
  late final TextEditingController _descricaoController;
  DateTime? _dataInicioSelecionada;
  DateTime? _dataFimSelecionada;

  // PARTICIPANTES
  List<User> _participantes = [];
  List<User> _todosUsers = [];

  // UTILIZADOR ATUAL
  int? _currentUserId;

  @override
  void initState() {
    super.initState();

    _nomeController = TextEditingController(text: widget.trip.name);
    _descricaoController = TextEditingController(
      text: widget.trip.description ?? '',
    );

    _carregarDados();
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _descricaoController.dispose();
    super.dispose();
  }

  Future<void> _carregarDados() async {
    final firebaseUser = firebase_auth.FirebaseAuth.instance.currentUser;

    if (firebaseUser == null) return;

    final currentUser = await appDatabase.usersDao.getUserByFirebaseUid(
      firebaseUser.uid,
    );

    if (currentUser == null) return;

    final participantes = await appDatabase.tripsDao.getUsersForTrip(
      widget.trip.id,
    );

    final todosUsers = await appDatabase.usersDao.getAllUsers();

    setState(() {
      _currentUserId = currentUser.id;
      _participantes = participantes;
      _todosUsers = todosUsers;
    });
  }

  Future<void> _selecionarDataInicio() async {
    final data = await showDatePicker(
      context: context,
      initialDate: _dataInicioSelecionada ?? widget.trip.startDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (data != null) setState(() => _dataInicioSelecionada = data);
  }

  Future<void> _selecionarDataFim() async {
    final data = await showDatePicker(
      context: context,
      initialDate:
          _dataFimSelecionada ?? _dataInicioSelecionada ?? widget.trip.endDate,
      firstDate: _dataInicioSelecionada ?? widget.trip.startDate,
      lastDate: DateTime(2100),
    );

    if (data != null) setState(() => _dataFimSelecionada = data);
  }

  void _adicionarParticipante(User user) {
    setState(() => _participantes.add(user));
  }

  void _removerParticipante(User user) {
    setState(() => _participantes.remove(user));
  }

  void _entrarEmEdicao() {
    _nomeController.text = widget.trip.name;
    _descricaoController.text = widget.trip.description ?? '';
    _dataInicioSelecionada = null;
    _dataFimSelecionada = null;
    setState(() => _editMode = true);
  }

  void _cancelarEdicao() {
    _carregarDados();
    setState(() => _editMode = false);
  }

  Future<void> _guardarAlteracoes() async {
    final nome = _nomeController.text.trim();
    final descricao = _descricaoController.text.trim();

    if (nome.isEmpty || descricao.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preenche todos os campos.')),
      );
      return;
    }

    await appDatabase.tripsDao.updateTrip(
      tripId: widget.trip.id,
      name: nome,
      description: descricao,
      destination: widget.trip.destination,
      startDate: _dataInicioSelecionada ?? widget.trip.startDate,
      endDate: _dataFimSelecionada ?? widget.trip.endDate,
    );

    await appDatabase.tripsDao.updateTripParticipants(
      tripId: widget.trip.id,
      createdByUserId: widget.trip.createdBy,
      userIds: _participantes.map((u) => u.id).toList(),
    );

    if (!mounted) return;

    setState(() => _editMode = false);
  }

  Future<void> _votar(int destinationId) async {
    if (_currentUserId == null) return;

    await appDatabase.destinationOptionsDao.voteForDestination(
      tripId: widget.trip.id,
      destinationId: destinationId,
      userId: _currentUserId!,
    );
  }

  Future<void> _fecharVotacao() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Fechar votação'),
        content: const Text(
          'O destino com mais votos será escolhido. Esta ação não pode ser desfeita.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    await appDatabase.destinationOptionsDao.closeVoting(widget.trip.id);
  }

  bool get _isCreator => _currentUserId == widget.trip.createdBy;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.trip.name),

        actions: [
          if (!_editMode)
            IconButton(icon: const Icon(Icons.edit), onPressed: _entrarEmEdicao)
          else ...[
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: _cancelarEdicao,
            ),
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: _guardarAlteracoes,
            ),
          ],
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            // CABEÇALHO
            TripHeader(
              trip: widget.trip,
              editMode: _editMode,
              nomeController: _nomeController,
              descricaoController: _descricaoController,
              dataInicioSelecionada: _dataInicioSelecionada,
              dataFimSelecionada: _dataFimSelecionada,
              onSelecionarDataInicio: _selecionarDataInicio,
              onSelecionarDataFim: _selecionarDataFim,
            ),

            const SizedBox(height: 20),

            // PARTICIPANTES
            TripParticipantsList(
              participantes: _participantes,
              createdByUserId: widget.trip.createdBy,
              editMode: _editMode,
              todosUsers: _todosUsers,
              onAdicionar: _adicionarParticipante,
              onRemover: _removerParticipante,
            ),

            // SECÇÕES (apenas fora do modo de edição)
            if (!_editMode) ...[
              const SizedBox(height: 20),

              const Divider(),

              const SizedBox(height: 10),

              // VOTAÇÃO (apenas se não há destino definido)
              if (widget.trip.destination == null && _currentUserId != null)
                StreamBuilder<List<DestinationWithVotes>>(
                  stream: appDatabase.destinationOptionsDao
                      .watchDestinationsWithVotes(
                        tripId: widget.trip.id,
                        currentUserId: _currentUserId!,
                      ),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const SizedBox.shrink();

                    final destinations = snapshot.data!;

                    if (destinations.isEmpty) return const SizedBox.shrink();

                    return Column(
                      children: [
                        TripVotingPanel(
                          destinations: destinations,
                          isCreator: _isCreator,
                          onVotar: _votar,
                          onFecharVotacao: _fecharVotacao,
                        ),
                        const SizedBox(height: 20),
                        const Divider(),
                        const SizedBox(height: 10),
                      ],
                    );
                  },
                ),

              TripSectionButton(
                label: 'Tarefas',
                destination: TripTasksPage(trip: widget.trip),
              ),

              const SizedBox(height: 10),

              TripSectionButton(
                label: 'Itinerário',
                destination: TripItineraryPage(trip: widget.trip),
              ),

              const SizedBox(height: 10),

              TripSectionButton(
                label: 'Despesas',
                destination: TripExpensesPage(trip: widget.trip),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
