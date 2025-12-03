class AreaConhecimento {
  final String id;
  final String nome;
  final String descricao;

  AreaConhecimento({
    required this.id,
    required this.nome,
    required this.descricao,
  });

  // Fábrica para converter o JSON em Objeto Dart
  factory AreaConhecimento.fromJson(Map<String, dynamic> json) {
    return AreaConhecimento(
      // Garante que o ID seja lido corretamente como String
      id: json['id']?.toString() ?? '',
      nome: json['nome']?.toString() ?? '',
      descricao: json['descricao']?.toString() ?? '',
    );
  }

  // Para enviar de volta ao servidor (se precisar)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'descricao': descricao,
    };
  }

  // Opcional: Útil para DropdownMenu mostrar o nome em vez de "Instance of..."
  @override
  String toString() => nome;
}
