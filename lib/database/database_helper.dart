import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('fmp_tutoria.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 2, // VERSÃO INCREMENTADA
      onCreate: _createDB,
      onUpgrade: _upgradeDB, // NOVA LÓGICA DE UPGRADE
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await _createTables(db);
    await _insertDefaultData(db);
  }

  // NOVO: Método para lidar com upgrades do schema
  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Adiciona a coluna de foto de perfil se o usuário veio da versão 1
      await db.execute('ALTER TABLE usuarios ADD COLUMN fotoPerfilPath TEXT');
    }
  }
  
  Future<void> _createTables(Database db) async {
     // Tabela de Usuários ATUALIZADA
    await db.execute('''
      CREATE TABLE usuarios (
        id TEXT PRIMARY KEY,
        nome TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        senha TEXT NOT NULL,
        dataCadastro TEXT NOT NULL,
        tipoUsuario TEXT NOT NULL,
        fotoPerfilPath TEXT -- NOVA COLUNA
      )
    ''');

    // Tabela de Estudantes
    await db.execute('''
      CREATE TABLE estudantes (
        id TEXT PRIMARY KEY,
        matricula INTEGER NOT NULL,
        curso TEXT NOT NULL,
        FOREIGN KEY (id) REFERENCES usuarios(id) ON DELETE CASCADE
      )
    ''');

    // Tabela de Tutores
    await db.execute('''
      CREATE TABLE tutores (
        id TEXT PRIMARY KEY,
        curriculo TEXT NOT NULL,
        aprovado INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (id) REFERENCES usuarios(id) ON DELETE CASCADE
      )
    ''');

    // Tabela de Coordenadores
    await db.execute('''
      CREATE TABLE coordenadores (
        id TEXT PRIMARY KEY,
        FOREIGN KEY (id) REFERENCES usuarios(id) ON DELETE CASCADE
      )
    ''');

    // Tabela de Áreas de Conhecimento
    await db.execute('''
      CREATE TABLE areas_conhecimento (
        id TEXT PRIMARY KEY,
        nome TEXT NOT NULL UNIQUE,
        descricao TEXT NOT NULL
      )
    ''');

    // Tabela de Disponibilidade de Tutores
    await db.execute('''
      CREATE TABLE disponibilidades (
        id TEXT PRIMARY KEY,
        tutorId TEXT NOT NULL,
        dataHora TEXT NOT NULL, 
        agendado INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (tutorId) REFERENCES tutores(id) ON DELETE CASCADE,
        UNIQUE (tutorId, dataHora)
      )
    ''');

    // Tabela de Tutores - Áreas de Conhecimento (Many-to-Many)
    await db.execute('''
      CREATE TABLE tutor_areas (
        tutorId TEXT NOT NULL,
        areaId TEXT NOT NULL,
        PRIMARY KEY (tutorId, areaId),
        FOREIGN KEY (tutorId) REFERENCES tutores(id) ON DELETE CASCADE,
        FOREIGN KEY (areaId) REFERENCES areas_conhecimento(id) ON DELETE CASCADE
      )
    ''');

    // Tabela de Agendamentos
    await db.execute('''
      CREATE TABLE agendamentos (
        id TEXT PRIMARY KEY,
        disponibilidadeId TEXT NOT NULL,
        estudanteId TEXT NOT NULL,
        motivoSolicitacao TEXT NOT NULL,
        status INTEGER NOT NULL DEFAULT 1,
        concluido INTEGER NOT NULL DEFAULT 0,
        descricaoDeConteudo TEXT,
        FOREIGN KEY (disponibilidadeId) REFERENCES disponibilidades(id) ON DELETE CASCADE,
        FOREIGN KEY (estudanteId) REFERENCES estudantes(id)
      )
    ''');

    // Tabela de Avaliações
    await db.execute('''
      CREATE TABLE avaliacoes (
        id TEXT PRIMARY KEY,
        agendamentoId TEXT NOT NULL,
        tutorId TEXT NOT NULL,
        estudanteId TEXT NOT NULL,
        nota REAL NOT NULL,
        comentario TEXT NOT NULL,
        dataAvaliacao TEXT NOT NULL,
        FOREIGN KEY (agendamentoId) REFERENCES agendamentos(id) ON DELETE CASCADE,
        FOREIGN KEY (tutorId) REFERENCES tutores(id),
        FOREIGN KEY (estudanteId) REFERENCES estudantes(id)
      )
    ''');

    // Tabela de Notificações
    await db.execute('''
      CREATE TABLE notificacoes (
        id TEXT PRIMARY KEY,
        destinatarioId TEXT NOT NULL,
        titulo TEXT NOT NULL,
        mensagem TEXT NOT NULL,
        dataEnvio TEXT NOT NULL,
        lida INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (destinatarioId) REFERENCES usuarios(id) ON DELETE CASCADE
      )
    ''');
  }

  Future<void> _insertDefaultData(Database db) async {
    await db.insert('areas_conhecimento', {'id': '1', 'nome': 'Matemática', 'descricao': 'Área de conhecimento em matemática'}, conflictAlgorithm: ConflictAlgorithm.replace);
    await db.insert('areas_conhecimento', {'id': '2', 'nome': 'Programação', 'descricao': 'Área de conhecimento em programação'}, conflictAlgorithm: ConflictAlgorithm.replace);
    await db.insert('areas_conhecimento', {'id': '3', 'nome': 'Física', 'descricao': 'Área de conhecimento em física'}, conflictAlgorithm: ConflictAlgorithm.replace);
    await db.insert('areas_conhecimento', {'id': '4', 'nome': 'Química', 'descricao': 'Área de conhecimento em química'}, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> ensureDefaultUsers() async {
    final db = await database;
    final adminExists = await db.query('usuarios', where: 'email = ?', whereArgs: ['admin']);
    if (adminExists.isEmpty) {
      final adminId = 'admin_estudante_001';
      final agora = DateTime.now().toIso8601String();
      await db.insert('usuarios', {'id': adminId, 'nome': 'Estudante Admin', 'email': 'admin', 'senha': 'admin', 'dataCadastro': agora, 'tipoUsuario': 'estudante', 'fotoPerfilPath': null});
      await db.insert('estudantes', {'id': adminId, 'matricula': 12345, 'curso': 'Ciência da Computação'});
    }
    final coordExists = await db.query('usuarios', where: 'email = ?', whereArgs: ['pedro@exemplo.com']);
    if (coordExists.isEmpty) {
        final coordId = 'coord_pedro_001';
        final agora = DateTime.now().toIso8601String();
        await db.insert('usuarios', {'id': coordId, 'nome': 'Pedro Coordenador', 'email': 'pedro@exemplo.com', 'senha': '123456', 'dataCadastro': agora, 'tipoUsuario': 'coordenador', 'fotoPerfilPath': null});
        await db.insert('coordenadores', {'id': coordId});
    }
  }

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
}
