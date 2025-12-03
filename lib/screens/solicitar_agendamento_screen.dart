import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/tutor.dart';
import '../models/estudante.dart';
import '../models/disponibilidade.dart';
import '../services/agendamento_service.dart';

class SolicitarAgendamentoScreen extends StatefulWidget {
  final Tutor tutor;
  final Estudante estudante;

  const SolicitarAgendamentoScreen({super.key, required this.tutor, required this.estudante});

  @override
  State<SolicitarAgendamentoScreen> createState() => _SolicitarAgendamentoScreenState();
}

class _SolicitarAgendamentoScreenState extends State<SolicitarAgendamentoScreen> {
  // A lista de disponibilidades já vem do objeto Tutor, que foi carregado na tela anterior.
  late List<Disponibilidade> _disponibilidades;

  final DateTime _hoje = DateTime.now();
  DateTime? _diaSelecionado;
  Disponibilidade? _horarioSelecionado;

  final _motivoController = TextEditingController();
  bool _confirmando = false;

  @override
  void initState() {
    super.initState();
    // Filtra apenas os slots livres e futuros
    _disponibilidades = widget.tutor.disponibilidades
        .where((d) => !d.agendado && d.dataHora.isAfter(DateTime.now()))
        .toList();
    _diaSelecionado = DateTime(_hoje.year, _hoje.month, _hoje.day);
  }

  @override
  void dispose() {
    _motivoController.dispose();
    super.dispose();
  }

  List<Disponibilidade> _getSlotsParaDia(DateTime dia) {
    final slots = _disponibilidades.where((d) => isSameDay(d.dataHora, dia)).toList();
    slots.sort((a, b) => a.dataHora.compareTo(b.dataHora));
    return slots;
  }

  bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  Future<void> _confirmarAgendamento() async {
    if (_horarioSelecionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Por favor, selecione um horário.')));
      return;
    }
    if (_motivoController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Por favor, informe o motivo da sua solicitação.')));
      return;
    }

    setState(() => _confirmando = true);
    try {
      await AgendamentoService.instance.criarAgendamento(
        disponibilidadeId: _horarioSelecionado!.id,
        estudanteId: widget.estudante.id,
        motivoSolicitacao: _motivoController.text.trim(),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Agendamento solicitado com sucesso!')));
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao salvar agendamento: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _confirmando = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Marcar Tutoria')),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildTutorCard(),
          const SizedBox(height: 24),
          const Text('Escolha o dia', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          _buildDaySelector(),
          const SizedBox(height: 24),
          const Text('Escolha o horário', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          _buildTimeGrid(),
          const SizedBox(height: 24),
          const Text('Motivo da Solicitação', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextField(
            controller: _motivoController,
            decoration: InputDecoration(hintText: 'Ex: Dúvidas sobre Cálculo I', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
            maxLines: 3,
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: _confirmando ? null : _confirmarAgendamento,
          child: _confirmando ? const CircularProgressIndicator(strokeWidth: 2) : const Text('Solicitar Agendamento'),
        ),
      ),
    );
  }

   Widget _buildTutorCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.tutor.nome, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
             if (widget.tutor.areasConhecimento.isNotEmpty) ...[
              const Divider(height: 20),
              Wrap(
                spacing: 8.0,
                runSpacing: 4.0,
                children: widget.tutor.areasConhecimento.map((area) => Chip(label: Text(area.nome))).toList(),
              )
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildDaySelector() {
    return SizedBox(
      height: 65,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 14,
        itemBuilder: (context, index) {
          final dia = _hoje.add(Duration(days: index));
          final isSelected = isSameDay(dia, _diaSelecionado!);
          final hasSlots = _disponibilidades.any((d) => isSameDay(d.dataHora, dia));

          return GestureDetector(
            onTap: hasSlots ? () => setState(() {
              _diaSelecionado = dia;
              _horarioSelecionado = null;
            }) : null,
            child: Container(
              width: 55,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: isSelected ? Theme.of(context).primaryColor : (hasSlots ? Colors.grey.shade200 : Colors.grey.shade100),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(DateFormat('dd', 'pt_BR').format(dia), style: TextStyle(fontWeight: FontWeight.bold, color: isSelected ? Colors.white : (hasSlots ? Colors.black87 : Colors.grey.shade400))),
                  Text(DateFormat('E', 'pt_BR').format(dia).toUpperCase(), style: TextStyle(fontSize: 12, color: isSelected ? Colors.white70 : (hasSlots ? Colors.black54 : Colors.grey.shade400))),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTimeGrid() {
    if (_diaSelecionado == null) return const SizedBox.shrink();
    final slotsDoDia = _getSlotsParaDia(_diaSelecionado!);

    if (slotsDoDia.isEmpty) {
      return const Center(child: Padding(padding: EdgeInsets.all(16.0), child: Text('Nenhum horário disponível para este dia.', style: TextStyle(color: Colors.grey))));
    }

    return Wrap(
      spacing: 8.0,
      runSpacing: 8.0,
      children: slotsDoDia.map((slot) {
        final isSelected = _horarioSelecionado?.id == slot.id;
        return ChoiceChip(
          label: Text(DateFormat.Hm('pt_BR').format(slot.dataHora)),
          selected: isSelected,
          onSelected: (selected) => setState(() => _horarioSelecionado = selected ? slot : null),
          selectedColor: Theme.of(context).primaryColor,
          labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black),
          backgroundColor: Colors.grey.shade200,
        );
      }).toList(),
    );
  }
}
