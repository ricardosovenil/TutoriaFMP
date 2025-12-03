import '../models/area_conhecimento.dart';
import '../repositories/area_conhecimento_repository.dart';

// Serviço para orquestrar a lógica de negócio de Áreas de Conhecimento
class AreaConhecimentoService {
  static final AreaConhecimentoService instance = AreaConhecimentoService._init();
  final _repository = AreaConhecimentoRepository();

  AreaConhecimentoService._init();

  // Delega a busca de todas as áreas para o repositório
  Future<List<AreaConhecimento>> listarTodasAreas() async {
    return _repository.listarTodasAreas();
  }

  // Delega o cadastro de uma nova área para o repositório
  Future<void> cadastrarArea(String nome, String descricao) async {
    await _repository.cadastrarArea(nome, descricao);
  }

  // Adicione outros métodos de serviço conforme necessário (atualizar, excluir, etc.)
}
