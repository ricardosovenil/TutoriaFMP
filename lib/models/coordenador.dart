import 'usuario.dart';
import 'tutor.dart';
import 'agendamento.dart';
import 'estudante.dart';

class Coordenador extends Usuario {
  Coordenador({
    required String id,
    required String nome,
    required String email,
    required String senha,
    required DateTime dataCadastro,
    String? fotoPerfilPath, // Novo
  }) : super(
          id: id,
          nome: nome,
          email: email,
          senha: senha,
          tipoUsuario: 'coordenador',
          dataCadastro: dataCadastro,
          fotoPerfilPath: fotoPerfilPath, // Passado para o pai
        );

  // Manter métodos de placeholder
  bool aprovarTutor(Tutor tutor) {
    return true;
  }

  List<Tutor> gerarRelatorioDeTutores() {
    return [];
  }

  List<Agendamento> gerarRelatorioDeAgendamentos() {
    return [];
  }

  List<Estudante> gerarRelatorioDeEstudantes() {
    return [];
  }

  List<Estudante> gerarRelatorioDoEstudante() {
    return gerarRelatorioDeEstudantes();
  }

  @override
  Map<String, dynamic> toJson() {
    return super.toJson();
  }

  factory Coordenador.fromJson(Map<String, dynamic> json) {
    return Coordenador(
      id: json['id'] ?? '',
      nome: json['nome'] ?? '',
      email: json['email'] ?? '',
      senha: json['senha'] ?? '',
      dataCadastro: json['dataCadastro'] != null
          ? DateTime.tryParse(json['dataCadastro']) ?? DateTime.now()
          : DateTime.now(),
      fotoPerfilPath: json['fotoPerfilPath']?.toString(), // Lendo do json
    );
  }
}
