import 'package:flutter/material.dart';
import '../models/activity.dart';
import '../models/trip.dart';
import 'create_activity_page.dart';

class TripItineraryPage extends StatefulWidget {
  final Trip trip;

  const TripItineraryPage({super.key, required this.trip});

  @override
  State<TripItineraryPage> createState() => _TripItineraryPageState();
}

class _TripItineraryPageState extends State<TripItineraryPage> {
  final List<Activity> atividades = [];

  Future<void> abrirCriarAtividade() async {
    final Activity? novaAtividade = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CreateActivityPage(),
      ),
    );

    if (novaAtividade != null) {
      setState(() {
        atividades.add(novaAtividade);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Itinerário - ${widget.trip.nome}'),
      ),
      body: atividades.isEmpty
          ? const Center(
              child: Text('Nenhuma atividade adicionada.'),
            )
          : ListView.builder(
              itemCount: atividades.length,
              itemBuilder: (context, index) {
                final atividade = atividades[index];

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: ListTile(
                    leading: const Icon(Icons.location_on),
                    title: Text(atividade.nome),
                    subtitle: Text(
                      '${atividade.data} às ${atividade.hora}\nLocal: ${atividade.local}',
                    ),
                    isThreeLine: true,
                  ),
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