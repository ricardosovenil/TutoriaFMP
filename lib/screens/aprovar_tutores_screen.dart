import 'package:flutter/material.dart';
import 'package:open_file_plus/open_file_plus.dart';
import '../models/tutor.dart';
import '../services/tutor_service.dart';

class AprovarTutoresScreen extends StatefulWidget {
  const AprovarTutoresScreen({super.key});

  @override
  State<AprovarTutoresScreen> createState() => _AprovarTutoresScreenState();
}

class _AprovarTutoresScreenState extends State<AprovarTutoresScreen> {
  bool _carregando = true;
  List<Tutor> _tutoresPendentes = [];

  @override
  void initState() {
    super.initState();
    _carregarTutoresPendentes();
  }

  Future<void> _carregarTutoresPendentes() async {
    setState(() => _carregando = true);
    try {
      final tutores = await TutorService.instance.listarTutores(aprovado: false);
      setState(() {
        _tutoresPendentes = tutores;
        _carregando = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao carregar candidatos: $e')));
        setState(() => _carregando = false);
      }
    }
  }

  Future<void> _aprovarTutor(String tutorId) async {
    try {
      await TutorService.instance.aprovarTutor(tutorId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tutor aprovado com sucesso!')));
        setState(() => _tutoresPendentes.removeWhere((t) => t.id == tutorId));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao aprovar tutor: $e')));
    }
  }

  // NOVO: Método de exclusão com diálogo de confirmação
  Future<void> _excluirTutor(String tutorId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: const Text('Tem certeza de que deseja excluir este tutor? Esta ação não pode ser desfeita.'),
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
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tutor excluído com sucesso!')));
          setState(() => _tutoresPendentes.removeWhere((t) => t.id == tutorId));
        }
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao excluir tutor: $e')));
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
      appBar: AppBar(title: const Text('Aprovar Tutores')),
      body: _carregando
          ? const Center(child: CircularProgressIndicator())
          : _tutoresPendentes.isEmpty
              ? const Center(child: Text('Nenhum tutor pendente de aprovação.'))
              : RefreshIndicator(
                  onRefresh: _carregarTutoresPendentes,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _tutoresPendentes.length,
                    itemBuilder: (context, index) {
                      final tutor = _tutoresPendentes[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(tutor.nome, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              Text(tutor.email, style: const TextStyle(color: Colors.grey)),
                              const Divider(height: 24),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Currículo:', style: TextStyle(fontWeight: FontWeight.bold)),
                                  OutlinedButton.icon(
                                    icon: const Icon(Icons.picture_as_pdf_rounded, size: 18),
                                    label: const Text('Visualizar'),
                                    onPressed: tutor.curriculo.isNotEmpty ? () => _visualizarCurriculo(tutor.curriculo) : null,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              // --- BOTÕES DE AÇÃO ---
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      icon: const Icon(Icons.check_circle, color: Colors.white),
                                      label: const Text('Aprovar', style: TextStyle(color: Colors.white)),
                                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green, padding: const EdgeInsets.symmetric(vertical: 12)),
                                      onPressed: () => _aprovarTutor(tutor.id),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  // NOVO: Botão de Excluir
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      icon: const Icon(Icons.delete, color: Colors.white),
                                      label: const Text('Excluir', style: TextStyle(color: Colors.white)),
                                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red, padding: const EdgeInsets.symmetric(vertical: 12)),
                                      onPressed: () => _excluirTutor(tutor.id),
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
