import 'package:flutter/material.dart';
import 'package:open_file_plus/open_file_plus.dart';
import '../models/tutor.dart';
import '../services/tutor_service.dart';
import '../theme/app_theme.dart';

class GerenciarTutoresScreen extends StatefulWidget {
  const GerenciarTutoresScreen({super.key});

  @override
  State<GerenciarTutoresScreen> createState() => _GerenciarTutoresScreenState();
}

class _GerenciarTutoresScreenState extends State<GerenciarTutoresScreen> {
  late Future<List<Tutor>> _tutoresFuture;

  @override
  void initState() {
    super.initState();
    _carregarTutores();
  }

  void _carregarTutores() {
    _tutoresFuture = TutorService.instance.listarTutores().then((tutores) {
      tutores.sort((a, b) => a.aprovado.compareTo(b.aprovado));
      return tutores;
    });
  }

  Future<void> _aprovarTutor(String tutorId) async {
    try {
      await TutorService.instance.aprovarTutor(tutorId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tutor aprovado com sucesso!'), backgroundColor: AppColors.success));
        setState(() => _carregarTutores());
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao aprovar tutor: $e'), backgroundColor: AppColors.error));
    }
  }

  Future<void> _excluirTutor(String tutorId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: const Text('Tem certeza de que deseja excluir este tutor? Esta ação é permanente.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Excluir', style: TextStyle(color: AppColors.error))),
        ],
      ),
    ) ?? false;

    if (confirm) {
      try {
        await TutorService.instance.excluirTutor(tutorId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tutor excluído com sucesso!'), backgroundColor: AppColors.success));
          setState(() => _carregarTutores());
        }
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao excluir tutor: $e'), backgroundColor: AppColors.error));
      }
    }
  }

  Future<void> _visualizarCurriculo(String filePath) async {
    final result = await OpenFile.open(filePath);
    if (result.type != ResultType.done && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Não foi possível abrir o arquivo: ${result.message}')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Gerenciar Tutores'),
      ),
      body: FutureBuilder<List<Tutor>>(
        future: _tutoresFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          }
          final tutores = snapshot.data;
          if (tutores == null || tutores.isEmpty) {
            return _buildEmptyState();
          }
          return RefreshIndicator(
            onRefresh: () async => setState(() => _carregarTutores()),
            child: ListView.separated(
              padding: const EdgeInsets.all(16.0),
              itemCount: tutores.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) => _buildTutorCard(context, tutores[index]),
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildEmptyState() {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 80, color: theme.colorScheme.onSurface.withOpacity(0.7)),
          const SizedBox(height: 20),
          Text('Nenhum Tutor Cadastrado', style: theme.textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text('Os tutores pendentes e aprovados aparecerão aqui.', textAlign: TextAlign.center, style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }

  Widget _buildTutorCard(BuildContext context, Tutor tutor) {
    final theme = Theme.of(context);
    final isPendente = tutor.aprovado == 0;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text(tutor.nome, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis)),
                Chip(
                  label: Text(isPendente ? 'Pendente' : 'Aprovado', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  backgroundColor: isPendente ? AppColors.warning : AppColors.success,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(tutor.email, style: theme.textTheme.bodyMedium),
            const Divider(height: 16),
            OutlinedButton.icon(
              icon: const Icon(Icons.picture_as_pdf_rounded, size: 18),
              label: const Text('Visualizar Currículo'),
              onPressed: tutor.curriculo.isNotEmpty ? () => _visualizarCurriculo(tutor.curriculo) : null,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                if (isPendente)
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.check),
                      label: const Text('Aprovar'),
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
                      onPressed: () => _aprovarTutor(tutor.id),
                    ),
                  ),
                if (isPendente) const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('Excluir'),
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
                    onPressed: () => _excluirTutor(tutor.id),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
