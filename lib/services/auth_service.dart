import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import '../models/usuario.dart';
import '../models/estudante.dart';
import '../models/tutor.dart';
import '../models/coordenador.dart';
import '../repositories/usuario_repository.dart';

class AuthService {
  static final AuthService instance = AuthService._init();
  final UsuarioRepository _repository = UsuarioRepository();

  AuthService._init();

  Future<Usuario?> login(String email, String senha) async {
    final usuarioData = await _repository.findUsuarioPorCredenciais(email, senha);
    if (usuarioData == null) return null;
    final tipoUsuario = usuarioData['tipoUsuario'] as String;
    final id = usuarioData['id'] as String;

    switch (tipoUsuario) {
      case 'estudante': return await _repository.findEstudantePorId(id);
      case 'tutor': return await _repository.findTutorPorId(id);
      case 'coordenador': return await _repository.findCoordenadorPorId(id);
      default: throw Exception('Tipo de usuário desconhecido: $tipoUsuario');
    }
  }

  Future<bool> emailJaExiste(String email) async {
    return await _repository.emailJaExiste(email);
  }

  Future<Estudante> cadastrarEstudante({required String nome, required String email, required String senha, required int matricula, required String curso, File? fotoPerfil}) async {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    String? fotoPath = fotoPerfil != null ? await _salvarFotoPerfil(id, fotoPerfil) : null;
    await _repository.criarEstudante(id: id, nome: nome, email: email, senha: senha, matricula: matricula, curso: curso, fotoPerfilPath: fotoPath);
    return await _repository.findEstudantePorId(id);
  }

  Future<Tutor> cadastrarTutor({required String nome, required String email, required String senha, required File curriculoFile, File? fotoPerfil}) async {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    String? fotoPath = fotoPerfil != null ? await _salvarFotoPerfil(id, fotoPerfil) : null;
    final String curriculoPath = await _salvarCurriculo(id, curriculoFile);
    await _repository.criarTutor(id: id, nome: nome, email: email, senha: senha, curriculo: curriculoPath, fotoPerfilPath: fotoPath);
    return await _repository.findTutorPorId(id);
  }
  
  Future<Coordenador> cadastrarCoordenador({required String nome, required String email, required String senha, File? fotoPerfil}) async {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    String? fotoPath = fotoPerfil != null ? await _salvarFotoPerfil(id, fotoPerfil) : null;
    await _repository.criarCoordenador(id: id, nome: nome, email: email, senha: senha, fotoPerfilPath: fotoPath);
    return await _repository.findCoordenadorPorId(id);
  }

  Future<String> _salvarArquivo(String userId, File arquivo, String diretorio, String prefixo) async {
    final appDir = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(appDir.path, diretorio));

    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }

    final extensao = p.extension(arquivo.path);
    final nomeArquivo = '$prefixo${userId}$extensao';
    final caminhoSalvo = p.join(dir.path, nomeArquivo);
    
    await arquivo.copy(caminhoSalvo);
    return caminhoSalvo;
  }

  Future<String> _salvarCurriculo(String tutorId, File arquivo) async {
    return _salvarArquivo(tutorId, arquivo, 'curriculos', 'curriculo_');
  }

  Future<String> _salvarFotoPerfil(String userId, File arquivo) async {
    return _salvarArquivo(userId, arquivo, 'fotos_perfil', 'perfil_');
  }
}
