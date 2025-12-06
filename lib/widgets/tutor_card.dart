import 'package:flutter/material.dart';
import '../models/tutor.dart';
import 'dart:io';

class TutorCard extends StatelessWidget {
  final Tutor tutor;
  final VoidCallback onTap;
  final bool isSelected;

  const TutorCard({
    super.key,
    required this.tutor,
    required this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasDisponibilidade = tutor.disponibilidades.any((d) => d.dataHora.isAfter(DateTime.now()));

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Card(
        elevation: isSelected ? 8 : 2,
        color: isSelected ? theme.colorScheme.primary.withOpacity(0.1) : theme.cardTheme.color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: BorderSide(
            color: isSelected ? theme.colorScheme.primary : theme.dividerColor,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center, // Centraliza o conteúdo na coluna
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: theme.colorScheme.onSurface.withOpacity(0.1),
                backgroundImage: tutor.fotoPerfilPath != null && File(tutor.fotoPerfilPath!).existsSync()
                    ? FileImage(File(tutor.fotoPerfilPath!))
                    : null,
                child: tutor.fotoPerfilPath == null || !File(tutor.fotoPerfilPath!).existsSync()
                    ? Icon(Icons.person, size: 40, color: theme.colorScheme.onSurface.withOpacity(0.4))
                    : null,
              ),
              const SizedBox(height: 12), // Espaçamento reduzido
              Text(
                tutor.nome.split(' ').first, // Mostra apenas o primeiro nome
                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4), // Espaçamento reduzido
              Text(
                tutor.areasConhecimento.isNotEmpty ? tutor.areasConhecimento.first.nome : 'Sem área',
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const Spacer(), // Ocupa o espaço restante para empurrar o status para baixo
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    hasDisponibilidade ? Icons.check_circle_outline : Icons.highlight_off,
                    color: hasDisponibilidade ? Colors.green : Colors.red,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    hasDisponibilidade ? 'Disponível' : 'Sem horários',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
