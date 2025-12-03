import '../models/tutor.dart';
import '../models/agendamento.dart';
import '../models/avaliacao.dart';
import '../repositories/tutor_repository.dart';
import '../repositories/usuario_repository.dart';

class RelatorioService {
  static final RelatorioService instance = RelatorioService._init();
  final _tutorRepository = TutorRepository();
  final _usuarioRepository = UsuarioRepository();

  RelatorioService._init();

  // Busca os dados completos para o relatório de um único tutor.
  Future<Map<String, dynamic>> getRelatorioCompletoTutor(String tutorId) async {
    final agendamentosMap = await _tutorRepository.findAgendamentosPorTutor(tutorId);
    final avaliacoesMap = await _tutorRepository.findAvaliacoesPorTutor(tutorId);

    // Converte os mapas brutos do SQL em listas de objetos do nosso modelo.
    final agendamentos = agendamentosMap.map((map) => Agendamento.fromDetailedMap(map)).toList();
    final avaliacoes = avaliacoesMap.map((map) => Avaliacao.fromDetailedMap(map)).toList();

    return {
      'agendamentos': agendamentos,
      'avaliacoes': avaliacoes,
    };
  }

  // Busca o número total de estudantes que já fizeram pelo menos um agendamento.
  Future<int> getTotalEstudantesComAgendamento() {
    return _usuarioRepository.countEstudantesComAgendamentos();
  }
}
