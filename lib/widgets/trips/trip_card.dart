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

  // ESTADO DA VIAGEM baseado nas datas
  ({IconData icon, String label, Color color}) get _estadoViagem {
    final hoje = DateTime.now();

    if (hoje.isBefore(trip.startDate)) {
      return (icon: Icons.schedule, label: 'Próxima', color: Colors.blue);
    } else if (hoje.isAfter(trip.endDate)) {
      return (
        icon: Icons.check_circle_outline,
        label: 'Concluída',
        color: Colors.grey,
      );
    } else {
      return (
        icon: Icons.flight_takeoff,
        label: 'Em curso',
        color: Colors.green,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final estado = _estadoViagem;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),

      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TripDetailsPage(trip: trip),
            ),
          );
        },

        child: Padding(
          padding: const EdgeInsets.all(16),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              // LINHA SUPERIOR: nome + chip de estado
              Row(
                children: [
                  Expanded(
                    child: Text(
                      trip.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  Chip(
                    avatar: Icon(estado.icon, size: 14, color: estado.color),
                    label: Text(
                      estado.label,
                      style: TextStyle(fontSize: 12, color: estado.color),
                    ),
                    padding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                    side: BorderSide(color: estado.color.withOpacity(0.4)),
                    backgroundColor: estado.color.withOpacity(0.08),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // DESTINO
              Row(
                children: [
                  const Icon(
                    Icons.place_outlined,
                    size: 15,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    trip.destination ?? 'A votar...',
                    style: TextStyle(
                      color: trip.destination != null ? null : Colors.grey,
                      fontStyle: trip.destination != null
                          ? FontStyle.normal
                          : FontStyle.italic,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 4),

              // DATAS
              Row(
                children: [
                  const Icon(
                    Icons.calendar_today_outlined,
                    size: 15,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${_formatarData(trip.startDate)} — ${_formatarData(trip.endDate)}',
                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                ],
              ),

              // DESCRIÇÃO
              if (trip.description != null && trip.description!.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  trip.description!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
