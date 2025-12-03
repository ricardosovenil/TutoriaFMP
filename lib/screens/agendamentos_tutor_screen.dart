import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
    return Scaffold(
      backgroundColor: const Color(0xFF0A1A46),
      appBar: AppBar(
        title: const Text('Meus Agendamentos', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: FutureBuilder<List<Agendamento>>(
        future: _agendamentosFuturos,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.white));
          }

          if (snapshot.hasError) {
            return _buildErrorState(snapshot.error.toString());
          }

          final agendamentos = snapshot.data;

          if (agendamentos == null || agendamentos.isEmpty) {
            return _buildEmptyState();
          }

          return RefreshIndicator(
            onRefresh: () async => _carregarAgendamentos(),
            child: ListView.separated(
              padding: const EdgeInsets.all(16.0),
              itemCount: agendamentos.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                return _buildAgendamentoCard(agendamentos[index]);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.calendar_today_outlined, size: 80, color: Colors.white70),
          SizedBox(height: 20),
          Text('Nenhum Agendamento', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
          SizedBox(height: 8),
          Text('Seus agendamentos aprovados aparecerão aqui.', textAlign: TextAlign.center, style: TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(24),
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.6),
          borderRadius: BorderRadius.circular(15),
        ),
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, color: Colors.redAccent, size: 50),
            SizedBox(height: 16),
            Text(
              'Ocorreu um Erro',
              style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10),
            Text(
              'Não foi possível carregar os agendamentos.',
              style: TextStyle(color: Colors.white70),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAgendamentoCard(Agendamento agendamento) {
    final studentName = agendamento.estudanteNome ?? 'Aluno não encontrado';
    final dataHora = agendamento.dataHora;
    if (dataHora == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(studentName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 12),
          Row(children: [const Icon(Icons.calendar_today, size: 16, color: Colors.white70), const SizedBox(width: 8), Text(DateFormat('dd/MM/yyyy', 'pt_BR').format(dataHora), style: const TextStyle(color: Colors.white))]),
          const SizedBox(height: 6),
          Row(children: [const Icon(Icons.access_time, size: 16, color: Colors.white70), const SizedBox(width: 8), Text(DateFormat('HH:mm', 'pt_BR').format(dataHora), style: const TextStyle(color: Colors.white))]),
          const Divider(height: 24, color: Colors.white30),
          const Text('Motivo da Solicitação:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 6),
          Text(agendamento.motivoSolicitacao, style: const TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }
}
