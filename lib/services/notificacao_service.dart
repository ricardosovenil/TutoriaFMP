import '../database/database_helper.dart';
import '../models/notificacao.dart';
import '../models/usuario.dart';
import 'package:sqflite/sqflite.dart';
import 'auth_service.dart';

class NotificacaoService {
  static final NotificacaoService instance = NotificacaoService._init();
  NotificacaoService._init();

  Future<bool> enviarNotificacao({
    required String destinatarioId,
    required String titulo,
    required String mensagem,
  }) async {
    final db = await DatabaseHelper.instance.database;
    final id = DateTime.now().millisecondsSinceEpoch.toString();

    try {
      await db.insert('notificacoes', {
        'id': id,
        'destinatarioId': destinatarioId,
        'titulo': titulo,
        'mensagem': mensagem,
        'dataEnvio': DateTime.now().toIso8601String(),
        'lida': 0,
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<List<Notificacao>> listarPorUsuario(String usuarioId) async {
    final db = await DatabaseHelper.instance.database;
    final maps = await db.query(
      'notificacoes',
      where: 'destinatarioId = ?',
      whereArgs: [usuarioId],
      orderBy: 'dataEnvio DESC',
    );

    final notificacoes = <Notificacao>[];
    
    for (var map in maps) {
      // Buscar usuário destinatário
      final usuarioMap = await db.query('usuarios', where: 'id = ?', whereArgs: [usuarioId]);
      if (usuarioMap.isNotEmpty) {
        final usuario = Usuario.fromJson(usuarioMap.first);
        
        notificacoes.add(Notificacao(
          id: map['id'] as String,
          destinatario: usuario,
          titulo: map['titulo'] as String,
          mensagem: map['mensagem'] as String,
          dataEnvio: DateTime.parse(map['dataEnvio'] as String),
          lida: (map['lida'] as int) == 1,
        ));
      }
    }

    return notificacoes;
  }

  Future<bool> marcarComoLida(String notificacaoId) async {
    final db = await DatabaseHelper.instance.database;
    final result = await db.update(
      'notificacoes',
      {'lida': 1},
      where: 'id = ?',
      whereArgs: [notificacaoId],
    );
    return result > 0;
  }

  Future<int> contarNaoLidas(String usuarioId) async {
    final db = await DatabaseHelper.instance.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM notificacoes WHERE destinatarioId = ? AND lida = 0',
      [usuarioId],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }
}


