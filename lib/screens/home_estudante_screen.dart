import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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

  String _getProximoHorario(Tutor tutor) {
    final agora = DateTime.now();
    final disponibilidadesFuturas = tutor.disponibilidades
        .where((d) => d.dataHora.isAfter(agora) && !d.agendado)
        .toList();

    if (disponibilidadesFuturas.isEmpty) {
      return 'Sem horários';
    }

    disponibilidadesFuturas.sort((a, b) => a.dataHora.compareTo(b.dataHora));
    final proximoHorario = disponibilidadesFuturas.first.dataHora;

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
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: _buildProfileHeader(widget.estudante),
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 80,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil('/', (Route<dynamic> route) => false),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
            child: Text('Tutores em Destaque', style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 22, fontWeight: FontWeight.bold)),
          ),
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
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 15, mainAxisSpacing: 15, childAspectRatio: 0.8),
                  itemCount: tutores.length,
                  itemBuilder: (context, index) => _buildTutorCard(tutores[index]),
                );
              },
            ),
          ),
        ],
      ),
       bottomNavigationBar: _buildBottomNavBar(context),
    );
  }
  
    Widget _buildBottomNavBar(BuildContext context) {
    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
           _buildNavIcon(Icons.school_rounded, 'Buscar', () => Navigator.push(context, MaterialPageRoute(builder: (context) => BuscarPorAreaScreen(estudante: widget.estudante)))),
           _buildNavIcon(Icons.calendar_today, 'Agenda', () => Navigator.push(context, MaterialPageRoute(builder: (context) => AgendamentosEstudanteScreen(estudante: widget.estudante)))),
           _buildNavIcon(Icons.star, 'Avaliar', () => Navigator.push(context, MaterialPageRoute(builder: (context) => AvaliarTutorScreen(estudante: widget.estudante)))),
        ],
      ),
    );
  }

  Widget _buildNavIcon(IconData icon, String label, VoidCallback onPressed) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(30),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 26),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(Estudante estudante) {
     return Row(
      children: [
        CircleAvatar(
          radius: 24,
          backgroundImage: estudante.fotoPerfilPath != null && estudante.fotoPerfilPath!.isNotEmpty ? FileImage(File(estudante.fotoPerfilPath!)) : null,
          child: estudante.fotoPerfilPath == null || estudante.fotoPerfilPath!.isEmpty ? const Icon(Icons.person, size: 24, color: Color(0xFF0A1A46)) : null,
          backgroundColor: Colors.white,
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Olá, ${estudante.nome.split(' ').first}', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            Text('Bem-vindo(a) de volta!', style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14)),
          ],
        ),
      ],
    );
  }

  Widget _buildTutorCard(Tutor tutor) {
    final proximoHorario = _getProximoHorario(tutor);

    return Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(15)
        ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 30,
              backgroundImage: tutor.fotoPerfilPath != null && tutor.fotoPerfilPath!.isNotEmpty ? FileImage(File(tutor.fotoPerfilPath!)) : null,
              child: tutor.fotoPerfilPath == null || tutor.fotoPerfilPath!.isEmpty ? const Icon(Icons.person, size: 30, color: Color(0xFF0A1A46),) : null,
              backgroundColor: Colors.white,
            ),
            const Spacer(),
            Text(tutor.nome.split(' ').first, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16), textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 4),
            Text(tutor.areasConhecimento.isNotEmpty ? tutor.areasConhecimento.first.nome : 'Sem especialidade', style: TextStyle(color: Colors.white70, fontSize: 12), textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.watch_later_outlined, color: Colors.white70, size: 14),
                const SizedBox(width: 4),
                Text(proximoHorario, style: const TextStyle(color: Colors.white, fontSize: 12)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
