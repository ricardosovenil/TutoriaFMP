class Avaliacao {
  final String id;
  final String agendamentoId;
  final String tutorId;
  final String estudanteId;
  final double nota;
  final String comentario;
  final DateTime dataAvaliacao;

  // Campo adicional para relatórios
  final String? estudanteNome;

  Avaliacao({
    required this.id,
    required this.agendamentoId,
    required this.tutorId,
    required this.estudanteId,
    required this.nota,
    required this.comentario,
    required this.dataAvaliacao,
    this.estudanteNome, // Adicionado ao construtor
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'agendamentoId': agendamentoId,
      'tutorId': tutorId,
      'estudanteId': estudanteId,
      'nota': nota,
      'comentario': comentario,
      'dataAvaliacao': dataAvaliacao.toIso8601String(),
    };
  }

  factory Avaliacao.fromMap(Map<String, dynamic> map) {
    return Avaliacao(
      id: map['id'] as String,
      agendamentoId: map['agendamentoId'] as String,
      tutorId: map['tutorId'] as String,
      estudanteId: map['estudanteId'] as String,
      nota: (map['nota'] as num).toDouble(),
      comentario: map['comentario'] as String,
      dataAvaliacao: DateTime.parse(map['dataAvaliacao'] as String),
    );
  }

  // NOVO: Construtor para dados detalhados do relatório
  factory Avaliacao.fromDetailedMap(Map<String, dynamic> map) {
    return Avaliacao(
      id: map['id'] as String,
      agendamentoId: map['agendamentoId'] as String,
      tutorId: map['tutorId'] as String,
      estudanteId: map['estudanteId'] as String,
      nota: (map['nota'] as num).toDouble(),
      comentario: map['comentario'] as String,
      dataAvaliacao: DateTime.parse(map['dataAvaliacao'] as String),
      // Campo extra
      estudanteNome: map['estudanteNome'] as String?,
    );
  }
}
