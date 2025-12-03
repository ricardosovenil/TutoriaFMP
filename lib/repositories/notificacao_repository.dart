import '../database/database_helper.dart';
import '../models/notificacao.dart';
import '../models/usuario.dart';
import 'usuario_repository.dart';

class NotificacaoRepository {
  final dbHelper = DatabaseHelper.instance;
  final _userRepository = UsuarioRepository();

  // Cria uma nova notificação no banco de dados
  Future<void> criarNotificacao(Notificacao notificacao) async {
    final db = await dbHelper.database;
    await db.insert('notificacoes', notificacao.toMap());
  }

  // Atualiza uma notificação (ex: marcar como lida)
  Future<void> atualizarNotificacao(Notificacao notificacao) async {
    final db = await dbHelper.database;
    await db.update(
      'notificacoes',
      notificacao.toMap(),
      where: 'id = ?',
      whereArgs: [notificacao.id],
    );
  }

  // Busca uma única notificação pelo seu ID
  Future<Notificacao?> findNotificacaoPorId(String id) async {
    final db = await dbHelper.database;
    final maps = await db.query('notificacoes', where: 'id = ?', whereArgs: [id]);

    if (maps.isEmpty) return null;

    final notificacaoMap = maps.first;
    final destinatarioId = notificacaoMap['id_destinatario'] as String;

    // Busca o objeto Usuario completo
    final destinatario = await _userRepository.findEstudantePorId(destinatarioId); // Ou o método geral de busca de usuário

    return Notificacao.fromMap(notificacaoMap, destinatario);
  }

  // Lista todas as notificações para um usuário específico
  Future<List<Notificacao>> listarPorDestinatario(String destinatarioId) async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'notificacoes',
      where: 'id_destinatario = ?',
      whereArgs: [destinatarioId],
      orderBy: 'dataEnvio DESC', // Ordena das mais recentes para as mais antigas
    );

    final List<Notificacao> notificacoes = [];
    for (var map in maps) {
      try {
        final notificacao = await findNotificacaoPorId(map['id'] as String);
        if (notificacao != null) {
          notificacoes.add(notificacao);
        }
      } catch (e) {
        print("Erro ao construir notificação: $e");
      }
    }
    return notificacoes;
  }
}
