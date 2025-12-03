import 'package:flutter/material.dart';

// Modelo que representa um único slot de horário específico de um tutor.
class Disponibilidade {
  final String id;
  final String tutorId;
  final DateTime dataHora;
  bool agendado; // Pode ser modificado

  Disponibilidade({
    required this.id,
    required this.tutorId,
    required this.dataHora,
    this.agendado = false,
  });

  // Converte de um Map do banco de dados para um objeto Disponibilidade
  factory Disponibilidade.fromMap(Map<String, dynamic> map) {
    return Disponibilidade(
      id: map['id'] as String,
      tutorId: map['tutorId'] as String,
      // O banco armazena a data como texto no padrão ISO 8601
      dataHora: DateTime.parse(map['dataHora'] as String),
      // O banco armazena booleano como 0 ou 1
      agendado: (map['agendado'] as int) == 1,
    );
  }

  // Converte o objeto Disponibilidade para um Map para salvar no banco
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tutorId': tutorId,
      // Converte a data para o formato de texto padrão (ISO 8601)
      'dataHora': dataHora.toIso8601String(),
      // Converte o booleano para 0 ou 1
      'agendado': agendado ? 1 : 0,
    };
  }
}
