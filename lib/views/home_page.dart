import 'package:flutter/material.dart';
import 'create_trip_page.dart';
import '../models/trip.dart';
import '../data/database/database_provider.dart';
import 'trip_details_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    // Ensure demo user exists when app starts
    appDatabase.usersDao.ensureDemoUser();
  }

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
      body: FutureBuilder<dynamic>(
        future: appDatabase.usersDao.getUserByEmail('demo@unitrip.local'),
        builder: (context, userSnapshot) {
          if (userSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!userSnapshot.hasData || userSnapshot.data == null) {
            return const Center(child: Text('Erro ao carregar utilizador.'));
          }

          final userId = userSnapshot.data!.id;

          return StreamBuilder<List<dynamic>>(
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
                  final dbTrip = trips[index];

                  // Convert database Trip to app Trip model
                  final trip = Trip(
                    id: dbTrip.id,
                    nome: dbTrip.name,
                    inicio: dbTrip.startDate,
                    fim: dbTrip.endDate,
                    descricao: dbTrip.description ?? '',
                    participantes: [],
                  );

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
                      title: Text(trip.nome),
                      subtitle: Text(
                        '${trip.inicioFormatado} - ${trip.fimFormatado}\n${trip.descricao}',
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
