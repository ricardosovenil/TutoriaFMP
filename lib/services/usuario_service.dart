import '../models/estudante.dart';
import '../repositories/usuario_repository.dart';

// Serviço para buscar dados de usuários.
class UsuarioService {
  static final UsuarioService instance = UsuarioService._init();
  final _usuarioRepository = UsuarioRepository();

  UsuarioService._init();

  // Busca um objeto Estudante completo pelo seu ID.
  Future<Estudante> getEstudante(String estudanteId) async {
    return await _usuarioRepository.findEstudantePorId(estudanteId);
  }
}
