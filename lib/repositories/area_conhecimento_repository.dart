import '../database/database_helper.dart';
import '../models/area_conhecimento.dart';

class AreaConhecimentoRepository {
  final dbHelper = DatabaseHelper.instance;

  // Adaptação do método do diagrama para o padrão Repository
  Future<void> cadastrarArea(String nome, String descricao) async {
    final db = await dbHelper.database;
    await db.insert(
      'areas_conhecimento',
      {'nome': nome, 'descricao': descricao},
    );
  }

  // Adaptação do método do diagrama para o padrão Repository
  Future<void> atualizarArea(String nome, String novaDescricao) async {
    final db = await dbHelper.database;
    await db.update(
      'areas_conhecimento',
      {'descricao': novaDescricao},
      where: 'nome = ?',
      whereArgs: [nome],
    );
  }

  // Adaptação do método do diagrama para o padrão Repository
  Future<void> excluirArea(String nome) async {
    final db = await dbHelper.database;
    await db.delete(
      'areas_conhecimento',
      where: 'nome = ?',
      whereArgs: [nome],
    );
  }

  // Adaptação do método do diagrama para o padrão Repository
  Future<List<AreaConhecimento>> listarTodasAreas() async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('areas_conhecimento');

    return List.generate(maps.length, (i) {
      return AreaConhecimento.fromJson(maps[i]);
    });
  }
}
