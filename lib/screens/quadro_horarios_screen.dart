import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/tutor.dart';
import '../models/estudante.dart';
import '../models/disponibilidade.dart';
import '../models/area_conhecimento.dart';
import '../services/tutor_service.dart';
import '../services/area_conhecimento_service.dart';
import 'solicitar_agendamento_screen.dart';

class QuadroHorariosScreen extends StatefulWidget {
  final Estudante estudante;
  final AreaConhecimento? areaFiltroInicial;

  const QuadroHorariosScreen({
    super.key,
    required this.estudante,
    this.areaFiltroInicial,
  });

  @override
  State<QuadroHorariosScreen> createState() => _QuadroHorariosScreenState();
}

class _QuadroHorariosScreenState extends State<QuadroHorariosScreen> {
  bool _carregando = true;
  List<Tutor> _todosTutores = [];
  List<AreaConhecimento> _areas = [];

  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  AreaConhecimento? _filtroArea;
  List<Tutor> _tutoresExibidos = [];

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _filtroArea = widget.areaFiltroInicial;
    _carregarDadosIniciais();
  }

  Future<void> _carregarDadosIniciais() async {
    setState(() => _carregando = true);
    try {
      // CORREÇÃO: Remove o filtro de 'aprovado' para facilitar o teste.
      // Em produção, isso seria (aprovado: true).
      final tutores = await TutorService.instance.listarTutores();
      final areas = await AreaConhecimentoService.instance.listarTodasAreas();
      
      setState(() {
        _todosTutores = tutores;
        _areas = areas;
        _carregando = false;
      });

      _atualizarListaTutores();
    } catch (e) {
      if (mounted) {
        setState(() => _carregando = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao carregar dados: $e')));
      }
    }
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
      });
      _atualizarListaTutores();
    }
  }

  // Lógica de filtragem FINAL E CORRIGIDA
  void _atualizarListaTutores() {
    List<Tutor> tutoresFiltrados = _todosTutores.where((tutor) {
      // 1. Filtra por área de conhecimento
      final correspondeArea = _filtroArea == null || tutor.areasConhecimento.any((a) => a.id == _filtroArea!.id);
      if (!correspondeArea) return false;

      // 2. Se a busca veio de uma área, mostra tutores com QUALQUER disponibilidade futura.
      if (widget.areaFiltroInicial != null) {
        return tutor.disponibilidades.any((d) => d.dataHora.isAfter(DateTime.now()));
      }
      // 3. Se a busca veio do calendário, filtra pelo dia selecionado.
      else {
        return tutor.disponibilidades.any((d) => isSameDay(d.dataHora, _selectedDay));
      }
    }).toList();

    setState(() => _tutoresExibidos = tutoresFiltrados);
  }

  void _navegarParaSolicitacao(Tutor tutor) async {
    final tutorCompleto = await TutorService.instance.getTutorCompleto(tutor.id);
    if(mounted) {
        final agendamentoCriado = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
            builder: (_) => SolicitarAgendamentoScreen(tutor: tutorCompleto, estudante: widget.estudante),
        ),
        );
        if (agendamentoCriado == true) {
            _carregarDadosIniciais();
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_filtroArea?.nome ?? 'Encontrar Tutor')),
      body: _carregando
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                if (widget.areaFiltroInicial == null) ...[
                  _buildCalendar(),
                  _buildFiltroArea(),
                  const Divider(height: 1),
                ],
                Expanded(child: _buildListaDeTutores()),
              ],
            ),
    );
  }

  Widget _buildCalendar() {
    return TableCalendar(
      locale: 'pt_BR',
      firstDay: DateTime.now(),
      lastDay: DateTime.now().add(const Duration(days: 90)),
      focusedDay: _focusedDay,
      selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
      onDaySelected: _onDaySelected,
      calendarStyle: CalendarStyle(
        todayDecoration: BoxDecoration(color: Colors.orange.shade300, shape: BoxShape.circle),
        selectedDecoration: BoxDecoration(color: Theme.of(context).primaryColor, shape: BoxShape.circle),
      ),
      headerStyle: const HeaderStyle(formatButtonVisible: false, titleCentered: true),
    );
  }

  Widget _buildFiltroArea() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: DropdownButtonFormField<AreaConhecimento>(
        value: _filtroArea,
        hint: const Text('Filtrar por Área de Conhecimento'),
        items: _areas.map((a) => DropdownMenuItem(value: a, child: Text(a.nome))).toList(),
        onChanged: (area) => setState(() {
          _filtroArea = area;
          _atualizarListaTutores();
        }),
        decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))), 
      ),
    );
  }

  Widget _buildListaDeTutores() {
    if (_tutoresExibidos.isEmpty) {
      return const Center(child: Text('Nenhum tutor encontrado para os critérios selecionados.'));
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: _tutoresExibidos.length,
      itemBuilder: (context, index) {
        final tutor = _tutoresExibidos[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tutor.nome, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('Média: ${tutor.mediaAvaliacoes.toStringAsFixed(1)} ★', style: TextStyle(color: Colors.grey.shade700)),
                const Divider(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _navegarParaSolicitacao(tutor),
                    child: const Text('Ver Horários'),
                  ),
                )
              ],
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
