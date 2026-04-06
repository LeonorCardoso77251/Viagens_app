class Task {
  final String descricao;
  final String responsavel;
  bool concluida;

  Task({
    required this.descricao,
    required this.responsavel,
    this.concluida = false,
  });
}