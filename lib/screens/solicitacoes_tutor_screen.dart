import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/tutor.dart';
import '../models/agendamento.dart';
import '../enums/status.dart';
import '../services/agendamento_service.dart';

class SolicitacoesTutorScreen extends StatefulWidget {
  final Tutor tutor;

  const SolicitacoesTutorScreen({super.key, required this.tutor});

  @override
  State<SolicitacoesTutorScreen> createState() => _SolicitacoesTutorScreenState();
}

class _SolicitacoesTutorScreenState extends State<SolicitacoesTutorScreen> {
  late Future<List<Agendamento>> _solicitacoesFuture;

  @override
  void initState() {
    super.initState();
    _carregarSolicitacoes();
  }

  void _carregarSolicitacoes() {
    setState(() {
      _solicitacoesFuture = AgendamentoService.instance.getSolicitacoesPendentes(widget.tutor.id);
    });
  }

  Future<void> _responderSolicitacao(Agendamento agendamento, Status novoStatus) async {
    try {
      final sucesso = await AgendamentoService.instance.atualizarStatus(agendamento.id, novoStatus);
      if (sucesso && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Solicitação ${novoStatus == Status.aprovado ? "aprovada" : "recusada"}!')));
        setState(() {
          _carregarSolicitacoes();
        });
      }
    } catch (e) {
       if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao responder solicitação: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A1A46),
      appBar: AppBar(
        title: const Text('Solicitações', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: FutureBuilder<List<Agendamento>>(
        future: _solicitacoesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.white));
          }
          if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}', style: const TextStyle(color: Colors.white)));
          }
          final solicitacoes = snapshot.data;
          if (solicitacoes == null || solicitacoes.isEmpty) {
            return _buildEmptyState();
          }
          return RefreshIndicator(
            onRefresh: () async => setState(() => _carregarSolicitacoes()),
            child: ListView.separated(
              padding: const EdgeInsets.all(16.0),
              itemCount: solicitacoes.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                return _buildSolicitacaoCard(solicitacoes[index]);
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
          Icon(Icons.notifications_off_outlined, size: 80, color: Colors.white70),
          SizedBox(height: 20),
          Text('Nenhuma Solicitação Pendente', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
          SizedBox(height: 8),
          Text('Novas solicitações de tutoria aparecerão aqui.', textAlign: TextAlign.center, style: TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }

  Widget _buildSolicitacaoCard(Agendamento agendamento) {
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
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _buildResponseButton('Recusar', Colors.red.shade400, () => _responderSolicitacao(agendamento, Status.negado)),
              const SizedBox(width: 12),
              _buildResponseButton('Aprovar', Colors.green.shade400, () => _responderSolicitacao(agendamento, Status.aprovado)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildResponseButton(String text, Color color, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12)
      ),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }
}
