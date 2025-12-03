import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';
import '../models/tutor.dart';
import '../models/area_conhecimento.dart';
import '../models/disponibilidade.dart';

// Repositório para gerenciar todas as interações de dados relacionadas a Tutores.
class TutorRepository {
  final dbHelper = DatabaseHelper.instance;

  Future<Map<String, dynamic>?> findTutorBase(String tutorId) async {
    final db = await dbHelper.database;
    final maps = await db.rawQuery('''
        SELECT u.*, t.* FROM usuarios u
        INNER JOIN tutores t ON u.id = t.id
        WHERE u.id = ?
    ''', [tutorId]);
    
    if (maps.isNotEmpty) return maps.first;
    return null;
  }

  Future<List<AreaConhecimento>> findAreasConhecimento(String tutorId) async {
    final db = await dbHelper.database;
    final maps = await db.rawQuery('''
      SELECT ac.* FROM areas_conhecimento ac
      INNER JOIN tutor_areas ta ON ac.id = ta.areaId
      WHERE ta.tutorId = ?
    ''', [tutorId]);
    
    return maps.map((map) => AreaConhecimento.fromJson(map)).toList();
  }

  Future<List<Disponibilidade>> findDisponibilidades(String tutorId, {bool? agendado}) async {
    final db = await dbHelper.database;
    String? where = 'tutorId = ?';
    List<dynamic> whereArgs = [tutorId];

    if (agendado != null) {
      where += ' AND agendado = ?';
      whereArgs.add(agendado ? 1 : 0);
    }

    final maps = await db.query('disponibilidades', where: where, whereArgs: whereArgs);
    return maps.map((map) => Disponibilidade.fromMap(map)).toList();
  }

  Future<List<String>> listarTutorIds({bool? aprovado}) async {
    final db = await dbHelper.database;
    String whereClause = 'tipoUsuario = ?';
    List<dynamic> whereArgs = ['tutor'];

    if (aprovado != null) {
      final tutorMaps = await db.query('tutores', where: 'aprovado = ?', whereArgs: [aprovado ? 1 : 0]);
      final tutorIds = tutorMaps.map((t) => t['id'] as String).toList();
      if (tutorIds.isEmpty) return [];
      final placeholders = '?,' * tutorIds.length;
      whereClause += ' AND id IN (${placeholders.substring(0, placeholders.length - 1)})';
      whereArgs.addAll(tutorIds);
    }

    final maps = await db.query('usuarios', columns: ['id'], where: whereClause, whereArgs: whereArgs);
    return maps.map((map) => map['id'] as String).toList();
  }

  Future<bool> aprovarTutor(String tutorId) async {
    final db = await dbHelper.database;
    final count = await db.update('tutores', {'aprovado': 1}, where: 'id = ?', whereArgs: [tutorId]);
    return count > 0;
  }

  Future<void> adicionarDisponibilidade(Disponibilidade disponibilidade) async {
    final db = await dbHelper.database;
    await db.insert('disponibilidades', disponibilidade.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }
  
  Future<void> removerDisponibilidade(String disponibilidadeId) async {
    final db = await dbHelper.database;
    await db.delete('disponibilidades', where: 'id = ?', whereArgs: [disponibilidadeId]);
  }

  Future<bool> adicionarAreaConhecimento(String tutorId, String areaId) async {
    final db = await dbHelper.database;
    try {
      await db.insert('tutor_areas', {'tutorId': tutorId, 'areaId': areaId}, conflictAlgorithm: ConflictAlgorithm.ignore);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> removerAreaConhecimento(String tutorId, String areaId) async {
    final db = await dbHelper.database;
    final count = await db.delete('tutor_areas', where: 'tutorId = ? AND areaId = ?', whereArgs: [tutorId, areaId]);
    return count > 0;
  }

  Future<double> getMediaAvaliacoes(String tutorId) async {
    final db = await dbHelper.database;
    final result = await db.rawQuery('SELECT AVG(nota) as media FROM avaliacoes WHERE tutorId = ?', [tutorId]);
    if (result.isNotEmpty && result.first['media'] != null) {
      return (result.first['media'] as num).toDouble();
    }
    return 0.0;
  }

  // --- NOVOS MÉTODOS PARA RELATÓRIOS ---

  // Busca todos os agendamentos de um tutor, com nome do estudante e data.
  Future<List<Map<String, dynamic>>> findAgendamentosPorTutor(String tutorId) async {
    final db = await dbHelper.database;
    return await db.rawQuery('''
      SELECT a.*, u.nome as estudanteNome, d.dataHora as dataHora
      FROM agendamentos a
      JOIN disponibilidades d ON a.disponibilidadeId = d.id
      JOIN usuarios u ON a.estudanteId = u.id
      WHERE d.tutorId = ?
      ORDER BY d.dataHora DESC
    ''', [tutorId]);
  }

  // Busca todas as avaliações de um tutor, com nome do estudante.
  Future<List<Map<String, dynamic>>> findAvaliacoesPorTutor(String tutorId) async {
    final db = await dbHelper.database;
    return await db.rawQuery('''
      SELECT av.*, u.nome as estudanteNome
      FROM avaliacoes av
      JOIN usuarios u ON av.estudanteId = u.id
      WHERE av.tutorId = ?
      ORDER BY av.dataAvaliacao DESC
    ''', [tutorId]);
  }
}
