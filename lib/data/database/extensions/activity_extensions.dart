import '../app_database.dart';

extension ActivityFormatting on Activity {
  String get dataFormatada {
    final d = dataHora.day.toString().padLeft(2, '0');
    final m = dataHora.month.toString().padLeft(2, '0');
    final y = dataHora.year.toString();

    return '$d/$m/$y';
  }

  String get horaFormatada {
    final h = dataHora.hour.toString().padLeft(2, '0');
    final min = dataHora.minute.toString().padLeft(2, '0');

    return '$h:$min';
  }
}