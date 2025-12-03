import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/tutor.dart';
import '../models/agendamento.dart';
import '../models/avaliacao.dart';
import '../services/relatorio_service.dart';

class RelatorioTutorDetalheScreen extends StatefulWidget {
  final Tutor tutor;

  const RelatorioTutorDetalheScreen({super.key, required this.tutor});

  @override
  State<RelatorioTutorDetalheScreen> createState() => _RelatorioTutorDetalheScreenState();
}

class _RelatorioTutorDetalheScreenState extends State<RelatorioTutorDetalheScreen> {
  late Future<Map<String, dynamic>> _relatorioFuture;

  @override
  void initState() {
    super.initState();
    _relatorioFuture = RelatorioService.instance.getRelatorioCompletoTutor(widget.tutor.id);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // 2 abas: Agendamentos e Avaliações
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.tutor.nome, overflow: TextOverflow.ellipsis),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.calendar_today), text: 'Agendamentos'),
              Tab(icon: Icon(Icons.star), text: 'Avaliações'),
            ],
          ),
        ),
        body: FutureBuilder<Map<String, dynamic>>(
          future: _relatorioFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Erro ao carregar relatório: ${snapshot.error}'));
            }
            if (!snapshot.hasData) {
              return const Center(child: Text('Nenhum dado encontrado.'));
            }

            final List<Agendamento> agendamentos = snapshot.data!['agendamentos'];
            final List<Avaliacao> avaliacoes = snapshot.data!['avaliacoes'];

            return TabBarView(
              children: [
                _buildAgendamentosList(agendamentos),
                _buildAvaliacoesList(avaliacoes),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildAgendamentosList(List<Agendamento> agendamentos) {
    if (agendamentos.isEmpty) {
      return const Center(child: Text('Este tutor não possui agendamentos.'));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: agendamentos.length,
      itemBuilder: (context, index) {
        final agendamento = agendamentos[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          child: ListTile(
            title: Text('Estudante: ${agendamento.estudanteNome ?? 'N/A'}'),
            subtitle: Text(DateFormat('dd/MM/yyyy HH:mm').format(agendamento.dataHora!)),
            trailing: Chip(
              label: Text(agendamento.status.name, style: const TextStyle(fontSize: 12)),
              backgroundColor: agendamento.concluido ? Colors.green[100] : Colors.grey[200],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAvaliacoesList(List<Avaliacao> avaliacoes) {
    if (avaliacoes.isEmpty) {
      return const Center(child: Text('Este tutor não recebeu nenhuma avaliação.'));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: avaliacoes.length,
      itemBuilder: (context, index) {
        final avaliacao = avaliacoes[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          child: ListTile(
            leading: CircleAvatar(child: Text(avaliacao.nota.toStringAsFixed(1))),
            title: Text('Estudante: ${avaliacao.estudanteNome ?? 'N/A'}'),
            subtitle: Text(avaliacao.comentario, maxLines: 2, overflow: TextOverflow.ellipsis),
          ),
        );
      },
    );
  }
}
