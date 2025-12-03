import 'package:flutter/material.dart';
import '../models/tutor.dart';
import '../models/avaliacao.dart';
import '../services/avaliacao_service.dart';

class AvaliacoesTutorScreen extends StatefulWidget {
  final Tutor tutor;

  const AvaliacoesTutorScreen({super.key, required this.tutor});

  @override
  State<AvaliacoesTutorScreen> createState() => _AvaliacoesTutorScreenState();
}

class _AvaliacoesTutorScreenState extends State<AvaliacoesTutorScreen> {
  late Future<List<Avaliacao>> _avaliacoesFuture;

  @override
  void initState() {
    super.initState();
    _carregarAvaliacoes();
  }

  void _carregarAvaliacoes() {
    _avaliacoesFuture = AvaliacaoService.instance.listarPorTutor(widget.tutor.id);
  }

  Future<void> _handleRefresh() async {
    setState(() {
      _carregarAvaliacoes();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A1A46),
      appBar: AppBar(
        title: const Text('Minhas Avaliações', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: FutureBuilder<List<Avaliacao>>(
        future: _avaliacoesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.white));
          }

          if (snapshot.hasError) {
            return Center(child: Text('Erro ao carregar avaliações: ${snapshot.error}', style: const TextStyle(color: Colors.white)));
          }

          final avaliacoes = snapshot.data;

          if (avaliacoes == null || avaliacoes.isEmpty) {
            return _buildEmptyState();
          }

          return RefreshIndicator(
            onRefresh: _handleRefresh,
            child: ListView.separated(
              padding: const EdgeInsets.all(16.0),
              itemCount: avaliacoes.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final avaliacao = avaliacoes[index];
                return _buildAvaliacaoCard(avaliacao);
              },
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
          Icon(Icons.star_border_purple500_outlined, size: 80, color: Colors.white70),
          SizedBox(height: 20),
          Text('Nenhuma Avaliação Recebida', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
          SizedBox(height: 8),
          Text('Suas avaliações aparecerão aqui.', textAlign: TextAlign.center, style: TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }

  Widget _buildAvaliacaoCard(Avaliacao avaliacao) {
    final studentName = avaliacao.estudanteNome ?? 'Aluno anônimo';
    final initial = studentName.isNotEmpty ? studentName[0].toUpperCase() : '?';
    final formattedDate = '${avaliacao.dataAvaliacao.day.toString().padLeft(2, '0')}/${avaliacao.dataAvaliacao.month.toString().padLeft(2, '0')}/${avaliacao.dataAvaliacao.year}';

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
              CircleAvatar(
                radius: 22,
                backgroundColor: Colors.white,
                child: Text(initial, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0D47A1))),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(studentName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                    const SizedBox(height: 2),
                    Text(formattedDate, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                  ],
                ),
              ),
              _buildStarRating(avaliacao.nota),
            ],
          ),
          const Divider(height: 24, color: Colors.white30),
          Text(avaliacao.comentario, style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.4)),
        ],
      ),
    );
  }

  Widget _buildStarRating(double nota) {
    int starCount = (nota).round(); 
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return Icon(
          index < starCount ? Icons.star_rounded : Icons.star_border_rounded,
          color: Colors.amber.shade300,
          size: 20,
        );
      }),
    );
  }
}
