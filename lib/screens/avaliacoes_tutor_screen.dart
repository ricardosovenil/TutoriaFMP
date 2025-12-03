import 'dart:ui';
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
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Minhas Avaliações', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Stack(
        children: [
          Image.asset(
            'assets/background_home.jpg',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          SafeArea(
            child: FutureBuilder<List<Avaliacao>>(
              future: _avaliacoesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: Colors.white));
                }

                if (snapshot.hasError) {
                  final errorTextStyle = TextStyle(color: Colors.white, fontSize: 16);
                  return Center(child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text(
                      'Ocorreu um erro ao carregar as avaliações. Por favor, tente novamente mais tarde.\n\nDetalhe: ${snapshot.error}',
                      style: errorTextStyle,
                      textAlign: TextAlign.center,
                    ),
                  ));
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
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.3))
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.star_border_purple500_outlined, size: 60, color: Colors.white70),
                const SizedBox(height: 20),
                const Text('Nenhuma Avaliação Recebida', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 8),
                Text('Suas avaliações aparecerão aqui.', textAlign: TextAlign.center, style: TextStyle(color: Colors.white.withOpacity(0.7))),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvaliacaoCard(Avaliacao avaliacao) {
    final studentName = avaliacao.estudanteNome ?? 'Aluno anônimo';
    final initial = studentName.isNotEmpty ? studentName[0].toUpperCase() : '?';
    final formattedDate = '${avaliacao.dataAvaliacao.day.toString().padLeft(2, '0')}/${avaliacao.dataAvaliacao.month.toString().padLeft(2, '0')}/${avaliacao.dataAvaliacao.year}';

    return ClipRRect(
      borderRadius: BorderRadius.circular(15),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.white.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: Colors.white.withOpacity(0.8),
                    // CORREÇÃO DA CAUSA RAIZ: Substituído Colors.blue.shade900 por seu valor literal constante.
                    child: Text(initial, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0D47A1))),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(studentName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                        const SizedBox(height: 2),
                        Text(formattedDate, style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12)),
                      ],
                    ),
                  ),
                  _buildStarRating(avaliacao.nota),
                ],
              ),
              const Divider(height: 24, thickness: 0.5, color: Colors.white30),
              Text(avaliacao.comentario, style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 14, height: 1.4)),
            ],
          ),
        ),
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
