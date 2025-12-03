import 'package:flutter/material.dart';
import '../models/tutor.dart';
import '../models/agendamento.dart';
import '../models/disponibilidade.dart';
import '../models/estudante.dart';
import '../services/agendamento_service.dart';
import '../services/usuario_service.dart'; // Usaremos para buscar o estudante
import '../enums/status.dart';
import 'package:intl/intl.dart';

class AgendamentosTutorScreen extends StatefulWidget {
  final Tutor tutor;

  const AgendamentosTutorScreen({super.key, required this.tutor});

  @override
  State<AgendamentosTutorScreen> createState() => _AgendamentosTutorScreenState();
}

// Modelo para agrupar dados para a UI
class _AgendamentoDetalhado {
  final Agendamento agendamento;
  final Disponibilidade disponibilidade;
  final Estudante estudante;
  _AgendamentoDetalhado({required this.agendamento, required this.disponibilidade, required this.estudante});
}

class _AgendamentosTutorScreenState extends State<AgendamentosTutorScreen> {
  List<_AgendamentoDetalhado> _agendamentosDetalhados = [];
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _carregarAgendamentos();
  }

  Future<void> _carregarAgendamentos() async {
    setState(() => _carregando = true);
    try {
      final agendamentosBase = await AgendamentoService.instance.listarPorTutor(widget.tutor.id);
      final List<_AgendamentoDetalhado> agendamentosDetalhados = [];

      for (var ag in agendamentosBase) {
        final disponibilidade = await AgendamentoService.instance.getDisponibilidade(ag.disponibilidadeId);
        final estudante = await UsuarioService.instance.getEstudante(ag.estudanteId);

        if (disponibilidade != null && estudante != null) {
          agendamentosDetalhados.add(_AgendamentoDetalhado(agendamento: ag, disponibilidade: disponibilidade, estudante: estudante));
        }
      }
      // Ordena do mais recente para o mais antigo
      agendamentosDetalhados.sort((a, b) => b.disponibilidade.dataHora.compareTo(a.disponibilidade.dataHora));

      setState(() {
        _agendamentosDetalhados = agendamentosDetalhados;
        _carregando = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao carregar agendamentos: $e')));
        setState(() => _carregando = false);
      }
    }
  }

  Color _getStatusColor(Status status) {
    // ... (código existente, sem mudanças)
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
      appBar: AppBar(title: const Text('Meus Agendamentos')),
      body: _carregando
          ? const Center(child: CircularProgressIndicator())
          : _agendamentosDetalhados.isEmpty
              ? const Center(child: Text('Nenhum agendamento encontrado.'))
              : RefreshIndicator(
                  onRefresh: _carregarAgendamentos,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _agendamentosDetalhados.length,
                    itemBuilder: (context, index) {
                      final item = _agendamentosDetalhados[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(item.estudante.nome, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0056A6))),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(color: _getStatusColor(item.agendamento.status).withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
                                    child: Text(item.agendamento.status.displayName, style: TextStyle(color: _getStatusColor(item.agendamento.status), fontWeight: FontWeight.w600, fontSize: 12)),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Text('Data: ${DateFormat('dd/MM/yyyy', 'pt_BR').format(item.disponibilidade.dataHora)}', style: const TextStyle(color: Colors.black54)),
                              Text('Hora: ${DateFormat('HH:mm', 'pt_BR').format(item.disponibilidade.dataHora)}', style: const TextStyle(color: Colors.black54)),
                              if (item.agendamento.motivoSolicitacao.isNotEmpty) ...[
                                const SizedBox(height: 10),
                                Text('Motivo: ${item.agendamento.motivoSolicitacao}', style: const TextStyle(color: Colors.black87)),
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
