class Usuario {
  final String id;
  final String nome;
  final String email;
  final String senha;
  final String tipoUsuario;
  final DateTime dataCadastro;
  final String? fotoPerfilPath; // NOVO CAMPO

  Usuario({
    required this.id,
    required this.nome,
    required this.email,
    required this.senha,
    required this.tipoUsuario,
    required this.dataCadastro,
    this.fotoPerfilPath, // Adicionado ao construtor
  });

  // Converte do Banco SQLite (Map) para Objeto
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
      fotoPerfilPath: map['fotoPerfilPath']?.toString(), // Lendo o novo campo
    );
  }

  // Converte do Objeto para Banco SQLite (Map)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'email': email,
      'senha': senha,
      'tipoUsuario': tipoUsuario,
      'dataCadastro': dataCadastro.toIso8601String(),
      'fotoPerfilPath': fotoPerfilPath, // Escrevendo o novo campo
    };
  }

  // Mantendo a compatibilidade
  Map<String, dynamic> toJson() => toMap();
  factory Usuario.fromJson(Map<String, dynamic> json) => Usuario.fromMap(json);
}
