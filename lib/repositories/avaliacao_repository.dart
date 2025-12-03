import '../database/database_helper.dart';
import '../models/avaliacao.dart';

class AvaliacaoRepository {
  final dbHelper = DatabaseHelper.instance;

  Future<void> criarAvaliacao(Avaliacao avaliacao) async {
    final db = await dbHelper.database;
    await db.insert('avaliacoes', avaliacao.toMap());
  }

  Future<Avaliacao?> findAvaliacaoPorId(String id) async {
    final db = await dbHelper.database;
    final maps = await db.query('avaliacoes', where: 'id = ?', whereArgs: [id]);

    if (maps.isEmpty) return null;

    return Avaliacao.fromMap(maps.first);
  }

  Future<List<Avaliacao>> listarPorTutor(String tutorId) async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'avaliacoes',
      where: 'tutorId = ?',
      whereArgs: [tutorId],
    );
    return maps.map((map) => Avaliacao.fromMap(map)).toList();
  }
  
  Future<List<Avaliacao>> listarPorEstudante(String estudanteId) async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'avaliacoes',
      where: 'estudanteId = ?',
      whereArgs: [estudanteId],
    );
    return maps.map((map) => Avaliacao.fromMap(map)).toList();
  }
}
