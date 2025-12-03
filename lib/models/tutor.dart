import 'usuario.dart';
import 'area_conhecimento.dart';
import 'disponibilidade.dart';

class Tutor extends Usuario {
  final String curriculo;
  final int aprovado;
  final double mediaAvaliacoes;
  List<AreaConhecimento> areasConhecimento;
  List<Disponibilidade> disponibilidades;

  Tutor({
    required String id,
    required String nome,
    required String email,
    required String senha,
    required DateTime dataCadastro,
    String? fotoPerfilPath, // Novo
    required this.curriculo,
    this.aprovado = 0,
    this.mediaAvaliacoes = 0.0,
    List<AreaConhecimento>? areasConhecimento,
    List<Disponibilidade>? disponibilidades,
  }) : areasConhecimento = areasConhecimento ?? [],
       disponibilidades = disponibilidades ?? [],
       super(
          id: id,
          nome: nome,
          email: email,
          senha: senha,
          tipoUsuario: 'tutor',
          dataCadastro: dataCadastro,
          fotoPerfilPath: fotoPerfilPath, // Passado para o pai
        );

  factory Tutor.fromJson(Map<String, dynamic> json) {
    return Tutor(
      id: json['id']?.toString() ?? '',
      nome: json['nome'] ?? '',
      email: json['email'] ?? '',
      senha: json['senha'] ?? '',
      dataCadastro: json['dataCadastro'] != null
          ? DateTime.tryParse(json['dataCadastro']) ?? DateTime.now()
          : DateTime.now(),
      fotoPerfilPath: json['fotoPerfilPath']?.toString(), // Lendo do json
      curriculo: json['curriculo'] ?? '',
      aprovado: json['aprovado'] is int
          ? json['aprovado']
          : int.tryParse(json['aprovado'].toString()) ?? 0,
      mediaAvaliacoes: (json['mediaAvaliacoes'] as num?)?.toDouble() ?? 0.0,
      areasConhecimento: (json['areasConhecimento'] as List<dynamic>?)
          ?.map((a) => AreaConhecimento.fromJson(a as Map<String, dynamic>))
          .toList() ?? [],
      disponibilidades: (json['disponibilidades'] as List<dynamic>?)
          ?.map((d) => Disponibilidade.fromMap(d as Map<String, dynamic>))
          .toList() ?? [],
    );
  }

  @override
  Map<String, dynamic> toMap() {
    final map = super.toMap();
    map.addAll({
      'curriculo': curriculo,
      'aprovado': aprovado,
    });
    return map;
  }

  @override
  Map<String, dynamic> toJson() {
    final map = super.toJson();
    map.addAll({
      'curriculo': curriculo,
      'aprovado': aprovado,
      'mediaAvaliacoes': mediaAvaliacoes,
      'areasConhecimento': areasConhecimento.map((a) => a.toJson()).toList(),
      'disponibilidades': disponibilidades.map((d) => d.toMap()).toList(),
    });
    return map;
  }
}
