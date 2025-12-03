import 'package:flutter/material.dart';
import '../models/tutor.dart';
import '../models/disponibilidade.dart';
import '../enums/dia_da_semana.dart';
import '../services/tutor_service.dart';
import 'package:intl/intl.dart';

class DisponibilidadeTutorScreen extends StatefulWidget {
  final Tutor tutor;

  const DisponibilidadeTutorScreen({super.key, required this.tutor});

  @override
  State<DisponibilidadeTutorScreen> createState() => _DisponibilidadeTutorScreenState();
}

class _DisponibilidadeTutorScreenState extends State<DisponibilidadeTutorScreen> {
  late List<Disponibilidade> _disponibilidades;
  bool _carregando = false;

  @override
  void initState() {
    super.initState();
    _disponibilidades = List.from(widget.tutor.disponibilidades);
  }

  void _adicionarSlot() {
    DiaDaSemana? diaSelecionado;
    TimeOfDay? horaInicio;
    TimeOfDay? horaFim;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (BuildContext context, StateSetter setModalState) {
          return Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, left: 20, right: 20, top: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('Adicionar Novo Horário', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                DropdownButtonFormField<DiaDaSemana>(
                  value: diaSelecionado,
                  hint: const Text('Selecione o dia'),
                  items: DiaDaSemana.values.map((d) => DropdownMenuItem(value: d, child: Text(d.displayName))).toList(),
                  onChanged: (val) => setModalState(() => diaSelecionado = val),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.timer_outlined),
                        label: Text(horaInicio?.format(context) ?? 'Início'),
                        onPressed: () async {
                          final time = await showTimePicker(context: ctx, initialTime: TimeOfDay.now());
                          if (time != null) setModalState(() => horaInicio = time);
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.timer_off_outlined),
                        label: Text(horaFim?.format(context) ?? 'Fim'),
                        onPressed: () async {
                          final time = await showTimePicker(context: ctx, initialTime: TimeOfDay.now());
                          if (time != null) setModalState(() => horaFim = time);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  child: const Text('Salvar Horário'),
                  onPressed: () async {
                    if (diaSelecionado != null && horaInicio != null && horaFim != null) {
                      if (horaFim!.hour < horaInicio!.hour || (horaFim!.hour == horaInicio!.hour && horaFim!.minute <= horaInicio!.minute)) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('A hora final deve ser após a hora inicial.')));
                        return;
                      }

                      setState(() => _carregando = true);
                      Navigator.of(ctx).pop(); // Fecha o bottom sheet

                      try {
                        await TutorService.instance.cadastrarDisponibilidade(
                          tutorId: widget.tutor.id,
                          dia: diaSelecionado!,
                          horaInicio: horaInicio!,
                          horaFim: horaFim!,
                        );
                        // Recarrega o tutor para obter a lista atualizada
                        final tutorAtualizado = await TutorService.instance.getTutorCompleto(widget.tutor.id);
                        setState(() {
                          _disponibilidades = tutorAtualizado.disponibilidades;
                          widget.tutor.disponibilidades = tutorAtualizado.disponibilidades;
                        });
                      } catch (e) {
                        if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao salvar: $e')));
                      } finally {
                        if(mounted) setState(() => _carregando = false);
                      }
                    }
                  },
                ),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _removerSlot(String disponibilidadeId) async {
    setState(() => _carregando = true);
    try {
      await TutorService.instance.removerDisponibilidade(disponibilidadeId);
      setState(() {
        _disponibilidades.removeWhere((d) => d.id == disponibilidadeId);
      });
    } catch (e) {
      if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao remover: $e')));
    } finally {
      if(mounted) setState(() => _carregando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meus Horários'),
        actions: [IconButton(icon: const Icon(Icons.add), onPressed: _adicionarSlot)],
      ),
      body: _carregando
          ? const Center(child: CircularProgressIndicator())
          : _disponibilidades.isEmpty
              ? const Center(child: Text('Nenhum horário cadastrado.'))
              : ListView.builder(
                  itemCount: _disponibilidades.length,
                  itemBuilder: (context, index) {
                    final slot = _disponibilidades[index];
                    return ListTile(
                      title: Text('${slot.diaDaSemana.displayName}'),
                      subtitle: Text('Das ${slot.horaInicio.format(context)} às ${slot.horaFim.format(context)}'),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                        onPressed: () => _removerSlot(slot.id),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _adicionarSlot,
        child: const Icon(Icons.add),
        tooltip: 'Adicionar Horário',
      ),
    );
  }
}
