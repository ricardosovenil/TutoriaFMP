import 'package:flutter/material.dart';
import '../models/tutor.dart';
import '../models/area_conhecimento.dart';
import '../models/disponibilidade.dart';
import '../repositories/tutor_repository.dart';
import '../repositories/usuario_repository.dart'; // Importa o repositório de usuário

class TutorService {
  static final TutorService instance = TutorService._init();
  final _tutorRepository = TutorRepository();
  final _usuarioRepository = UsuarioRepository(); // Instancia o novo repositório

  TutorService._init();

  Future<Tutor> getTutorCompleto(String tutorId) async {
    final tutorBaseMap = await _tutorRepository.findTutorBase(tutorId);
    if (tutorBaseMap == null) {
      throw Exception('Tutor não encontrado no serviço');
    }

    final areas = await _tutorRepository.findAreasConhecimento(tutorId);
    final disponibilidades = await _tutorRepository.findDisponibilidades(tutorId);
    final mediaAvaliacoes = await _tutorRepository.getMediaAvaliacoes(tutorId);

    final tutorData = {
      ...tutorBaseMap,
      'areasConhecimento': areas.map((a) => a.toJson()).toList(),
      'disponibilidades': disponibilidades.map((d) => d.toMap()).toList(),
      'mediaAvaliacoes': mediaAvaliacoes,
    };

    return Tutor.fromJson(tutorData);
  }

  Future<List<Tutor>> listarTutores({bool? aprovado}) async {
    final tutorIds = await _tutorRepository.listarTutorIds(aprovado: aprovado);
    
    final tutores = <Tutor>[];
    for (var id in tutorIds) {
      try {
        final tutor = await getTutorCompleto(id);
        tutores.add(tutor);
      } catch (e) {
        debugPrint("Erro ao buscar tutor completo ($id): $e");
      }
    }
    return tutores;
  }

  Future<bool> aprovarTutor(String tutorId) {
    return _tutorRepository.aprovarTutor(tutorId);
  }

  // NOVO: Método para excluir um tutor
  Future<void> excluirTutor(String tutorId) async {
    // A lógica de deleção em cascata no banco de dados cuida do resto.
    await _usuarioRepository.excluirUsuario(tutorId);
  }

  Future<void> cadastrarDisponibilidade({required String tutorId, required DateTime dataHora}) async {
    final novoSlot = Disponibilidade(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      tutorId: tutorId,
      dataHora: dataHora,
      agendado: false,
    );
    await _tutorRepository.adicionarDisponibilidade(novoSlot);
  }

  Future<void> removerDisponibilidade(String disponibilidadeId) {
    return _tutorRepository.removerDisponibilidade(disponibilidadeId);
  }

  Future<bool> adicionarAreaConhecimento(String tutorId, String areaId) {
    return _tutorRepository.adicionarAreaConhecimento(tutorId, areaId);
  }

  Future<bool> removerAreaConhecimento(String tutorId, String areaId) {
    return _tutorRepository.removerAreaConhecimento(tutorId, areaId);
  }
}
