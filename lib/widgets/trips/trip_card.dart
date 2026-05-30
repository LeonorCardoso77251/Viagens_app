import 'package:flutter/material.dart';

import '../../data/database/app_database.dart';

import '../../views/trip_details_page.dart';

class TripCard extends StatelessWidget {
  final Trip trip;

  const TripCard({super.key, required this.trip});

  String _formatarData(DateTime data) {
    final dia = data.day.toString().padLeft(2, '0');
    final mes = data.month.toString().padLeft(2, '0');
    final ano = data.year.toString();
    return '$dia/$mes/$ano';
  }

  @override
  Widget build(BuildContext context) {
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
          '${_formatarData(trip.startDate)} - '
          '${_formatarData(trip.endDate)}\n'
          '${trip.description ?? ''}',
        ),

        isThreeLine: true,
      ),
    );
  }
}
