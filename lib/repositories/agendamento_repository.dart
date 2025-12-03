import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';
import '../models/agendamento.dart';
import '../models/disponibilidade.dart';
import '../enums/status.dart';

class AgendamentoRepository {
  final dbHelper = DatabaseHelper.instance;

  Future<Disponibilidade?> getDisponibilidade(String id) async {
    final db = await dbHelper.database;
    final maps = await db.query('disponibilidades', where: 'id = ?', whereArgs: [id]);
    if (maps.isNotEmpty) {
      return Disponibilidade.fromMap(maps.first);
    }
    return null;
  }

  Future<void> criarAgendamento(Agendamento agendamento) async {
    final db = await dbHelper.database;
    await db.transaction((txn) async {
      await txn.insert('agendamentos', agendamento.toMap());
      await txn.update(
        'disponibilidades',
        {'agendado': 1},
        where: 'id = ?',
        whereArgs: [agendamento.disponibilidadeId],
      );
    });
  }

  Future<void> atualizarAgendamento(Agendamento agendamento, bool agendado) async {
    final db = await dbHelper.database;
    await db.transaction((txn) async {
      await txn.update(
        'agendamentos',
        agendamento.toMap(),
        where: 'id = ?',
        whereArgs: [agendamento.id],
      );
      if (!agendado) {
        await txn.update(
          'disponibilidades',
          {'agendado': 0},
          where: 'id = ?',
          whereArgs: [agendamento.disponibilidadeId],
        );
      }
    });
  }

  Future<Agendamento?> findAgendamentoPorId(String id) async {
    final db = await dbHelper.database;
    final maps = await db.query('agendamentos', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return Agendamento.fromMap(maps.first);
  }

  Future<List<Agendamento>> listarPorEstudante(String estudanteId) async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'agendamentos',
      where: 'estudanteId = ?',
      whereArgs: [estudanteId],
    );
    return maps.map((map) => Agendamento.fromMap(map)).toList();
  }

  Future<List<Agendamento>> listarPorTutor(String tutorId) async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT a.* FROM agendamentos a
      INNER JOIN disponibilidades d ON a.disponibilidadeId = d.id
      WHERE d.tutorId = ?
    ''', [tutorId]);
    
    return maps.map((map) => Agendamento.fromMap(map)).toList();
  }

  Future<List<Map<String, dynamic>>> getSolicitacoesPendentes(String tutorId) async {
    final db = await dbHelper.database;
    return await db.rawQuery('''
      SELECT 
        a.id, a.disponibilidadeId, a.estudanteId, a.motivoSolicitacao, a.status, a.concluido, a.descricaoDeConteudo, 
        u.nome as estudanteNome, 
        d.dataHora as dataHora
      FROM agendamentos a
      JOIN usuarios u ON a.estudanteId = u.id
      JOIN disponibilidades d ON a.disponibilidadeId = d.id
      WHERE d.tutorId = ? AND a.status = ?
      ORDER BY d.dataHora ASC
    ''', [tutorId, Status.aguardandoAp.value]);
  }

  // NOVO MÉTODO OTIMIZADO PARA AGENDAMENTOS APROVADOS
  Future<List<Map<String, dynamic>>> getAgendamentosAprovadosDetalhados(String tutorId) async {
    final db = await dbHelper.database;
    return await db.rawQuery('''
      SELECT 
        a.id, a.disponibilidadeId, a.estudanteId, a.motivoSolicitacao, a.status, a.concluido, a.descricaoDeConteudo, 
        u.nome as estudanteNome, 
        d.dataHora as dataHora
      FROM agendamentos a
      JOIN usuarios u ON a.estudanteId = u.id
      JOIN disponibilidades d ON a.disponibilidadeId = d.id
      WHERE d.tutorId = ? AND a.status = ?
      ORDER BY d.dataHora DESC
    ''', [tutorId, Status.aprovado.value]);
  }
}
