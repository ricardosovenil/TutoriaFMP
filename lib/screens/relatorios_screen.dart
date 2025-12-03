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
      backgroundColor: const Color(0xFF0A1A46),
      appBar: AppBar(
        title: const Text('Relatórios', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: RefreshIndicator(
        onRefresh: () async => setState(() => _carregarDados()),
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            _buildResumoCard(),
            const SizedBox(height: 24),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: Text('Relatório por Tutor', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white70)),
            ),
            const SizedBox(height: 10),
            _buildListaTutores(),
          ],
        ),
      ),
    );
  }

  Widget _buildResumoCard() {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          const Text('Total de Estudantes Ativos', style: TextStyle(fontSize: 16, color: Colors.white70)),
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
          const Text('(que já agendaram pelo menos uma tutoria)', style: TextStyle(fontSize: 12, color: Colors.white60), textAlign: TextAlign.center),
        ],
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
          return const Center(child: Text('Nenhum tutor cadastrado.', style: TextStyle(color: Colors.white70)));
        }

        final tutores = snapshot.data!;
        return Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(15),
          ),
          clipBehavior: Clip.antiAlias,
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: tutores.length,
            separatorBuilder: (context, index) => const Divider(height: 1, color: Colors.white24, indent: 16, endIndent: 16),
            itemBuilder: (context, index) {
              final tutor = tutores[index];
              return ListTile(
                title: Text(tutor.nome, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                subtitle: Text(tutor.email, style: const TextStyle(color: Colors.white70)),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.white70),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => RelatorioTutorDetalheScreen(tutor: tutor)),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}
