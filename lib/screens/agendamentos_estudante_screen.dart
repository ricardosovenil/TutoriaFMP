import 'package:flutter/material.dart';
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
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancelar Agendamento'),
        content: const Text('Deseja realmente cancelar este agendamento?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Não')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Sim', style: TextStyle(color: Colors.red))),
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
      case Status.aprovado: return Colors.green;
      case Status.aguardandoAp: return Colors.orange;
      case Status.negado: return Colors.red;
      case Status.cancelado: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: AppBar(
        title: const Text('Meus Agendamentos', style: TextStyle(color: Colors.black87)),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: _carregando
          ? const Center(child: CircularProgressIndicator())
          : _agendamentosCompletos.isEmpty
              ? const Center(child: Text('Nenhum agendamento encontrado.'))
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
                        margin: const EdgeInsets.only(bottom: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(tutor.nome, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0056A6))),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: _getStatusColor(agendamento.status).withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(agendamento.status.displayName, style: TextStyle(color: _getStatusColor(agendamento.status), fontWeight: FontWeight.w600, fontSize: 12)),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Text('Data: ${DateFormat('dd/MM/yyyy', 'pt_BR').format(disponibilidade.dataHora)}', style: const TextStyle(color: Colors.black54)),
                              Text('Hora: ${DateFormat('HH:mm', 'pt_BR').format(disponibilidade.dataHora)}', style: const TextStyle(color: Colors.black54)),
                              if (agendamento.motivoSolicitacao.isNotEmpty) ...[
                                const SizedBox(height: 10),
                                Text('Motivo: ${agendamento.motivoSolicitacao}', style: const TextStyle(color: Colors.black87)),
                              ],
                              if (agendamento.status == Status.aguardandoAp || agendamento.status == Status.aprovado) ...[
                                const SizedBox(height: 15),
                                SizedBox(
                                  width: double.infinity,
                                  child: OutlinedButton(
                                    onPressed: () => _cancelarAgendamento(agendamento),
                                    style: OutlinedButton.styleFrom(foregroundColor: Colors.red, side: const BorderSide(color: Colors.red)),
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
}
