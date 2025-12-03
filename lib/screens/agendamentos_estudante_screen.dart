import 'package:flutter/material.dart';
import '../theme/app_theme.dart'; // 1. Importar o tema
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
            child: Text('Sim', style: TextStyle(color: theme.colorScheme.error)), // Usa a cor de erro do tema
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

  // 2. Usar as cores do AppColors
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
      backgroundColor: theme.scaffoldBackgroundColor, // 3. Usar a cor de fundo do tema
      appBar: AppBar(
        title: const Text('Meus Agendamentos'),
        // 4. Estilo da AppBar agora é herdado do tema
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

                      return Card(
                        // 5. O estilo do Card é herdado do tema
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      tutor.nome, 
                                      style: theme.textTheme.headlineSmall?.copyWith(color: AppColors.primaryBlue, fontSize: 18), // 6. Estilo do texto padronizado
                                    ),
                                  ),
                                  _buildStatusBadge(agendamento.status),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Text('Data: ${DateFormat('dd/MM/yyyy', 'pt_BR').format(disponibilidade.dataHora)}', style: theme.textTheme.bodyMedium),
                              Text('Hora: ${DateFormat('HH:mm', 'pt_BR').format(disponibilidade.dataHora)}', style: theme.textTheme.bodyMedium),
                              if (agendamento.motivoSolicitacao.isNotEmpty) ...[
                                const SizedBox(height: 10),
                                Text('Motivo: ${agendamento.motivoSolicitacao}', style: theme.textTheme.bodyLarge),
                              ],
                              if (agendamento.status == Status.aguardandoAp || agendamento.status == Status.aprovado) ...[
                                const SizedBox(height: 15),
                                SizedBox(
                                  width: double.infinity,
                                  child: OutlinedButton(
                                    onPressed: () => _cancelarAgendamento(agendamento),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: theme.colorScheme.error,
                                      side: BorderSide(color: theme.colorScheme.error), // 7. Botão usa a cor de erro do tema
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
