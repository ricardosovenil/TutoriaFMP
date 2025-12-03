import 'package:flutter/material.dart';
import '../models/estudante.dart';
import '../models/area_conhecimento.dart';
import '../services/area_conhecimento_service.dart';
import 'quadro_horarios_screen.dart';

class BuscarPorAreaScreen extends StatefulWidget {
  final Estudante estudante;

  const BuscarPorAreaScreen({super.key, required this.estudante});

  @override
  State<BuscarPorAreaScreen> createState() => _BuscarPorAreaScreenState();
}

class _BuscarPorAreaScreenState extends State<BuscarPorAreaScreen> {
  bool _carregando = true;
  List<AreaConhecimento> _areas = [];

  @override
  void initState() {
    super.initState();
    _carregarAreas();
  }

  Future<void> _carregarAreas() async {
    setState(() => _carregando = true);
    try {
      final areas = await AreaConhecimentoService.instance.listarTodasAreas();
      setState(() {
        _areas = areas;
        _carregando = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao carregar áreas: $e')));
        setState(() => _carregando = false);
      }
    }
  }

  void _navegarParaTutoresDaArea(AreaConhecimento area) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => QuadroHorariosScreen(
          estudante: widget.estudante,
          areaFiltroInicial: area, // Passa a área selecionada como filtro inicial
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: AppBar(
        title: const Text('Escolha a Área de Conhecimento', style: TextStyle(color: Colors.black87)),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: _carregando
          ? const Center(child: CircularProgressIndicator())
          : _areas.isEmpty
              ? const Center(child: Text('Nenhuma área de conhecimento cadastrada.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _areas.length,
                  itemBuilder: (context, index) {
                    final area = _areas[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                        title: Text(area.nome, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0056A6))),
                        subtitle: Text(area.descricao, style: const TextStyle(color: Colors.black54)),
                        trailing: const Icon(Icons.arrow_forward_ios, color: Colors.grey),
                        onTap: () => _navegarParaTutoresDaArea(area),
                      ),
                    );
                  },
                ),
    );
  }
}
