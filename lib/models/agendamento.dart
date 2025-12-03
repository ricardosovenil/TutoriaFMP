import '../enums/status.dart';
import 'tutor.dart';
import 'estudante.dart';
import 'disponibilidade.dart';

class Agendamento {
  final String id;
  final String disponibilidadeId; // Alterado para ID
  final String estudanteId; // Alterado para ID
  final String motivoSolicitacao;
  Status status;
  bool concluido;
  String? descricaoDeConteudo;

  // Campos adicionais para relatórios
  final DateTime? dataHora;
  final String? estudanteNome;

  Agendamento({
    required this.id,
    required this.disponibilidadeId,
    required this.estudanteId,
    required this.motivoSolicitacao,
    this.status = Status.aguardandoAp,
    this.concluido = false,
    this.descricaoDeConteudo,
    // Campos de relatório
    this.dataHora,
    this.estudanteNome,
  });


  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'disponibilidadeId': disponibilidadeId,
      'estudanteId': estudanteId,
      'motivoSolicitacao': motivoSolicitacao,
      'status': status.value,
      'concluido': concluido ? 1 : 0,
      'descricaoDeConteudo': descricaoDeConteudo,
    };
  }

  factory Agendamento.fromMap(Map<String, dynamic> map) {
    return Agendamento(
      id: map['id'] as String,
      disponibilidadeId: map['disponibilidadeId'] as String,
      estudanteId: map['estudanteId'] as String,
      motivoSolicitacao: map['motivoSolicitacao'] as String,
      status: Status.fromValue(map['status'] as int) ?? Status.aguardandoAp,
      concluido: (map['concluido'] as int) == 1,
      descricaoDeConteudo: map['descricaoDeConteudo'] as String?,
    );
  }

  // NOVO: Construtor para dados detalhados do relatório
  factory Agendamento.fromDetailedMap(Map<String, dynamic> map) {
    return Agendamento(
      id: map['id'] as String,
      disponibilidadeId: map['disponibilidadeId'] as String,
      estudanteId: map['estudanteId'] as String,
      motivoSolicitacao: map['motivoSolicitacao'] as String,
      status: Status.fromValue(map['status'] as int) ?? Status.aguardandoAp,
      concluido: (map['concluido'] as int) == 1,
      descricaoDeConteudo: map['descricaoDeConteudo'] as String?,
      // Campos extras
      dataHora: map['dataHora'] != null ? DateTime.parse(map['dataHora']) : null,
      estudanteNome: map['estudanteNome'] as String?,
    );
  }
}
