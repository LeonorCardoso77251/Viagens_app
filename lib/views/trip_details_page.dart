import 'package:flutter/material.dart';
import '../models/trip.dart';
import 'trip_tasks_page.dart';
import 'trip_itinerary_page.dart';
import 'trip_expenses_page.dart';

class TripDetailsPage extends StatelessWidget {
  final Trip trip;

  const TripDetailsPage({super.key, required this.trip});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(trip.nome),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              trip.nome,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text('Datas: ${trip.inicio} - ${trip.fim}'),
            const SizedBox(height: 10),
            const Text(
              'Descrição:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            Text(trip.descricao),
            const SizedBox(height: 20),

            const Text(
              'Participantes:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),

            if (trip.participantes.isEmpty)
              const Text('Sem participantes adicionados.')
            else
              Column(
                children: trip.participantes.map((participante) {
                  return Card(
                    child: ListTile(
                      leading: const Icon(Icons.person),
                      title: Text(participante),
                    ),
                  );
                }).toList(),
              ),

            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 10),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TripTasksPage(trip: trip),
                    ),
                  );
                },
                child: const Text('Tarefas'),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TripItineraryPage(trip: trip),
                    ),
                  );
                },
                child: const Text('Itinerário'),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TripExpensesPage(trip: trip),
                    ),
                  );
                },
                child: const Text('Despesas'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}