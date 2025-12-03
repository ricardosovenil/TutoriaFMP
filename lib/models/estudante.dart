import 'usuario.dart';
import 'tutor.dart';
import 'agendamento.dart';

class Estudante extends Usuario {
  final int matricula;
  final String curso;

  Estudante({
    // Dados do pai (Usuario)
    required String id,
    required String nome,
    required String email,
    required String senha,
    required DateTime dataCadastro,
    String? fotoPerfilPath, // Novo
    // Dados do filho
    required this.matricula,
    required this.curso,
  }) : super(
          id: id,
          nome: nome,
          email: email,
          senha: senha,
          tipoUsuario: 'estudante',
          dataCadastro: dataCadastro,
          fotoPerfilPath: fotoPerfilPath, // Passado para o pai
        );

  factory Estudante.fromMap(Map<String, dynamic> map) {
    return Estudante(
      id: map['id']?.toString() ?? '',
      nome: map['nome'] ?? '',
      email: map['email'] ?? '',
      senha: map['senha'] ?? '',
      dataCadastro: map['dataCadastro'] != null
          ? DateTime.tryParse(map['dataCadastro']) ?? DateTime.now()
          : DateTime.now(),
      fotoPerfilPath: map['fotoPerfilPath']?.toString(), // Lendo do map
      matricula: map['matricula'] is int
          ? map['matricula']
          : int.tryParse(map['matricula'].toString()) ?? 0,
      curso: map['curso'] ?? '',
    );
  }

  @override
  Map<String, dynamic> toMap() {
    final map = super.toMap(); // Pega o map do pai (já com fotoPerfilPath)
    map.addAll({
      'matricula': matricula,
      'curso': curso,
    });
    return map;
  }

  // Manter métodos de placeholder
  bool solicitarTutoria(Tutor tutor, String motivo) {
    return true;
  }

  List<Agendamento> visualizarAgendamentos() {
    return [];
  }

  bool avaliarTutor(Tutor tutor, double nota, String comentario) {
    return true;
  }

  Map<String, dynamic> toJson() => toMap();
  factory Estudante.fromJson(Map<String, dynamic> json) => Estudante.fromMap(json);
}
