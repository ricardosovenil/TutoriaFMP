import 'package:flutter/material.dart';
import '../models/estudante.dart';
import '../models/tutor.dart';
import '../models/agendamento.dart';
import '../models/disponibilidade.dart';
import '../services/agendamento_service.dart';
import '../services/tutor_service.dart';
import '../services/avaliacao_service.dart';
import 'package:intl/intl.dart';

class AvaliarTutorScreen extends StatefulWidget {
  final Estudante estudante;

  const AvaliarTutorScreen({super.key, required this.estudante});

  @override
  State<AvaliarTutorScreen> createState() => _AvaliarTutorScreenState();
}

class _ItemAvaliacao {
  final Agendamento agendamento;
  final Disponibilidade disponibilidade;
  final Tutor tutor;
  _ItemAvaliacao({required this.agendamento, required this.disponibilidade, required this.tutor});
}

class _AvaliarTutorScreenState extends State<AvaliarTutorScreen> {
  List<_ItemAvaliacao> _itensParaAvaliar = [];
  bool _carregando = true;
  _ItemAvaliacao? _itemSelecionado;
  double _nota = 5.0;
  final _comentarioController = TextEditingController();
  bool _avaliando = false;

  @override
  void initState() {
    super.initState();
    _carregarAgendamentos();
  }

  @override
  void dispose() {
    _comentarioController.dispose();
    super.dispose();
  }

  Future<void> _carregarAgendamentos() async {
    setState(() => _carregando = true);
    try {
      final todosAgendamentos = await AgendamentoService.instance.listarPorEstudante(widget.estudante.id);
      final concluidos = todosAgendamentos.where((a) => a.concluido).toList();
      
      final List<_ItemAvaliacao> itensCompletos = [];
      for (var ag in concluidos) {
        final disponibilidade = await AgendamentoService.instance.getDisponibilidade(ag.disponibilidadeId);
        if (disponibilidade != null) {
          final tutor = await TutorService.instance.getTutorCompleto(disponibilidade.tutorId);
          itensCompletos.add(_ItemAvaliacao(agendamento: ag, disponibilidade: disponibilidade, tutor: tutor));
        }
      }

      setState(() {
        _itensParaAvaliar = itensCompletos;
        _carregando = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao carregar agendamentos: $e')));
        setState(() => _carregando = false);
      }
    }
  }

  Future<void> _avaliarTutor() async {
    if (_itemSelecionado == null || _comentarioController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Selecione um agendamento e preencha o comentário.')));
      return;
    }

    setState(() => _avaliando = true);
    try {
      await AvaliacaoService.instance.registrarAvaliacao(
        agendamentoId: _itemSelecionado!.agendamento.id,
        tutorId: _itemSelecionado!.tutor.id, // ID do Tutor é necessário
        estudanteId: widget.estudante.id, // ID do Estudante é necessário
        nota: _nota,
        comentario: _comentarioController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Avaliação registrada com sucesso!')));
        setState(() {
          _itemSelecionado = null;
          _comentarioController.clear();
          _nota = 5.0;
        });
        _carregarAgendamentos();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao avaliar: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _avaliando = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Avaliar Tutoria')),
      body: _carregando
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: _itensParaAvaliar.isEmpty
                  ? const Center(child: Text('Nenhum agendamento concluído para avaliar.'))
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text('Selecione a Tutoria para Avaliar', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        ..._itensParaAvaliar.map((item) {
                          final selecionado = _itemSelecionado?.agendamento.id == item.agendamento.id;
                          return Card(
                            color: selecionado ? Theme.of(context).primaryColorLight : Colors.white,
                            child: ListTile(
                              title: Text(item.tutor.nome, style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text('${DateFormat('dd/MM/yyyy').format(item.disponibilidade.dataHora)} às ${DateFormat('HH:mm').format(item.disponibilidade.dataHora)}'),
                              onTap: () => setState(() => _itemSelecionado = item),
                              trailing: selecionado ? Icon(Icons.check_circle, color: Theme.of(context).primaryColor) : null,
                            ),
                          );
                        }),
                        if (_itemSelecionado != null) ...[
                          const SizedBox(height: 24),
                          const Text('Sua Avaliação', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Nota para ${(_itemSelecionado!.tutor).nome}'),
                                  Slider(value: _nota, min: 1, max: 10, divisions: 9, label: _nota.toStringAsFixed(1), onChanged: (v) => setState(() => _nota = v)),
                                  const SizedBox(height: 16),
                                  const Text('Comentário'),
                                  const SizedBox(height: 8),
                                  TextField(
                                    controller: _comentarioController,
                                    maxLines: 3,
                                    decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'Deixe sua opinião...'),
                                  ),
                                  const SizedBox(height: 16),
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: _avaliando ? null : _avaliarTutor,
                                      child: _avaliando ? const CircularProgressIndicator(strokeWidth: 2) : const Text('Enviar Avaliação'),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
            ),
    );
  }
}
