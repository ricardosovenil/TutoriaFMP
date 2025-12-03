import '../models/avaliacao.dart';
import '../repositories/avaliacao_repository.dart';

class AvaliacaoService {
  static final AvaliacaoService instance = AvaliacaoService._init();
  final _avaliacaoRepository = AvaliacaoRepository();

  AvaliacaoService._init();

  Future<void> registrarAvaliacao({
    required String agendamentoId,
    required String tutorId,
    required String estudanteId,
    required double nota,
    required String comentario,
  }) async {
    final novaAvaliacao = Avaliacao(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      agendamentoId: agendamentoId,
      tutorId: tutorId,
      estudanteId: estudanteId,
      nota: nota,
      comentario: comentario,
      dataAvaliacao: DateTime.now(),
    );

    await _avaliacaoRepository.criarAvaliacao(novaAvaliacao);
  }

  Future<List<Avaliacao>> listarPorTutor(String tutorId) {
    return _avaliacaoRepository.listarPorTutor(tutorId);
  }

  Future<List<Avaliacao>> listarPorEstudante(String estudanteId) {
    return _avaliacaoRepository.listarPorEstudante(estudanteId);
  }
}
