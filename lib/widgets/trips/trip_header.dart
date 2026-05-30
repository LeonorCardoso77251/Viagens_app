import 'package:flutter/material.dart';

import '../../data/database/app_database.dart';
import 'trip_form_fields.dart';

class TripHeader extends StatelessWidget {
  final Trip trip;
  final bool editMode;

  // Apenas necessários em modo de edição
  final TextEditingController? nomeController;
  final TextEditingController? descricaoController;
  final DateTime? dataInicioSelecionada;
  final DateTime? dataFimSelecionada;
  final VoidCallback? onSelecionarDataInicio;
  final VoidCallback? onSelecionarDataFim;

  const TripHeader({
    super.key,
    required this.trip,
    this.editMode = false,
    this.nomeController,
    this.descricaoController,
    this.dataInicioSelecionada,
    this.dataFimSelecionada,
    this.onSelecionarDataInicio,
    this.onSelecionarDataFim,
  });

  String _formatarData(DateTime data) {
    final dia = data.day.toString().padLeft(2, '0');
    final mes = data.month.toString().padLeft(2, '0');
    final ano = data.year.toString();
    return '$dia/$mes/$ano';
  }

  @override
  Widget build(BuildContext context) {
    if (editMode) {
      return TripFormFields(
        nomeController: nomeController!,
        descricaoController: descricaoController!,
        dataInicioSelecionada: dataInicioSelecionada,
        dataFimSelecionada: dataFimSelecionada,
        onSelecionarDataInicio: onSelecionarDataInicio!,
        onSelecionarDataFim: onSelecionarDataFim!,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        // NOME
        Text(
          trip.name,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 10),

        // DESTINO (se definido)
        if (trip.destination != null) ...[
          Row(
            children: [
              const Icon(Icons.place, size: 16),
              const SizedBox(width: 4),
              Text(trip.destination!),
            ],
          ),
          const SizedBox(height: 6),
        ],

        // DATAS
        Row(
          children: [
            const Icon(Icons.calendar_today, size: 16),
            const SizedBox(width: 4),
            Text(
              '${_formatarData(trip.startDate)} - ${_formatarData(trip.endDate)}',
            ),
          ],
        ),

        const SizedBox(height: 10),

        // DESCRIÇÃO
        const Text('Descrição:', style: TextStyle(fontWeight: FontWeight.bold)),

        const SizedBox(height: 5),

        Text(trip.description ?? 'Sem descrição.'),
      ],
    );
  }
}
