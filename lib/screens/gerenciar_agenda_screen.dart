import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/tutor.dart';
import '../models/disponibilidade.dart';
import '../services/tutor_service.dart';

class GerenciarAgendaScreen extends StatefulWidget {
  final Tutor tutor;

  const GerenciarAgendaScreen({super.key, required this.tutor});

  @override
  State<GerenciarAgendaScreen> createState() => _GerenciarAgendaScreenState();
}

class _GerenciarAgendaScreenState extends State<GerenciarAgendaScreen> {
  late List<Disponibilidade> _disponibilidades;
  bool _carregando = true;

  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  List<Disponibilidade> _slotsDoDiaSelecionado = [];

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _carregarDisponibilidades();
  }

  Future<void> _carregarDisponibilidades() async {
    if (!mounted) return;
    setState(() => _carregando = true);
    try {
      final tutorAtualizado = await TutorService.instance.getTutorCompleto(widget.tutor.id);
      if (!mounted) return;
      setState(() {
        _disponibilidades = tutorAtualizado.disponibilidades;
        _carregando = false;
      });
      _atualizarSlotsParaDia(_selectedDay!);
    } catch (e) {
      if (!mounted) return;
      setState(() => _carregando = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao carregar agenda: $e')));
    }
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
        _atualizarSlotsParaDia(selectedDay);
      });
    }
  }

  void _atualizarSlotsParaDia(DateTime dia) {
    final slots = _disponibilidades.where((d) => isSameDay(d.dataHora, dia)).toList();
    slots.sort((a, b) => a.dataHora.compareTo(b.dataHora));
    if(mounted) setState(() => _slotsDoDiaSelecionado = slots);
  }

  Future<void> _adicionarSlot() async {
    final TimeOfDay? horaSelecionada = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      helpText: 'Selecione o horário para o slot',
    );

    if (horaSelecionada != null && _selectedDay != null) {
      final dataHora = DateTime(_selectedDay!.year, _selectedDay!.month, _selectedDay!.day, horaSelecionada.hour, horaSelecionada.minute);
      if (_disponibilidades.any((d) => d.dataHora.isAtSameMomentAs(dataHora))) {
        if(mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Este horário já foi cadastrado.')));
        return;
      }
      if(mounted) setState(() => _carregando = true);
      try {
        await TutorService.instance.cadastrarDisponibilidade(tutorId: widget.tutor.id, dataHora: dataHora);
        await _carregarDisponibilidades();
      } catch (e) {
        if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao adicionar horário: $e')));
      } finally {
        if(mounted) setState(() => _carregando = false);
      }
    }
  }

  Future<void> _removerSlot(String disponibilidadeId) async {
    if(mounted) setState(() => _carregando = true);
      try {
        await TutorService.instance.removerDisponibilidade(disponibilidadeId);
        await _carregarDisponibilidades();
      } catch (e) {
        if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao remover horário: $e')));
      } finally {
        if(mounted) setState(() => _carregando = false);
      }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Gerenciar Agenda', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Stack(
        children: [
          Image.asset('assets/background_home.jpg', fit: BoxFit.cover, width: double.infinity, height: double.infinity),
          if (_carregando) 
            const Center(child: CircularProgressIndicator(color: Colors.white))
          else 
            SafeArea(
              child: Column(
                children: [
                  _buildCalendar(),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Divider(color: Colors.white30),
                  ),
                  Expanded(child: _buildListaDeSlots()),
                ],
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _adicionarSlot,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Adicionar Horário', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white.withOpacity(0.25),
        elevation: 0,
      ),
    );
  }

  Widget _buildCalendar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.white.withOpacity(0.3)),
            ),
            child: TableCalendar(
              locale: 'pt_BR',
              firstDay: DateTime.utc(_focusedDay.year, _focusedDay.month, 1),
              lastDay: DateTime.utc(_focusedDay.year + 1, 12, 31),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onDaySelected: _onDaySelected,
              eventLoader: (day) => _disponibilidades.where((d) => isSameDay(d.dataHora, day)).toList(),
              calendarStyle: CalendarStyle(
                defaultTextStyle: const TextStyle(color: Colors.white),
                weekendTextStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                outsideTextStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
                todayDecoration: BoxDecoration(color: Colors.orange.withOpacity(0.5), shape: BoxShape.circle),
                selectedDecoration: const BoxDecoration(color: Colors.orange, shape: BoxShape.circle),
                markerDecoration: BoxDecoration(color: Colors.lightBlue.shade200, shape: BoxShape.circle),
              ),
              headerStyle: HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                titleTextStyle: const TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                leftChevronIcon: const Icon(Icons.chevron_left, color: Colors.white),
                rightChevronIcon: const Icon(Icons.chevron_right, color: Colors.white),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildListaDeSlots() {
    if (_slotsDoDiaSelecionado.isEmpty) {
      return const Center(child: Text('Nenhum horário cadastrado para este dia.', style: TextStyle(color: Colors.white70)));
    }
    
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
      itemCount: _slotsDoDiaSelecionado.length,
      itemBuilder: (context, index) {
        final slot = _slotsDoDiaSelecionado[index];
        final formatadorHora = DateFormat.Hm('pt_BR');
        return Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
              child: Container(
                decoration: BoxDecoration(
                  color: slot.agendado ? Colors.black.withOpacity(0.3) : Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                ),
                child: ListTile(
                  leading: Icon(slot.agendado ? Icons.lock_clock_rounded : Icons.check_circle_outline_rounded, color: slot.agendado ? Colors.white70 : Colors.greenAccent),
                  title: Text(formatadorHora.format(slot.dataHora), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 18)),
                  subtitle: Text(slot.agendado ? 'Reservado' : 'Livre', style: TextStyle(color: Colors.white.withOpacity(0.8))),
                  trailing: slot.agendado
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                        onPressed: () => _removerSlot(slot.id),
                      ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  bool isSameDay(DateTime? a, DateTime? b) {
    if (a == null || b == null) return false;
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
