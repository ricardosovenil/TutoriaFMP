import 'usuario.dart';

// Modelo "limpo" para a entidade Notificacao.
class Notificacao {
  String id;
  Usuario destinatario; // Objeto completo para uso na UI
  String titulo;
  String mensagem;
  DateTime dataEnvio;
  bool lida;

  Notificacao({
    required this.id,
    required this.destinatario,
    required this.titulo,
    required this.mensagem,
    required this.dataEnvio,
    this.lida = false,
  });

  // Método de negócio que opera na própria instância.
  void marcarComoLida() {
    lida = true;
  }

  // Converte o objeto para um Map, pronto para ser salvo no banco.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'id_destinatario': destinatario.id,
      'titulo': titulo,
      'mensagem': mensagem,
      'dataEnvio': dataEnvio.toIso8601String(),
      'lida': lida ? 1 : 0,
    };
  }

  // Fábrica para criar uma instância a partir de um Map do banco.
  // Requer que o objeto Usuario (destinatario) seja injetado.
  factory Notificacao.fromMap(Map<String, dynamic> map, Usuario destinatario) {
    return Notificacao(
      id: map['id'] ?? '',
      destinatario: destinatario,
      titulo: map['titulo'] ?? '',
      mensagem: map['mensagem'] ?? '',
      dataEnvio: DateTime.parse(map['dataEnvio']),
      lida: (map['lida'] ?? 0) == 1,
    );
  }
}
