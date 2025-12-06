import 'package:flutter/material.dart';
import '../models/estudante.dart';
import '../models/tutor.dart';
import '../models/area_conhecimento.dart';
import '../services/tutor_service.dart';
import '../services/agendamento_service.dart';
import '../services/area_conhecimento_service.dart';
import '../services/notificacao_service.dart';
import '../widgets/tutor_card.dart'; // Importa o novo TutorCard
import 'package:intl/intl.dart';

class SolicitarTutoriaScreen extends StatefulWidget {
  final Estudante estudante;

  const SolicitarTutoriaScreen({super.key, required this.estudante});

  @override
  State<SolicitarTutoriaScreen> createState() => _SolicitarTutoriaScreenState();
}

class _SolicitarTutoriaScreenState extends State<SolicitarTutoriaScreen> {
  List<Tutor> _tutores = [];
  List<AreaConhecimento> _areas = [];
  Tutor? _tutorSelecionado;
  AreaConhecimento? _areaSelecionada;
  DateTime? _dataSelecionada;
  TimeOfDay? _horaSelecionada;
  final _motivoController = TextEditingController();
  bool _isLoading = false;
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  @override
  void dispose() {
    _motivoController.dispose();
    super.dispose();
  }

  Future<void> _carregarDados() async {
    setState(() => _carregando = true);
    try {
      final tutores = await TutorService.instance.listarTutores(aprovado: true);
      final areas = await AreaConhecimentoService.instance.listarTodas();
      setState(() {
        _tutores = tutores;
        _areas = areas;
        _carregando = false;
      });
    } catch (e) {
      setState(() => _carregando = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar dados: $e')),
        );
      }
    }
  }

  Future<void> _solicitarTutoria() async {
    if (_tutorSelecionado == null || _areaSelecionada == null || 
        _dataSelecionada == null || _horaSelecionada == null ||
        _motivoController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha todos os campos')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final hora = DateTime(
        _dataSelecionada!.year,
        _dataSelecionada!.month,
        _dataSelecionada!.day,
        _horaSelecionada!.hour,
        _horaSelecionada!.minute,
      );

      await AgendamentoService.instance.criarAgendamento(
        tutorId: _tutorSelecionado!.id,
        estudanteId: widget.estudante.id,
        areaId: _areaSelecionada!.id,
        data: _dataSelecionada!,
        hora: hora,
        motivoSolicitacao: _motivoController.text,
      );

      await NotificacaoService.instance.enviarNotificacao(
        destinatarioId: _tutorSelecionado!.id,
        titulo: 'Nova Solicitação de Tutoria',
        mensagem: '${widget.estudante.nome} solicitou uma tutoria em ${_areaSelecionada!.nome}',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Solicitação enviada com sucesso!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao solicitar tutoria: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Solicitar Tutoria'),
      ),
      body: _carregando
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Selecione o Tutor',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 10),
                    // NOVO: GridView de Tutores
                    SizedBox(
                      height: 220, // Altura definida para a grade
                      child: GridView.builder(
                        scrollDirection: Axis.horizontal,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 1, // 1 linha
                          childAspectRatio: 1.2, // Proporção do card
                          mainAxisSpacing: 10,
                        ),
                        itemCount: _tutores.length,
                        itemBuilder: (context, index) {
                          final tutor = _tutores[index];
                          return TutorCard(
                            tutor: tutor,
                            isSelected: _tutorSelecionado?.id == tutor.id,
                            onTap: () => setState(() => _tutorSelecionado = tutor),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Text(
                              'Detalhes do Agendamento',
                               style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const Divider(height: 20),
                            // Seleção de Área
                            DropdownButtonFormField<AreaConhecimento>(
                              value: _areaSelecionada,
                              decoration: const InputDecoration(labelText: 'Área de Conhecimento'),
                              items: _areas.map((area) => DropdownMenuItem(value: area, child: Text(area.nome))).toList(),
                              onChanged: (area) => setState(() => _areaSelecionada = area),
                            ),
                            const SizedBox(height: 20),
                            // Seleção de Data e Hora
                            Row(
                              children: [
                                Expanded(
                                  child: InkWell(
                                    onTap: () async {
                                      final data = await showDatePicker(
                                        context: context,
                                        initialDate: DateTime.now(),
                                        firstDate: DateTime.now(),
                                        lastDate: DateTime.now().add(const Duration(days: 365)),
                                      );
                                      if (data != null) setState(() => _dataSelecionada = data);
                                    },
                                    child: InputDecorator(
                                      decoration: const InputDecoration(labelText: 'Data'),
                                      child: Text(_dataSelecionada != null ? DateFormat('dd/MM/yyyy').format(_dataSelecionada!) : 'Selecione'),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: InkWell(
                                    onTap: () async {
                                      final hora = await showTimePicker(context: context, initialTime: TimeOfDay.now());
                                      if (hora != null) setState(() => _horaSelecionada = hora);
                                    },
                                    child: InputDecorator(
                                      decoration: const InputDecoration(labelText: 'Hora'),
                                      child: Text(_horaSelecionada != null ? _horaSelecionada!.format(context) : 'Selecione'),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            // Motivo
                            TextField(
                              controller: _motivoController,
                              maxLines: 4,
                              decoration: const InputDecoration(labelText: 'Motivo da Solicitação', hintText: 'Descreva o motivo da solicitação'),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    // Botão Solicitar
                    ElevatedButton(
                      onPressed: _isLoading ? null : _solicitarTutoria,
                      child: _isLoading
                          ? const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white))
                          : const Text('Solicitar Tutoria'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
