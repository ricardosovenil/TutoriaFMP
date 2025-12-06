import 'package:flutter/material.dart';
import 'package:flutter_application_1/theme/app_theme.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'screens/login_screen.dart';
import 'screens/cadastro_screen.dart';
import 'screens/home_estudante_screen.dart';
import 'screens/home_tutor_screen.dart';
import 'screens/home_coordenador_screen.dart';
import 'models/usuario.dart';
import 'models/estudante.dart';
import 'models/tutor.dart';
import 'models/coordenador.dart';
import 'database/database_helper.dart';
import 'database/database_init_stub.dart' if (dart.library.io) 'database/database_init_io.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('pt_BR', null);
  initDatabaseForPlatform();
  await DatabaseHelper.instance.database;
  await DatabaseHelper.instance.ensureDefaultUsers();
  runApp(const FmpApp());
}

class FmpApp extends StatelessWidget {
  const FmpApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FMP - Sistema de Tutoria',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system, // Força o tema escuro para este exemplo
      initialRoute: '/',
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/':
            return MaterialPageRoute(builder: (_) => const TelaEscolhaUsuario());

          case '/login':
            final tipoUsuario = settings.arguments as String?;
            return MaterialPageRoute(builder: (_) => LoginScreen(tipoUsuario: tipoUsuario ?? 'estudante'));

          case '/cadastro':
            final tipoUsuario = settings.arguments as String?;
            return MaterialPageRoute(builder: (_) => CadastroScreen(tipoUsuario: tipoUsuario ?? 'estudante'));

          case '/home_estudante':
            final estudante = settings.arguments as Estudante?;
            if (estudante != null) {
              return MaterialPageRoute(builder: (_) => HomeEstudanteScreen(estudante: estudante));
            }
            break;

          case '/home_tutor':
            final tutor = settings.arguments as Tutor?;
            if (tutor != null) {
              return MaterialPageRoute(builder: (_) => HomeTutorScreen(tutor: tutor));
            }
            break;

          case '/home_coordenador':
            final coordenador = settings.arguments as Coordenador?;
            if (coordenador != null) {
              return MaterialPageRoute(builder: (_) => HomeCoordenadorScreen(coordenador: coordenador));
            }
            break;
        }
        return MaterialPageRoute(builder: (_) => const TelaEscolhaUsuario());
      },
    );
  }
}

class TelaEscolhaUsuario extends StatefulWidget {
  const TelaEscolhaUsuario({super.key});

  @override
  State<TelaEscolhaUsuario> createState() => _TelaEscolhaUsuarioState();
}

class _TelaEscolhaUsuarioState extends State<TelaEscolhaUsuario> {
  String? usuarioSelecionado;

  void _navegarPara(String rota) {
    if (usuarioSelecionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, selecione um tipo de usuário primeiro.')),
      );
    } else {
      Navigator.pushNamed(context, rota, arguments: usuarioSelecionado);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Forçando o fundo escuro para corresponder à imagem de referência
    return Scaffold(
      backgroundColor: AppColors.darkBlue,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/logo_fmp.png',
                  height: 70,
                ),
                const SizedBox(height: 40),
                Card(
                  elevation: 8,
                  shadowColor: Colors.black.withOpacity(0.2),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                  color: AppColors.white,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
                    child: Column(
                      children: [
                        const Text(
                          "Selecionar tipo de usuário",
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textDark),
                        ),
                        const SizedBox(height: 25),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _botaoUsuario("Estudante", Icons.person, "estudante"),
                            _botaoUsuario("Tutor", Icons.school, "tutor"),
                            _botaoUsuario("Coordenador", Icons.manage_accounts, "coordenador"),
                          ],
                        ),
                        const SizedBox(height: 30),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryBlue,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            onPressed: () => _navegarPara('/login'),
                            child: const Text("Entrar"),
                          ),
                        ),
                        const SizedBox(height: 20),
                        GestureDetector(
                          onTap: () => _navegarPara('/cadastro'),
                          child: const Text.rich(
                            TextSpan(
                              text: "Possui login? ", // Texto ajustado
                              style: TextStyle(color: AppColors.darkGrey, fontSize: 14),
                              children: [
                                TextSpan(
                                  text: "Cadastre-se",
                                  style: TextStyle(
                                    color: AppColors.primaryBlue,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _botaoUsuario(String titulo, IconData icone, String valor) {
    final bool selecionado = usuarioSelecionado == valor;
    
    final Color backgroundColor = selecionado ? AppColors.primaryBlue.withOpacity(0.1) : AppColors.lightGrey;
    final Color borderColor = selecionado ? AppColors.primaryBlue : AppColors.mediumGrey;

    return GestureDetector(
      onTap: () => setState(() => usuarioSelecionado = valor),
      child: Container(
        width: 95,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: backgroundColor,
          border: Border.all(color: borderColor, width: 1.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icone, color: AppColors.primaryBlue, size: 30),
            const SizedBox(height: 6),
            Text(
              titulo,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.primaryBlue,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
