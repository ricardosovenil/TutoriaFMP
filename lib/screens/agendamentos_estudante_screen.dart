import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/estudante.dart';
import '../models/agendamento.dart';
import '../models/tutor.dart';
import '../models/disponibilidade.dart';
import '../services/agendamento_service.dart';
import '../services/tutor_service.dart';
import '../enums/status.dart';
import 'package:intl/intl.dart';

class AgendamentosEstudanteScreen extends StatefulWidget {
  final Estudante estudante;

  const AgendamentosEstudanteScreen({super.key, required this.estudante});

  @override
  State<AgendamentosEstudanteScreen> createState() => _AgendamentosEstudanteScreenState();
}

class _AgendamentoCompleto {
  final Agendamento agendamento;
  final Disponibilidade disponibilidade;
  final Tutor tutor;
  _AgendamentoCompleto({required this.agendamento, required this.disponibilidade, required this.tutor});
}

class _AgendamentosEstudanteScreenState extends State<AgendamentosEstudanteScreen> {
  List<_AgendamentoCompleto> _agendamentosCompletos = [];
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _carregarAgendamentos();
  }

  Future<void> _carregarAgendamentos() async {
    setState(() => _carregando = true);
    try {
      final agendamentosBase = await AgendamentoService.instance.listarPorEstudante(widget.estudante.id);
      final List<_AgendamentoCompleto> agendamentosCompletos = [];

      for (var ag in agendamentosBase) {
        final disponibilidade = await AgendamentoService.instance.getDisponibilidade(ag.disponibilidadeId);
        if (disponibilidade != null) {
          final tutor = await TutorService.instance.getTutorCompleto(disponibilidade.tutorId);
          agendamentosCompletos.add(_AgendamentoCompleto(agendamento: ag, disponibilidade: disponibilidade, tutor: tutor));
        }
      }

      setState(() {
        _agendamentosCompletos = agendamentosCompletos;
        _carregando = false;
      });
    } catch (e) {
      setState(() => _carregando = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao carregar agendamentos: $e')));
      }
    }
  }

  Future<void> _cancelarAgendamento(Agendamento agendamento) async {
    final theme = Theme.of(context);
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancelar Agendamento'),
        content: const Text('Deseja realmente cancelar este agendamento?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Não')),
          TextButton(
            onPressed: () => Navigator.pop(context, true), 
            child: Text('Sim', style: TextStyle(color: theme.colorScheme.error)),
          ),
        ],
      ),
    );

    if (confirmado == true) {
      try {
        await AgendamentoService.instance.atualizarStatus(agendamento.id, Status.cancelado);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Agendamento cancelado com sucesso!')));
          _carregarAgendamentos();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao cancelar: $e')));
        }
      }
    }
  }

  Color _getStatusColor(Status status) {
    switch (status) {
      case Status.aprovado: return AppColors.success;
      case Status.aguardandoAp: return AppColors.warning;
      case Status.negado: return AppColors.error;
      case Status.cancelado: return AppColors.darkGrey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Meus Agendamentos'),
      ),
      body: _carregando
          ? const Center(child: CircularProgressIndicator())
          : _agendamentosCompletos.isEmpty
              ? Center(child: Text('Nenhum agendamento encontrado.', style: theme.textTheme.bodyMedium))
              : RefreshIndicator(
                  onRefresh: _carregarAgendamentos,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _agendamentosCompletos.length,
                    itemBuilder: (context, index) {
                      final item = _agendamentosCompletos[index];
                      final agendamento = item.agendamento;
                      final tutor = item.tutor;
                      final disponibilidade = item.disponibilidade;

                      // AJUSTE: O Padding e os SizedBox foram reduzidos para um layout mais compacto
                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      tutor.nome, 
                                      style: theme.textTheme.titleLarge?.copyWith(color: AppColors.primaryBlue, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  _buildStatusBadge(agendamento.status),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text('Data: ${DateFormat('dd/MM/yyyy', 'pt_BR').format(disponibilidade.dataHora)}', style: theme.textTheme.bodyMedium),
                              const SizedBox(height: 2),
                              Text('Hora: ${DateFormat('HH:mm', 'pt_BR').format(disponibilidade.dataHora)}', style: theme.textTheme.bodyMedium),
                              if (agendamento.motivoSolicitacao.isNotEmpty) ...[
                                const Divider(height: 12),
                                Text('Motivo: ${agendamento.motivoSolicitacao}', style: theme.textTheme.bodyLarge),
                              ],
                              if (agendamento.status == Status.aguardandoAp || agendamento.status == Status.aprovado) ...[
                                const SizedBox(height: 12),
                                SizedBox(
                                  width: double.infinity,
                                  child: OutlinedButton(
                                    onPressed: () => _cancelarAgendamento(agendamento),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: theme.colorScheme.error,
                                      side: BorderSide(color: theme.colorScheme.error),
                                    ),
                                    child: const Text('Cancelar Agendamento'),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }

  Widget _buildStatusBadge(Status status) {
    final Color color = _getStatusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.displayName, 
        style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 12)
      ),
    );
  }
}
