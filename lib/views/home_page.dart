import 'package:flutter/material.dart';
import 'create_trip_page.dart';
import '../data/database/database_provider.dart';
import 'trip_details_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String formatarData(DateTime data) {
    final dia = data.day.toString().padLeft(2, '0');
    final mes = data.month.toString().padLeft(2, '0');
    final ano = data.year.toString();
    return '$dia/$mes/$ano';
  }

  Future<void> _abrirCriarViagem() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreateTripPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: appDatabase.usersDao.getUserByEmail('demo@unitrip.local'),
        builder: (context, userSnapshot) {
          if (userSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!userSnapshot.hasData || userSnapshot.data == null) {
            return const Center(child: Text('Erro ao carregar utilizador.'));
          }

          final userId = userSnapshot.data!.id;

          return StreamBuilder(
            stream: appDatabase.tripsDao.watchTripsForUser(userId),
            builder: (context, tripsSnapshot) {
              if (tripsSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (tripsSnapshot.hasError) {
                return Center(child: Text('Erro: ${tripsSnapshot.error}'));
              }

              final trips = tripsSnapshot.data ?? [];

              if (trips.isEmpty) {
                return const Center(child: Text('Bem-vinda à app de viagens!'));
              }

              return ListView.builder(
                itemCount: trips.length,
                itemBuilder: (context, index) {
                  final trip = trips[index];

                  return Card(
                    margin: const EdgeInsets.all(12),
                    child: ListTile(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TripDetailsPage(trip: trip),
                          ),
                        );
                      },
                      title: Text(trip.name),
                      subtitle: Text(
                        '${formatarData(trip.startDate)} - ${formatarData(trip.endDate)}\n${trip.description ?? ''}',
                      ),
                      isThreeLine: true,
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _abrirCriarViagem,
        child: const Icon(Icons.add),
      ),
    );
  }
}