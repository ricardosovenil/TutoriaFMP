import 'dart:ui';
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

  @override
  void initState() {
    super.initState();
    _carregarAreas();
  }

  void _carregarAreas() {
    _todasAreasFuture = AreaConhecimentoService.instance.listarTodasAreas();
    // Carrega as áreas do tutor separadamente para não bloquear a UI
    _getAreasDoTutor();
  }

  Future<void> _getAreasDoTutor() async {
    final tutorCompleto = await TutorService.instance.getTutorCompleto(widget.tutor.id);
    if (mounted) {
      setState(() {
        _areasTutorIds = tutorCompleto.areasConhecimento.map((a) => a.id).toSet();
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
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Minhas Áreas', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Stack(
        children: [
          Image.asset('assets/background_home.jpg', fit: BoxFit.cover, width: double.infinity, height: double.infinity),
          SafeArea(
            child: FutureBuilder<List<AreaConhecimento>>(
              future: _todasAreasFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting && _areasTutorIds.isEmpty) {
                  return const Center(child: CircularProgressIndicator(color: Colors.white));
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Erro: ${snapshot.error}', style: const TextStyle(color: Colors.white)));
                }
                final todasAreas = snapshot.data;
                if (todasAreas == null || todasAreas.isEmpty) {
                  return const Center(child: Text('Nenhuma área de conhecimento disponível.', style: TextStyle(color: Colors.white)));
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
          ),
        ],
      ),
    );
  }

  Widget _buildAreaCard(AreaConhecimento area, bool selecionada) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(15),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          decoration: BoxDecoration(
            color: selecionada ? Colors.white.withOpacity(0.4) : Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: selecionada ? Colors.cyanAccent : Colors.white.withOpacity(0.3)),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            title: Text(area.nome, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16)),
            subtitle: Text(area.descricao, style: TextStyle(color: Colors.white.withOpacity(0.8), height: 1.3)),
            trailing: Icon(
              selecionada ? Icons.check_circle : Icons.radio_button_unchecked,
              color: selecionada ? Colors.cyanAccent : Colors.white60,
              size: 28,
            ),
            onTap: () => _toggleArea(area.id),
          ),
        ),
      ),
    );
  }
}
