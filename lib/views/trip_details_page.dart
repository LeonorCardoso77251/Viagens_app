import 'package:flutter/material.dart';

import '../data/database/app_database.dart';
import '../data/database/database_provider.dart';

import 'trip_tasks_page.dart';
import 'trip_itinerary_page.dart';
import 'trip_expenses_page.dart';

class TripDetailsPage extends StatelessWidget {
  final Trip trip;

  const TripDetailsPage({
    super.key,
    required this.trip,
  });

  String formatarData(DateTime data) {
    final dia =
    data.day.toString().padLeft(2, '0');

    final mes =
    data.month.toString().padLeft(2, '0');

    final ano =
    data.year.toString();

    return '$dia/$mes/$ano';
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: Text(trip.name),
      ),

      body: FutureBuilder<List<User>>(

        future:
        appDatabase
            .tripsDao
            .getUsersForTrip(
          trip.id,
        ),

        builder: (
            context,
            snapshot,
            ) {

          if (snapshot.connectionState ==
              ConnectionState.waiting) {

            return const Center(
              child:
              CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {

            return Center(
              child: Text(
                'Erro: ${snapshot.error}',
              ),
            );
          }

          final participantes =
              snapshot.data ?? [];

          return SingleChildScrollView(

            padding:
            const EdgeInsets.all(16),

            child: Column(

              crossAxisAlignment:
              CrossAxisAlignment.start,

              children: [

                // NOME
                Text(
                  trip.name,

                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight:
                    FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                // DATAS
                Text(
                  'Datas: ${formatarData(trip.startDate)} - ${formatarData(trip.endDate)}',
                ),

                const SizedBox(height: 10),

                // DESCRIÇÃO
                const Text(
                  'Descrição:',

                  style: TextStyle(
                    fontWeight:
                    FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  trip.description ??
                      'Sem descrição.',
                ),

                const SizedBox(height: 20),

                // PARTICIPANTES
                const Text(
                  'Participantes:',

                  style: TextStyle(
                    fontSize: 18,
                    fontWeight:
                    FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                if (participantes.isEmpty)

                  const Text(
                    'Nenhum participante.',
                  )

                else

                  Column(

                    children:
                    participantes
                        .map<Widget>(

                          (user) {

                        return Card(

                          child: ListTile(

                            leading:
                            CircleAvatar(

                              child: Text(

                                user.name
                                    .substring(
                                  0,
                                  1,
                                )
                                    .toUpperCase(),
                              ),
                            ),

                            title:
                            Text(
                              user.name,
                            ),

                            subtitle:
                            Text(
                              user.email,
                            ),
                          ),
                        );
                      },
                    ).toList(),
                  ),

                const SizedBox(height: 20),

                const Divider(),

                const SizedBox(height: 10),

                // TAREFAS
                SizedBox(
                  width: double.infinity,

                  child: ElevatedButton(

                    onPressed: () {

                      Navigator.push(

                        context,

                        MaterialPageRoute(

                          builder:
                              (context) =>
                              TripTasksPage(
                                trip: trip,
                              ),
                        ),
                      );
                    },

                    child:
                    const Text(
                      'Tarefas',
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // ITINERÁRIO
                SizedBox(
                  width: double.infinity,

                  child: ElevatedButton(

                    onPressed: () {

                      Navigator.push(

                        context,

                        MaterialPageRoute(

                          builder:
                              (context) =>
                              TripItineraryPage(
                                trip: trip,
                              ),
                        ),
                      );
                    },

                    child:
                    const Text(
                      'Itinerário',
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // DESPESAS
                SizedBox(
                  width: double.infinity,

                  child: ElevatedButton(

                    onPressed: () {

                      Navigator.push(

                        context,

                        MaterialPageRoute(

                          builder:
                              (context) =>
                              TripExpensesPage(
                                trip: trip,
                              ),
                        ),
                      );
                    },

                    child:
                    const Text(
                      'Despesas',
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}