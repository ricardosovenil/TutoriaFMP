import 'dart:ui';
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
      backgroundColor: const Color(0xFFF0F4F8),
      extendBodyBehindAppBar: true, // Permite que o body fique atrás do AppBar
      appBar: AppBar(
        title: const Text('Painel do Coordenador', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Imagem de fundo
          Image.asset(
            'assets/background_home.jpg',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildHeader(context),
                const SizedBox(height: 24),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    "Ferramentas Administrativas",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 16),
                _buildDashboardGrid(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.white.withOpacity(0.2),
            border: Border.all(color: Colors.white.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              // LÓGICA DA FOTO DE PERFIL ATUALIZADA
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.white.withOpacity(0.8),
                // backgroundImage: coordenador.fotoPerfilPath != null
                //     ? FileImage(File(coordenador.fotoPerfilPath!))
                //     : null,
                child: coordenador.fotoPerfilPath == null
                    ? Text(
                        coordenador.nome.substring(0, 1),
                        style: const TextStyle(fontSize: 28, color: Color(0xFF0A1A46), fontWeight: FontWeight.bold),
                      )
                    : null,
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
        ),
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
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.25),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.4)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.9),
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
        ),
      ),
    );
  }
}
