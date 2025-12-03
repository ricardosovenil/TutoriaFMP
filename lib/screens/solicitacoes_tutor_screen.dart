import 'dart:ui';
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
  // Agora o Future retorna a lista de agendamentos já com todos os detalhes
  late Future<List<Agendamento>> _solicitacoesFuture;

  @override
  void initState() {
    super.initState();
    _carregarSolicitacoes();
  }

  void _carregarSolicitacoes() {
    // Assumimos que o service foi otimizado para buscar tudo em uma query só
    _solicitacoesFuture = AgendamentoService.instance.getSolicitacoesPendentes(widget.tutor.id);
  }

  Future<void> _responderSolicitacao(Agendamento agendamento, Status novoStatus) async {
    try {
      final sucesso = await AgendamentoService.instance.atualizarStatus(agendamento.id, novoStatus);
      if (sucesso && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Solicitação ${novoStatus == Status.aprovado ? "aprovada" : "recusada"}!')));
        // Recarrega a lista para refletir a mudança
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
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Solicitações', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Stack(
        children: [
          Image.asset('assets/background_home.jpg', fit: BoxFit.cover, width: double.infinity, height: double.infinity),
          SafeArea(
            child: FutureBuilder<List<Agendamento>>(
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
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
     return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.3))
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.notifications_off_outlined, size: 60, color: Colors.white70),
                const SizedBox(height: 20),
                const Text('Nenhuma Solicitação', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 8),
                Text('Quando um aluno solicitar uma tutoria,\nela aparecerá aqui.', textAlign: TextAlign.center, style: TextStyle(color: Colors.white.withOpacity(0.7))),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSolicitacaoCard(Agendamento agendamento) {
    final studentName = agendamento.estudanteNome ?? 'Aluno não encontrado';
    final dataHora = agendamento.dataHora;
    if (dataHora == null) return const SizedBox.shrink(); // Não deveria acontecer

    return ClipRRect(
      borderRadius: BorderRadius.circular(15),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.white.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(studentName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 8),
              Row(children: [const Icon(Icons.calendar_today, size: 16, color: Colors.white70), const SizedBox(width: 8), Text(DateFormat('dd/MM/yyyy', 'pt_BR').format(dataHora), style: const TextStyle(color: Colors.white))]),
              const SizedBox(height: 4),
              Row(children: [const Icon(Icons.access_time, size: 16, color: Colors.white70), const SizedBox(width: 8), Text(DateFormat('HH:mm', 'pt_BR').format(dataHora), style: const TextStyle(color: Colors.white))]),
              const Divider(height: 20, color: Colors.white30),
              const Text('Motivo da Solicitação:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 4),
              Text(agendamento.motivoSolicitacao, style: TextStyle(color: Colors.white.withOpacity(0.9))),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _buildResponseButton('Recusar', Colors.red, () => _responderSolicitacao(agendamento, Status.negado)),
                  const SizedBox(width: 8),
                  _buildResponseButton('Aprovar', Colors.green, () => _responderSolicitacao(agendamento, Status.aprovado)),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResponseButton(String text, Color color, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withOpacity(0.8),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(horizontal: 20)
      ),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }
}
