import 'package:flutter/material.dart';
import '../models/tutor.dart';
import '../models/area_conhecimento.dart';
import '../services/area_conhecimento_service.dart';
import '../services/tutor_service.dart';

class AreasTutorScreen extends StatefulWidget {
  final Tutor tutor;

  const AreasTutorScreen({super.key, required this.tutor});

  @override
  State<AreasTutorScreen> createState() => _AreasTutorScreenState();
}

class _AreasTutorScreenState extends State<AreasTutorScreen> {
  late Future<List<AreaConhecimento>> _todasAreasFuture;
  Set<String> _areasTutorIds = {};
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _carregarAreas();
  }

  void _carregarAreas() {
    setState(() => _carregando = true);
    _todasAreasFuture = AreaConhecimentoService.instance.listarTodasAreas();
    _getAreasDoTutor();
  }

  Future<void> _getAreasDoTutor() async {
    final tutorCompleto = await TutorService.instance.getTutorCompleto(widget.tutor.id);
    if (mounted) {
      setState(() {
        _areasTutorIds = tutorCompleto.areasConhecimento.map((a) => a.id).toSet();
        _carregando = false;
      });
    }
  }

  Future<void> _toggleArea(String areaId) async {
    final bool contem = _areasTutorIds.contains(areaId);
    try {
      if (contem) {
        await TutorService.instance.removerAreaConhecimento(widget.tutor.id, areaId);
      } else {
        await TutorService.instance.adicionarAreaConhecimento(widget.tutor.id, areaId);
      }
      if (mounted) {
        setState(() {
          if (contem) {
            _areasTutorIds.remove(areaId);
          } else {
            _areasTutorIds.add(areaId);
          }
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Área atualizada com sucesso!'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao atualizar área: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A1A46),
      appBar: AppBar(
        title: const Text('Minhas Áreas', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: FutureBuilder<List<AreaConhecimento>>(
        future: _todasAreasFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting || _carregando) {
            return const Center(child: CircularProgressIndicator(color: Colors.white));
          }
          if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}', style: const TextStyle(color: Colors.white)));
          }
          final todasAreas = snapshot.data;
          if (todasAreas == null || todasAreas.isEmpty) {
            return const Center(child: Text('Nenhuma área de conhecimento disponível.', style: TextStyle(color: Colors.white70)));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: todasAreas.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final area = todasAreas[index];
              final selecionada = _areasTutorIds.contains(area.id);
              return _buildAreaCard(area, selecionada);
            },
          );
        },
      ),
    );
  }

  Widget _buildAreaCard(AreaConhecimento area, bool selecionada) {
    return Container(
        decoration: BoxDecoration(
          color: selecionada ? Colors.white.withOpacity(0.25) : Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: selecionada ? Colors.cyanAccent : Colors.white.withOpacity(0.2)),
        ),
        child: ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        title: Text(area.nome, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16)),
        subtitle: Text(area.descricao, style: const TextStyle(color: Colors.white70, height: 1.3)),
        trailing: Icon(
          selecionada ? Icons.check_circle : Icons.radio_button_unchecked,
          color: selecionada ? Colors.cyanAccent : Colors.white60,
          size: 28,
        ),
        onTap: () => _toggleArea(area.id),
      ),
    );
  }
}
