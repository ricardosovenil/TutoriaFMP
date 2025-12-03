import 'package:flutter/material.dart';
import 'package:open_file_plus/open_file_plus.dart';
import '../models/tutor.dart';
import '../services/tutor_service.dart';

class GerenciarTutoresScreen extends StatefulWidget {
  const GerenciarTutoresScreen({super.key});

  @override
  State<GerenciarTutoresScreen> createState() => _GerenciarTutoresScreenState();
}

class _GerenciarTutoresScreenState extends State<GerenciarTutoresScreen> {
  late Future<List<Tutor>> _tutoresFuture;

  @override
  void initState() {
    super.initState();
    _carregarTutores();
  }

  void _carregarTutores() {
    _tutoresFuture = TutorService.instance.listarTutores().then((tutores) {
      tutores.sort((a, b) => a.aprovado.compareTo(b.aprovado));
      return tutores;
    });
  }

  Future<void> _aprovarTutor(String tutorId) async {
    try {
      await TutorService.instance.aprovarTutor(tutorId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tutor aprovado com sucesso!'), backgroundColor: Colors.green));
        setState(() => _carregarTutores());
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao aprovar tutor: $e'), backgroundColor: Colors.red));
    }
  }

  Future<void> _excluirTutor(String tutorId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: const Text('Tem certeza de que deseja excluir este tutor? Esta ação é permanente.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Excluir', style: TextStyle(color: Colors.red))),
        ],
      ),
    ) ?? false;

    if (confirm) {
      try {
        await TutorService.instance.excluirTutor(tutorId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tutor excluído com sucesso!'), backgroundColor: Colors.green));
          setState(() => _carregarTutores());
        }
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao excluir tutor: $e'), backgroundColor: Colors.red));
      }
    }
  }

  Future<void> _visualizarCurriculo(String filePath) async {
    final result = await OpenFile.open(filePath);
    if (result.type != ResultType.done && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Não foi possível abrir o arquivo: ${result.message}')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A1A46),
      appBar: AppBar(
        title: const Text('Gerenciar Tutores', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: FutureBuilder<List<Tutor>>(
        future: _tutoresFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.white));
          }
          if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}', style: const TextStyle(color: Colors.white)));
          }
          final tutores = snapshot.data;
          if (tutores == null || tutores.isEmpty) {
            return _buildEmptyState();
          }
          return RefreshIndicator(
            onRefresh: () async => setState(() => _carregarTutores()),
            child: ListView.separated(
              padding: const EdgeInsets.all(16.0),
              itemCount: tutores.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) => _buildTutorCard(tutores[index]),
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 80, color: Colors.white70),
          SizedBox(height: 20),
          Text('Nenhum Tutor Cadastrado', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
          SizedBox(height: 8),
          Text('Os tutores pendentes e aprovados aparecerão aqui.', textAlign: TextAlign.center, style: TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }

  Widget _buildTutorCard(Tutor tutor) {
    final isPendente = tutor.aprovado == 0;
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(tutor.nome, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white), overflow: TextOverflow.ellipsis)),
              Chip(
                label: Text(isPendente ? 'Pendente' : 'Aprovado', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                backgroundColor: isPendente ? Colors.orange.shade400 : Colors.green.shade400,
                padding: const EdgeInsets.symmetric(horizontal: 8),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(tutor.email, style: const TextStyle(color: Colors.white70)),
          const Divider(height: 24, color: Colors.white30),
          OutlinedButton.icon(
            icon: const Icon(Icons.picture_as_pdf_rounded, size: 18, color: Colors.white),
            label: const Text('Visualizar Currículo', style: TextStyle(color: Colors.white)),
            style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.white70)),
            onPressed: tutor.curriculo.isNotEmpty ? () => _visualizarCurriculo(tutor.curriculo) : null,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              if (isPendente)
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.check, color: Colors.white),
                    label: const Text('Aprovar', style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green, padding: const EdgeInsets.symmetric(vertical: 12)),
                    onPressed: () => _aprovarTutor(tutor.id),
                  ),
                ),
              if (isPendente) const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.delete_outline, color: Colors.white),
                  label: const Text('Excluir', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red, padding: const EdgeInsets.symmetric(vertical: 12)),
                  onPressed: () => _excluirTutor(tutor.id),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
