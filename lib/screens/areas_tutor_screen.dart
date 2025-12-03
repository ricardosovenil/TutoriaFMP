import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/tutor.dart';
import '../models/area_conhecimento.dart';
import '../services/area_conhecimento_service.dart';
import '../services/tutor_service.dart';

class AreasTutorScreen extends StatefulWidget {
  final Tutor tutor;

  const AreasTutorScreen({super.key, required this.tutor});

  @override
  State<AreasTutorScreen> createState() => _AreasTutorScreenState();
}

class _AreasTutorScreenState extends State<AreasTutorScreen> {
  late Future<List<AreaConhecimento>> _todasAreasFuture;
  Set<String> _areasTutorIds = {};
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _carregarAreas();
  }

  void _carregarAreas() {
    setState(() => _carregando = true);
    _todasAreasFuture = AreaConhecimentoService.instance.listarTodasAreas();
    _getAreasDoTutor();
  }

  Future<void> _getAreasDoTutor() async {
    final tutorCompleto = await TutorService.instance.getTutorCompleto(widget.tutor.id);
    if (mounted) {
      setState(() {
        _areasTutorIds = tutorCompleto.areasConhecimento.map((a) => a.id).toSet();
        _carregando = false;
      });
    }
  }

  Future<void> _toggleArea(String areaId) async {
    final bool contem = _areasTutorIds.contains(areaId);
    try {
      if (contem) {
        await TutorService.instance.removerAreaConhecimento(widget.tutor.id, areaId);
      } else {
        await TutorService.instance.adicionarAreaConhecimento(widget.tutor.id, areaId);
      }
      if (mounted) {
        setState(() {
          if (contem) {
            _areasTutorIds.remove(areaId);
          } else {
            _areasTutorIds.add(areaId);
          }
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: const Text('Área atualizada com sucesso!'), backgroundColor: AppColors.success),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao atualizar área: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Minhas Áreas'),
        backgroundColor: Colors.transparent, // Mantém a transparência para o design da tela escura
        elevation: 0,
      ),
      body: FutureBuilder<List<AreaConhecimento>>(
        future: _todasAreasFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting || _carregando) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}', style: theme.textTheme.bodyMedium));
          }
          final todasAreas = snapshot.data;
          if (todasAreas == null || todasAreas.isEmpty) {
            return Center(child: Text('Nenhuma área de conhecimento disponível.', style: theme.textTheme.bodyMedium));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: todasAreas.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final area = todasAreas[index];
              final selecionada = _areasTutorIds.contains(area.id);
              return _buildAreaCard(context, area, selecionada);
            },
          );
        },
      ),
    );
  }

  Widget _buildAreaCard(BuildContext context, AreaConhecimento area, bool selecionada) {
    final theme = Theme.of(context);

    // Define as cores com base na seleção e no tema (claro/escuro)
    final Color cardColor = selecionada 
        ? theme.colorScheme.primary.withOpacity(0.2) 
        : theme.cardTheme.color!;
    final Color borderColor = selecionada 
        ? theme.colorScheme.primary
        : theme.cardTheme.shape is RoundedRectangleBorder
          ? ((theme.cardTheme.shape as RoundedRectangleBorder).side.color)
          : theme.colorScheme.onSurface.withOpacity(0.2);
    final Color iconColor = selecionada ? theme.colorScheme.primary : theme.colorScheme.onSurface.withOpacity(0.6);

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: (theme.cardTheme.shape as RoundedRectangleBorder).borderRadius,
        border: Border.all(color: borderColor, width: 1.5),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        title: Text(area.nome, style: theme.textTheme.headlineSmall?.copyWith(fontSize: 16)),
        subtitle: Text(area.descricao, style: theme.textTheme.bodyMedium),
        trailing: Icon(
          selecionada ? Icons.check_circle : Icons.radio_button_unchecked,
          color: iconColor,
          size: 28,
        ),
        onTap: () => _toggleArea(area.id),
      ),
    );
  }
}
