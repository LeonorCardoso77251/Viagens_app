import 'package:flutter/material.dart';

/// Campos de formulário partilhados entre CreateTripPage e TripHeader (modo edição).
/// Gere apenas a apresentação — os controllers e callbacks vêm de fora.
class TripFormFields extends StatelessWidget {
  final TextEditingController nomeController;
  final TextEditingController descricaoController;
  final DateTime? dataInicioSelecionada;
  final DateTime? dataFimSelecionada;
  final VoidCallback onSelecionarDataInicio;
  final VoidCallback onSelecionarDataFim;

  const TripFormFields({
    super.key,
    required this.nomeController,
    required this.descricaoController,
    required this.dataInicioSelecionada,
    required this.dataFimSelecionada,
    required this.onSelecionarDataInicio,
    required this.onSelecionarDataFim,
  });

  String _formatarData(DateTime data) {
    final dia = data.day.toString().padLeft(2, '0');
    final mes = data.month.toString().padLeft(2, '0');
    final ano = data.year.toString();
    return '$dia/$mes/$ano';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        // NOME
        TextField(
          controller: nomeController,
          decoration: InputDecoration(
            labelText: 'Nome da viagem',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),

        const SizedBox(height: 14),

        // DATA INÍCIO
        TextField(
          readOnly: true,
          onTap: onSelecionarDataInicio,
          decoration: InputDecoration(
            labelText: 'Data de início',
            hintText: dataInicioSelecionada != null
                ? _formatarData(dataInicioSelecionada!)
                : null,
            suffixIcon: const Icon(Icons.calendar_today),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),

        const SizedBox(height: 14),

        // DATA FIM
        TextField(
          readOnly: true,
          onTap: onSelecionarDataFim,
          decoration: InputDecoration(
            labelText: 'Data de fim',
            hintText: dataFimSelecionada != null
                ? _formatarData(dataFimSelecionada!)
                : null,
            suffixIcon: const Icon(Icons.calendar_today),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),

        const SizedBox(height: 14),

        // DESCRIÇÃO
        TextField(
          controller: descricaoController,
          maxLines: 3,
          decoration: InputDecoration(
            labelText: 'Descrição',
            alignLabelWithHint: true,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),
      ],
    );
  }
}
