import 'dart:ui';
import 'package:flutter/material.dart';
import '../models/tutor.dart';
import '../services/tutor_service.dart';
import '../services/relatorio_service.dart';
import 'relatorio_tutor_detalhe_screen.dart';

class RelatoriosScreen extends StatefulWidget {
  const RelatoriosScreen({super.key});

  @override
  State<RelatoriosScreen> createState() => _RelatoriosScreenState();
}

class _RelatoriosScreenState extends State<RelatoriosScreen> {
  late Future<int> _totalEstudantesFuture;
  late Future<List<Tutor>> _tutoresFuture;

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  void _carregarDados() {
    _totalEstudantesFuture = RelatorioService.instance.getTotalEstudantesComAgendamento();
    _tutoresFuture = TutorService.instance.listarTutores();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Relatórios', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Stack(
        children: [
          Image.asset('assets/background_home.jpg', fit: BoxFit.cover, width: double.infinity, height: double.infinity),
          SafeArea(
            child: RefreshIndicator(
              onRefresh: () async => setState(() => _carregarDados()),
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  _buildResumoCard(),
                  const SizedBox(height: 24),
                  const Text('Relatório por Tutor', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 10),
                  _buildListaTutores(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResumoCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          padding: const EdgeInsets.all(20.0),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.3)),
          ),
          child: Column(
            children: [
              Text('Total de Estudantes Ativos', style: TextStyle(fontSize: 16, color: Colors.white.withOpacity(0.8))),
              const SizedBox(height: 10),
              FutureBuilder<int>(
                future: _totalEstudantesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator(color: Colors.white);
                  }
                  if (snapshot.hasError) {
                    return const Text('Erro', style: TextStyle(color: Colors.redAccent, fontSize: 32, fontWeight: FontWeight.bold));
                  }
                  return Text(snapshot.data?.toString() ?? '0', style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white));
                },
              ),
              const SizedBox(height: 5),
              Text('(que já agendaram pelo menos uma tutoria)', style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.7)), textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildListaTutores() {
    return FutureBuilder<List<Tutor>>(
      future: _tutoresFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: Padding(padding: EdgeInsets.all(32.0), child: CircularProgressIndicator(color: Colors.white)));
        }
        if (snapshot.hasError) {
          return const Center(child: Text('Erro ao carregar tutores.', style: TextStyle(color: Colors.white)));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('Nenhum tutor cadastrado.', style: TextStyle(color: Colors.white)));
        }

        final tutores = snapshot.data!;
        return ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.3)),
                ),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: tutores.length,
                separatorBuilder: (context, index) => const Divider(color: Colors.white30, indent: 16, endIndent: 16),
                itemBuilder: (context, index) {
                  final tutor = tutores[index];
                  return ListTile(
                    title: Text(tutor.nome, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    subtitle: Text(tutor.email, style: TextStyle(color: Colors.white.withOpacity(0.8))),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.white),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => RelatorioTutorDetalheScreen(tutor: tutor)),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
