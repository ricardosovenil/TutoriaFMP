import 'dart:ui';
import 'package:flutter/material.dart';
import '../models/tutor.dart';
import '../services/tutor_service.dart';
import 'gerenciar_agenda_screen.dart'; 
import 'agendamentos_tutor_screen.dart';
import 'avaliacoes_tutor_screen.dart';
import 'areas_tutor_screen.dart';
import 'solicitacoes_tutor_screen.dart';

class HomeTutorScreen extends StatefulWidget {
  final Tutor tutor;

  const HomeTutorScreen({super.key, required this.tutor});

  @override
  State<HomeTutorScreen> createState() => _HomeTutorScreenState();
}

class _HomeTutorScreenState extends State<HomeTutorScreen> {
  late Tutor _tutorCompleto;
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _tutorCompleto = widget.tutor;
    _carregarTutorCompleto();
  }

  Future<void> _carregarTutorCompleto() async {
    setState(() => _carregando = true);
    try {
      final tutor = await TutorService.instance.getTutorCompleto(widget.tutor.id);
      if (mounted) {
        setState(() {
          _tutorCompleto = tutor;
          _carregando = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _carregando = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao carregar dados do tutor: $e')));
      }
    }
  }

  Future<void> _navegarEAtualizar(Widget tela) async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => tela));
    _carregarTutorCompleto();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      // O AppBar agora é transparente para o efeito funcionar
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Painel do Tutor', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.transparent, // Transparente
        elevation: 0,
        actions: [
          if (_carregando)
            const Padding(padding: EdgeInsets.only(right: 20.0), child: Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 3, color: Colors.white)))),
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
          // Conteúdo principal
          SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildHeader(),
                const SizedBox(height: 24),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    "O que você gostaria de fazer?",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 16),
                _buildDashboardGrid(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    // ClipRRect é necessário para conter o efeito de blur
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.white.withOpacity(0.2), // Cor semi-transparente para o efeito de vidro
            border: Border.all(color: Colors.white.withOpacity(0.3))
          ),
          child: Row(
            children: [
              // LÓGICA DA FOTO DE PERFIL ATUALIZADA
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.white.withOpacity(0.8),
                // backgroundImage: _tutorCompleto.fotoPerfilPath != null 
                //   ? FileImage(File(_tutorCompleto.fotoPerfilPath!)) 
                //   : null,
                child: _tutorCompleto.fotoPerfilPath == null 
                  ? Text(
                      _tutorCompleto.nome.substring(0, 1),
                      style: const TextStyle(fontSize: 28, color: Color(0xFF0A1A46), fontWeight: FontWeight.bold),
                    )
                  : null,
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Olá, ${_tutorCompleto.nome}!',
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 5),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'Média: ${_tutorCompleto.mediaAvaliacoes.toStringAsFixed(1)} ⭐',
                        style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
                      ),
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
  
  Widget _buildDashboardGrid() {
    // ... (O restante do código do Grid permanece o mesmo, mas agora terá um fundo transparente)
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(), 
      children: [
        _buildDashboardItem(
          icon: Icons.notification_add_rounded,
          text: 'Solicitações',
          onTap: () => _navegarEAtualizar(SolicitacoesTutorScreen(tutor: _tutorCompleto)),
          color: Colors.orange,
        ),
        _buildDashboardItem(
          icon: Icons.edit_calendar_rounded,
          text: 'Gerenciar Agenda',
          onTap: () => _navegarEAtualizar(GerenciarAgendaScreen(tutor: _tutorCompleto)),
          color: Colors.blue,
        ),
        _buildDashboardItem(
          icon: Icons.calendar_today_rounded,
          text: 'Agendamentos',
          onTap: () => _navegarEAtualizar(AgendamentosTutorScreen(tutor: _tutorCompleto)),
          color: Colors.green,
        ),
        _buildDashboardItem(
          icon: Icons.star_rounded,
          text: 'Avaliações',
          onTap: () => _navegarEAtualizar(AvaliacoesTutorScreen(tutor: _tutorCompleto)),
          color: Colors.amber,
        ),
        _buildDashboardItem(
          icon: Icons.school_rounded,
          text: 'Minhas Áreas',
          onTap: () => _navegarEAtualizar(AreasTutorScreen(tutor: _tutorCompleto)),
          color: Colors.purple,
        ),
      ],
    );
  }

  Widget _buildDashboardItem({
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
              border: Border.all(color: Colors.white.withOpacity(0.4))
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
