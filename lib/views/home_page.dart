import 'package:flutter/material.dart';
import 'create_trip_page.dart';
import '../models/trip.dart';
import 'trip_details_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Trip> viagens = [];

  Future<void> abrirCriarViagem() async {
    final Trip? novaViagem = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CreateTripPage(),
      ),
    );

    if (novaViagem != null) {
      setState(() {
        viagens.add(novaViagem);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: viagens.isEmpty
          ? const Center(
              child: Text('Bem-vinda à app de viagens!'),
            )
          : ListView.builder(
              itemCount: viagens.length,
              itemBuilder: (context, index) {
                final viagem = viagens[index];

                return Card(
                  margin: const EdgeInsets.all(12),
                  child: ListTile(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TripDetailsPage(trip: viagem),
                        ),
                      );
                    },
                    title: Text(viagem.nome),
                    subtitle: Text(
                      '${viagem.inicio} - ${viagem.fim}\n${viagem.descricao}',
                    ),
                    isThreeLine: true,
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: abrirCriarViagem,
        child: const Icon(Icons.add),
      ),
    );
  }
}