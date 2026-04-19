class Task {
  final int id;
  final int tripId;
  final int assignedToUserId;
  final String descricao;
  final String responsavel;
  bool concluida;
  final String status;

  Task({
    required this.id,
    required this.tripId,
    required this.assignedToUserId,
    required this.descricao,
    required this.responsavel,
    this.concluida = false,
    this.status = 'pending',
  });

  bool get isDone => status == 'done' || concluida;
}
