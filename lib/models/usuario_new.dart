// Cleaned Usuario model with proper JSON and Map serialization
class Usuario {
  final String id;
  final String nome;
  final String email;
  final String senha;
  final String tipoUsuario;
  final DateTime dataCadastro;

  Usuario({
    required this.id,
    required this.nome,
    required this.email,
    required this.senha,
    required this.tipoUsuario,
    required this.dataCadastro,
  });

  factory Usuario.fromMap(Map<String, dynamic> map) {
    return Usuario(
      id: map['id']?.toString() ?? '',
      nome: map['nome']?.toString() ?? '',
      email: map['email']?.toString() ?? '',
      senha: map['senha']?.toString() ?? '',
      tipoUsuario: map['tipoUsuario']?.toString() ?? '',
      dataCadastro: map['dataCadastro'] != null
          ? DateTime.parse(map['dataCadastro'].toString())
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'email': email,
      'senha': senha,
      'tipoUsuario': tipoUsuario,
      'dataCadastro': dataCadastro.toIso8601String(),
    };
  }

  factory Usuario.fromJson(Map<String, dynamic> json) => Usuario.fromMap(json);

  Map<String, dynamic> toJson() => toMap();
}
