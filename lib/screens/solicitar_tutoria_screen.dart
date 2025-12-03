import 'package:flutter/material.dart';
import '../models/estudante.dart';
import '../models/tutor.dart';
import '../models/area_conhecimento.dart';
import '../services/tutor_service.dart';
import '../services/agendamento_service.dart';
import '../services/area_conhecimento_service.dart';
import '../services/notificacao_service.dart';
import '../enums/status.dart';
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

      // Enviar notificação ao tutor
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
    return Scaffold(
      backgroundColor: const Color(0xFF0A1A46),
      appBar: AppBar(
        title: const Text('Solicitar Tutoria'),
        backgroundColor: const Color(0xFF0056A6),
        foregroundColor: Colors.white,
      ),
      body: _carregando
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Card principal
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Seleção de Tutor
                          const Text(
                            'Selecione o Tutor',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF0056A6),
                            ),
                          ),
                          const SizedBox(height: 10),
                          DropdownButtonFormField<Tutor>(
                            value: _tutorSelecionado,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Color(0xFF0056A6),
                                  width: 2,
                                ),
                              ),
                            ),
                            items: _tutores.map((tutor) {
                              return DropdownMenuItem(
                                value: tutor,
                                child: Text(tutor.nome),
                              );
                            }).toList(),
                            onChanged: (tutor) {
                              setState(() => _tutorSelecionado = tutor);
                            },
                          ),
                          const SizedBox(height: 20),

                          // Seleção de Área
                          const Text(
                            'Área de Conhecimento',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF0056A6),
                            ),
                          ),
                          const SizedBox(height: 10),
                          DropdownButtonFormField<AreaConhecimento>(
                            value: _areaSelecionada,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Color(0xFF0056A6),
                                  width: 2,
                                ),
                              ),
                            ),
                            items: _areas.map((area) {
                              return DropdownMenuItem(
                                value: area,
                                child: Text(area.nome),
                              );
                            }).toList(),
                            onChanged: (area) {
                              setState(() => _areaSelecionada = area);
                            },
                          ),
                          const SizedBox(height: 20),

                          // Seleção de Data
                          const Text(
                            'Data',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF0056A6),
                            ),
                          ),
                          const SizedBox(height: 10),
                          InkWell(
                            onTap: () async {
                              final data = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime.now(),
                                lastDate: DateTime.now().add(const Duration(days: 365)),
                              );
                              if (data != null) {
                                setState(() => _dataSelecionada = data);
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.calendar_today, color: Color(0xFF0056A6)),
                                  const SizedBox(width: 10),
                                  Text(
                                    _dataSelecionada == null
                                        ? 'Selecione a data'
                                        : DateFormat('dd/MM/yyyy').format(_dataSelecionada!),
                                    style: TextStyle(
                                      color: _dataSelecionada == null
                                          ? Colors.grey
                                          : Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Seleção de Hora
                          const Text(
                            'Hora',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF0056A6),
                            ),
                          ),
                          const SizedBox(height: 10),
                          InkWell(
                            onTap: () async {
                              final hora = await showTimePicker(
                                context: context,
                                initialTime: TimeOfDay.now(),
                              );
                              if (hora != null) {
                                setState(() => _horaSelecionada = hora);
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.access_time, color: Color(0xFF0056A6)),
                                  const SizedBox(width: 10),
                                  Text(
                                    _horaSelecionada == null
                                        ? 'Selecione a hora'
                                        : _horaSelecionada!.format(context),
                                    style: TextStyle(
                                      color: _horaSelecionada == null
                                          ? Colors.grey
                                          : Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Motivo
                          const Text(
                            'Motivo da Solicitação',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF0056A6),
                            ),
                          ),
                          const SizedBox(height: 10),
                          TextField(
                            controller: _motivoController,
                            maxLines: 4,
                            decoration: InputDecoration(
                              hintText: 'Descreva o motivo da solicitação',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Color(0xFF0056A6),
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 30),

                          // Botão Solicitar
                          SizedBox(
                            height: 50,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF0056A6),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: _isLoading ? null : _solicitarTutoria,
                              child: _isLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                      ),
                                    )
                                  : const Text(
                                      'Solicitar Tutoria',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}


