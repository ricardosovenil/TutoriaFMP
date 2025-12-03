import '../models/agendamento.dart';
import '../models/disponibilidade.dart';
import '../enums/status.dart';
import '../repositories/agendamento_repository.dart';

class AgendamentoService {
  static final AgendamentoService instance = AgendamentoService._init();
  final _agendamentoRepo = AgendamentoRepository();

  AgendamentoService._init();

  Future<void> criarAgendamento({
    required String disponibilidadeId,
    required String estudanteId,
    required String motivoSolicitacao,
  }) async {
    final disponibilidade = await _agendamentoRepo.getDisponibilidade(disponibilidadeId);

    if (disponibilidade == null) throw Exception('Slot de disponibilidade não encontrado.');
    if (disponibilidade.agendado) throw Exception('Este horário já foi agendado.');

    final agendamento = Agendamento(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      disponibilidadeId: disponibilidadeId,
      estudanteId: estudanteId,
      motivoSolicitacao: motivoSolicitacao,
      status: Status.aguardandoAp,
    );

    await _agendamentoRepo.criarAgendamento(agendamento);
  }

  Future<bool> atualizarStatus(String agendamentoId, Status novoStatus) async {
    final agendamento = await _agendamentoRepo.findAgendamentoPorId(agendamentoId);
    if (agendamento == null) return false;

    agendamento.status = novoStatus;
    final bool deveManterSlotOcupado = novoStatus == Status.aprovado;

    await _agendamentoRepo.atualizarAgendamento(agendamento, deveManterSlotOcupado);
    return true;
  }

  // --- MÉTODOS DE BUSCA ---

  Future<List<Agendamento>> listarPorTutor(String tutorId) {
    return _agendamentoRepo.listarPorTutor(tutorId);
  }

  Future<List<Agendamento>> listarPorEstudante(String estudanteId) {
    return _agendamentoRepo.listarPorEstudante(estudanteId);
  }

  Future<Agendamento?> getAgendamento(String id) {
    return _agendamentoRepo.findAgendamentoPorId(id);
  }

  Future<Disponibilidade?> getDisponibilidade(String id) {
    return _agendamentoRepo.getDisponibilidade(id);
  }

  Future<List<Agendamento>> getSolicitacoesPendentes(String tutorId) async {
    final maps = await _agendamentoRepo.getSolicitacoesPendentes(tutorId);
    // CORREÇÃO: Usando o construtor correto que lê os dados detalhados do JOIN.
    return maps.map((map) => Agendamento.fromDetailedMap(map)).toList();
  }
}
