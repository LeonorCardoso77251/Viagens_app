class Trip {
  final String nome;
  final String inicio;
  final String fim;
  final String descricao;
  final List<String> participantes;

  Trip({
    required this.nome,
    required this.inicio,
    required this.fim,
    required this.descricao,
    required this.participantes,
  });
}