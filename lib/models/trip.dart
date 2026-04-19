class Trip {
  final int id;
  final String nome;
  final DateTime inicio;
  final DateTime fim;
  final String descricao;
  final List<String> participantes;

  Trip({
    required this.id,
    required this.nome,
    required this.inicio,
    required this.fim,
    required this.descricao,
    required this.participantes,
  });

  /// Format date to display format (dd/MM/yyyy)
  String get inicioFormatado {
    final dia = inicio.day.toString().padLeft(2, '0');
    final mes = inicio.month.toString().padLeft(2, '0');
    final ano = inicio.year.toString();
    return '$dia/$mes/$ano';
  }

  /// Format end date to display format (dd/MM/yyyy)
  String get fimFormatado {
    final dia = fim.day.toString().padLeft(2, '0');
    final mes = fim.month.toString().padLeft(2, '0');
    final ano = fim.year.toString();
    return '$dia/$mes/$ano';
  }
}
