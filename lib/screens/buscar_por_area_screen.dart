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
      appBar: AppBar(title: const Text('Escolha a Área de Conhecimento')),
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
                      margin: const EdgeInsets.only(bottom: 16),
                      child: ListTile(
                        title: Text(area.nome, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(area.descricao),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () => _navegarParaTutoresDaArea(area),
                      ),
                    );
                  },
                ),
    );
  }
}
