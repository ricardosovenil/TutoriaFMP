import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';
import '../models/usuario.dart';
import '../models/estudante.dart';
import '../models/tutor.dart';
import '../models/coordenador.dart';

class UsuarioRepository {
  final dbHelper = DatabaseHelper.instance;

  Future<Map<String, dynamic>?> findUsuarioPorCredenciais(String email, String senha) async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('usuarios', where: 'email = ? AND senha = ?', whereArgs: [email, senha]);
    if (maps.isNotEmpty) return maps.first;
    return null;
  }

  Future<bool> emailJaExiste(String email) async {
    final db = await dbHelper.database;
    final result = await db.query('usuarios', where: 'email = ?', whereArgs: [email]);
    return result.isNotEmpty;
  }

  Future<Estudante> findEstudantePorId(String id) async {
    final db = await dbHelper.database;
    final usuarioMap = await db.query('usuarios', where: 'id = ?', whereArgs: [id]);
    final estudanteMap = await db.query('estudantes', where: 'id = ?', whereArgs: [id]);
    if (usuarioMap.isEmpty || estudanteMap.isEmpty) throw Exception('Estudante não encontrado');
    final data = {...usuarioMap.first, ...estudanteMap.first};
    return Estudante.fromJson(data);
  }

  Future<Tutor> findTutorPorId(String id) async {
    final db = await dbHelper.database;
    final usuarioMap = await db.query('usuarios', where: 'id = ?', whereArgs: [id]);
    final tutorMap = await db.query('tutores', where: 'id = ?', whereArgs: [id]);
    if (usuarioMap.isEmpty || tutorMap.isEmpty) throw Exception('Tutor não encontrado');
    final data = {...usuarioMap.first, ...tutorMap.first};
    return Tutor.fromJson(data);
  }

  Future<Coordenador> findCoordenadorPorId(String id) async {
    final db = await dbHelper.database;
    final usuarioMap = await db.query('usuarios', where: 'id = ?', whereArgs: [id]);
    if (usuarioMap.isEmpty) throw Exception('Coordenador não encontrado');
    return Coordenador.fromJson(usuarioMap.first);
  }

  Future<void> criarEstudante({required String id, required String nome, required String email, required String senha, required int matricula, required String curso, String? fotoPerfilPath}) async {
    final db = await dbHelper.database;
    await db.transaction((txn) async {
      await txn.insert('usuarios', {
        'id': id, 'nome': nome, 'email': email, 'senha': senha,
        'dataCadastro': DateTime.now().toIso8601String(), 'tipoUsuario': 'estudante',
        'fotoPerfilPath': fotoPerfilPath,
      });
      await txn.insert('estudantes', {'id': id, 'matricula': matricula, 'curso': curso});
    });
  }

  Future<void> criarTutor({required String id, required String nome, required String email, required String senha, required String curriculo, String? fotoPerfilPath}) async {
    final db = await dbHelper.database;
    await db.transaction((txn) async {
      await txn.insert('usuarios', {
        'id': id, 'nome': nome, 'email': email, 'senha': senha,
        'dataCadastro': DateTime.now().toIso8601String(), 'tipoUsuario': 'tutor',
        'fotoPerfilPath': fotoPerfilPath,
      });
      await txn.insert('tutores', {'id': id, 'curriculo': curriculo, 'aprovado': 0});
    });
  }

  Future<void> criarCoordenador({required String id, required String nome, required String email, required String senha, String? fotoPerfilPath}) async {
    final db = await dbHelper.database;
    await db.transaction((txn) async {
      await txn.insert('usuarios', {
        'id': id, 'nome': nome, 'email': email, 'senha': senha,
        'dataCadastro': DateTime.now().toIso8601String(), 'tipoUsuario': 'coordenador',
        'fotoPerfilPath': fotoPerfilPath,
      });
      await txn.insert('coordenadores', {'id': id});
    });
  }

  Future<void> excluirUsuario(String usuarioId) async {
    final db = await dbHelper.database;
    await db.delete('usuarios', where: 'id = ?', whereArgs: [usuarioId]);
  }

  // NOVO: Conta quantos estudantes únicos agendaram tutorias
  Future<int> countEstudantesComAgendamentos() async {
    final db = await dbHelper.database;
    final result = await db.rawQuery('SELECT COUNT(DISTINCT estudanteId) as total FROM agendamentos');
    if (result.isNotEmpty && result.first['total'] != null) {
      return result.first['total'] as int;
    }
    return 0;
  }
}
