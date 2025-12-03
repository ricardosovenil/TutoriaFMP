import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../models/tutor.dart';
import '../models/agendamento.dart';
import '../services/agendamento_service.dart';

class AgendamentosTutorScreen extends StatefulWidget {
  final Tutor tutor;

  const AgendamentosTutorScreen({super.key, required this.tutor});

  @override
  State<AgendamentosTutorScreen> createState() => _AgendamentosTutorScreenState();
}

class _AgendamentosTutorScreenState extends State<AgendamentosTutorScreen> {
  late Future<List<Agendamento>> _agendamentosFuturos;

  @override
  void initState() {
    super.initState();
    _carregarAgendamentos();
  }

  void _carregarAgendamentos() {
    setState(() {
      _agendamentosFuturos = AgendamentoService.instance.getAgendamentosAprovadosDetalhados(widget.tutor.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Meus Agendamentos'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: FutureBuilder<List<Agendamento>>(
        future: _agendamentosFuturos,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return _buildErrorState(context, snapshot.error.toString());
          }

          final agendamentos = snapshot.data;

          if (agendamentos == null || agendamentos.isEmpty) {
            return _buildEmptyState(context);
          }

          return RefreshIndicator(
            onRefresh: () async => _carregarAgendamentos(),
            child: ListView.separated(
              padding: const EdgeInsets.all(16.0),
              itemCount: agendamentos.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                return _buildAgendamentoCard(context, agendamentos[index]);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.calendar_today_outlined, size: 80, color: theme.colorScheme.onSurface.withOpacity(0.7)),
          const SizedBox(height: 20),
          Text('Nenhum Agendamento', style: theme.textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(
            'Seus agendamentos aprovados aparecerão aqui.',
            textAlign: TextAlign.center, 
            style: theme.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String error) {
    final theme = Theme.of(context);
    return Center(
      child: Container(
        padding: const EdgeInsets.all(24),
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.cardTheme.color,
          borderRadius: (theme.cardTheme.shape as RoundedRectangleBorder).borderRadius,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, color: theme.colorScheme.error, size: 50),
            const SizedBox(height: 16),
            Text('Ocorreu um Erro', style: theme.textTheme.headlineSmall, textAlign: TextAlign.center),
            const SizedBox(height: 10),
            Text('Não foi possível carregar os agendamentos.', style: theme.textTheme.bodyMedium, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _buildAgendamentoCard(BuildContext context, Agendamento agendamento) {
    final theme = Theme.of(context);
    final studentName = agendamento.estudanteNome ?? 'Aluno não encontrado';
    final dataHora = agendamento.dataHora;
    if (dataHora == null) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(studentName, style: theme.textTheme.headlineSmall?.copyWith(fontSize: 18)),
            const SizedBox(height: 12),
            Row(children: [
              Icon(Icons.calendar_today, size: 16, color: theme.textTheme.bodyMedium?.color),
              const SizedBox(width: 8),
              Text(DateFormat('dd/MM/yyyy', 'pt_BR').format(dataHora), style: theme.textTheme.bodyLarge)
            ]),
            const SizedBox(height: 6),
            Row(children: [
              Icon(Icons.access_time, size: 16, color: theme.textTheme.bodyMedium?.color),
              const SizedBox(width: 8),
              Text(DateFormat('HH:mm', 'pt_BR').format(dataHora), style: theme.textTheme.bodyLarge)
            ]),
            const Divider(height: 24),
            Text('Motivo da Solicitação:', style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text(agendamento.motivoSolicitacao, style: theme.textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}
