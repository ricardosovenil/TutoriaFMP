import 'dart:io';
import 'package:flutter/material.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:intl/intl.dart'; // Import para formatação de data
import '../models/estudante.dart';
import '../models/tutor.dart';
import '../services/tutor_service.dart';
import 'buscar_por_area_screen.dart';
import 'agendamentos_estudante_screen.dart';
import 'avaliar_tutor_screen.dart';

class HomeEstudanteScreen extends StatefulWidget {
  final Estudante estudante;
  const HomeEstudanteScreen({super.key, required this.estudante});

  @override
  State<HomeEstudanteScreen> createState() => _HomeEstudanteScreenState();
}

class _HomeEstudanteScreenState extends State<HomeEstudanteScreen> {
  late Future<List<Tutor>> _tutoresFuture;

  @override
  void initState() {
    super.initState();
    _tutoresFuture = TutorService.instance.listarTutores(aprovado: true);
  }

  // NOVO: Método para buscar e formatar o próximo horário
  String _getProximoHorario(Tutor tutor) {
    final agora = DateTime.now();
    final disponibilidadesFuturas = tutor.disponibilidades
        .where((d) => d.dataHora.isAfter(agora) && !d.agendado)
        .toList();

    if (disponibilidadesFuturas.isEmpty) {
      return 'Sem horários';
    }

    // Ordena para garantir que o mais próximo esteja primeiro
    disponibilidadesFuturas.sort((a, b) => a.dataHora.compareTo(b.dataHora));
    final proximoHorario = disponibilidadesFuturas.first.dataHora;

    // Formata a data
    if (agora.day == proximoHorario.day && agora.month == proximoHorario.month && agora.year == proximoHorario.year) {
      return 'Hoje, ${DateFormat.Hm().format(proximoHorario)}';
    } else {
      return DateFormat('dd/MM, HH:mm').format(proximoHorario);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A1A46),
      body: Stack(
        children: [
          Container(decoration: const BoxDecoration(image: DecorationImage(image: AssetImage('assets/background_home.jpg'), fit: BoxFit.cover))),
          SafeArea(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSideNavBar(context),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(10, 20, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildProfileHeader(widget.estudante),
                        const SizedBox(height: 30),
                        const Text('Tutores em Destaque', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 15),
                        Expanded(
                          child: FutureBuilder<List<Tutor>>(
                            future: _tutoresFuture,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return const Center(child: CircularProgressIndicator());
                              }
                              if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                                return const Center(child: Text('Nenhum tutor disponível.', style: TextStyle(color: Colors.white70)));
                              }
                              final tutores = snapshot.data!;
                              return GridView.builder(
                                padding: EdgeInsets.zero,
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 15, mainAxisSpacing: 15, childAspectRatio: 0.8),
                                itemCount: tutores.length,
                                itemBuilder: (context, index) => _buildTutorCard(tutores[index]),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSideNavBar(BuildContext context) {
    // ... (código existente, sem mudanças)
    return GlassmorphicContainer(
      width: 80,
      height: double.infinity,
      borderRadius: 0, blur: 15, border: 0,
      linearGradient: LinearGradient(colors: [Colors.white.withOpacity(0.1), Colors.white.withOpacity(0.05)], begin: Alignment.topLeft, end: Alignment.bottomRight),
      borderGradient: const LinearGradient(colors: [Colors.transparent, Colors.transparent]),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              children: [
                const SizedBox(height: 20),
                _buildNavIcon(Icons.school_rounded, () => Navigator.push(context, MaterialPageRoute(builder: (context) => BuscarPorAreaScreen(estudante: widget.estudante)))),
                const SizedBox(height: 40),
                _buildNavIcon(Icons.calendar_today, () => Navigator.push(context, MaterialPageRoute(builder: (context) => AgendamentosEstudanteScreen(estudante: widget.estudante)))),
                const SizedBox(height: 40),
                _buildNavIcon(Icons.star, () => Navigator.push(context, MaterialPageRoute(builder: (context) => AvaliarTutorScreen(estudante: widget.estudante)))),
              ],
            ),
            _buildNavIcon(Icons.logout, () => Navigator.of(context).pushNamedAndRemoveUntil('/', (Route<dynamic> route) => false)),
          ],
        ),
      ),
    );
  }

  Widget _buildNavIcon(IconData icon, VoidCallback onPressed) {
    return IconButton(icon: Icon(icon, color: Colors.white, size: 30), onPressed: onPressed);
  }

  Widget _buildProfileHeader(Estudante estudante) {
    // ... (código existente, sem mudanças)
     return Row(
      children: [
        CircleAvatar(
          radius: 30,
          backgroundImage: estudante.fotoPerfilPath != null && estudante.fotoPerfilPath!.isNotEmpty ? FileImage(File(estudante.fotoPerfilPath!)) : null,
          child: estudante.fotoPerfilPath == null || estudante.fotoPerfilPath!.isEmpty ? const Icon(Icons.person, size: 30, color: Colors.white) : null,
          backgroundColor: Colors.white24,
        ),
        const SizedBox(width: 15),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Olá, ${estudante.nome.split(' ').first}', style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
            Text('Bem-vindo(a) de volta!', style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14)),
          ],
        ),
      ],
    );
  }

  // ATUALIZADO: Card de Tutor com foto deslocada e horário
  Widget _buildTutorCard(Tutor tutor) {
    final proximoHorario = _getProximoHorario(tutor);

    return GlassmorphicContainer(
      width: double.infinity,
      height: double.infinity,
      borderRadius: 20, blur: 15, alignment: Alignment.center,
      border: 2,
      linearGradient: LinearGradient(colors: [Colors.white.withOpacity(0.15), Colors.white.withOpacity(0.05)], stops: const [0.1, 1], begin: Alignment.topLeft, end: Alignment.bottomRight),
      borderGradient: LinearGradient(colors: [Colors.white.withOpacity(0.5), Colors.white.withOpacity(0.5)], begin: Alignment.topLeft, end: Alignment.bottomRight),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            const Spacer(flex: 2), // Empurra a foto para baixo
            CircleAvatar(
              radius: 35,
              backgroundImage: tutor.fotoPerfilPath != null && tutor.fotoPerfilPath!.isNotEmpty ? FileImage(File(tutor.fotoPerfilPath!)) : null,
              child: tutor.fotoPerfilPath == null || tutor.fotoPerfilPath!.isEmpty ? const Icon(Icons.person, size: 35) : null,
            ),
            const Spacer(flex: 3), // Espaço flexível abaixo da foto
            Text(tutor.nome.split(' ').first, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16), textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 4),
            Text(tutor.areasConhecimento.isNotEmpty ? tutor.areasConhecimento.first.nome : 'Sem especialidade', style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12), textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
            const Spacer(),
            // NOVO: Exibição do próximo horário
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.watch_later_outlined, color: Colors.white.withOpacity(0.7), size: 14),
                const SizedBox(width: 4),
                Text(proximoHorario, style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 12)),
              ],
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
