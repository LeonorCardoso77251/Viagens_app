import 'package:flutter/material.dart';
import '../data/database/app_database.dart';
import '../data/database/database_provider.dart';
import 'create_activity_page.dart';

class TripItineraryPage extends StatefulWidget {
  final Trip trip;

  const TripItineraryPage({super.key, required this.trip});

  @override
  State<TripItineraryPage> createState() => _TripItineraryPageState();
}

class _TripItineraryPageState extends State<TripItineraryPage> {
  Future<void> abrirCriarAtividade() async {
    final novaAtividade = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (context) => const CreateActivityPage(),
      ),
    );

    if (novaAtividade == null) return;

    await appDatabase.activitiesDao.insertActivity(
      ActivitiesCompanion.insert(
        tripId: widget.trip.id,
        nome: novaAtividade['nome'] as String,
        dataHora: novaAtividade['dataHora'] as DateTime,
        local: novaAtividade['local'] as String,
      ),
    );
  }

  String formatarData(DateTime data) {
    final dia = data.day.toString().padLeft(2, '0');
    final mes = data.month.toString().padLeft(2, '0');
    final ano = data.year.toString();
    return '$dia/$mes/$ano';
  }

  String formatarHora(DateTime data) {
    final hora = data.hour.toString().padLeft(2, '0');
    final minuto = data.minute.toString().padLeft(2, '0');
    return '$hora:$minuto';
  }

  @override
  Widget build(BuildContext context) {
    final tripId = widget.trip.id;

    return Scaffold(
      appBar: AppBar(
        title: Text('Itinerário - ${widget.trip.name}'),
      ),
      body: StreamBuilder<List<Activity>>(
        stream: appDatabase.activitiesDao.watchActivitiesForTrip(tripId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final atividades = snapshot.data ?? [];

          if (atividades.isEmpty) {
            return const Center(
              child: Text('Nenhuma atividade adicionada.'),
            );
          }

          return ListView.builder(
            itemCount: atividades.length,
            itemBuilder: (context, index) {
              final atividade = atividades[index];

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: ListTile(
                  leading: const Icon(Icons.location_on),
                  title: Text(atividade.nome),
                  subtitle: Text(
                    '${formatarData(atividade.dataHora)} às ${formatarHora(atividade.dataHora)}\nLocal: ${atividade.local}',
                  ),
                  isThreeLine: true,
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: abrirCriarAtividade,
        child: const Icon(Icons.add),
      ),
    );
  }
}