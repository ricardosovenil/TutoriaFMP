import 'package:flutter/material.dart';
import '../models/coordenador.dart';
import 'gerenciar_tutores_screen.dart';
import 'relatorios_screen.dart';

class HomeCoordenadorScreen extends StatelessWidget {
  final Coordenador coordenador;

  const HomeCoordenadorScreen({super.key, required this.coordenador});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A1A46), // NOVO PADRÃO DE COR DE FUNDO
      appBar: AppBar(
        title: const Text('Painel do Coordenador', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildHeader(context),
          const SizedBox(height: 24),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              "Ferramentas Administrativas",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white70),
            ),
          ),
          const SizedBox(height: 16),
          _buildDashboardGrid(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Colors.white.withOpacity(0.1),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.white,
            child: Text(
              coordenador.nome.substring(0, 1),
              style: const TextStyle(fontSize: 28, color: Color(0xFF0A1A46), fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Bem-vindo(a), Coordenador!',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white70),
                ),
                Text(
                  coordenador.nome,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardGrid(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _buildDashboardItem(
          context: context,
          icon: Icons.people_alt_rounded,
          text: 'Gerenciar Tutores',
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const GerenciarTutoresScreen())),
          color: Colors.teal,
        ),
        _buildDashboardItem(
          context: context,
          icon: Icons.bar_chart_rounded,
          text: 'Relatórios',
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const RelatoriosScreen())),
          color: Colors.pink,
        ),
      ],
    );
  }

  Widget _buildDashboardItem({
    required BuildContext context,
    required IconData icon,
    required String text,
    required VoidCallback onTap,
    required Color color,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(100),
              ),
              child: Icon(icon, color: Colors.white, size: 28),
            ),
            const Spacer(),
            Text(
              text,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
