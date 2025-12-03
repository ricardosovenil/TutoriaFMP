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
      themeMode: ThemeMode.system,
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
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Image.asset(
                  'assets/logo_fmp.png',
                  height: 90,
                ),
                const SizedBox(height: 40),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
                  decoration: BoxDecoration(
                    color: theme.cardTheme.color,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        "Selecionar tipo de usuário",
                        style: theme.textTheme.headlineSmall,
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
                          onPressed: () => _navegarPara('/login'),
                          child: const Text("Entrar"),
                        ),
                      ),
                      const SizedBox(height: 20),
                      GestureDetector(
                        onTap: () => _navegarPara('/cadastro'),
                        child: Text.rich(
                          TextSpan(
                            text: "Não possui login? ",
                            style: theme.textTheme.bodyMedium,
                            children: [
                              TextSpan(
                                text: "Cadastre-se",
                                style: TextStyle(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.w600,
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
          ),
        ),
      ),
    );
  }

  Widget _botaoUsuario(String titulo, IconData icone, String valor) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final bool selecionado = usuarioSelecionado == valor;
    
    final Color backgroundColor = selecionado 
      ? (isDarkMode ? AppColors.primaryBlue.withOpacity(0.3) : AppColors.primaryBlue.withOpacity(0.1))
      : theme.cardTheme.color!;

    final Color borderColor = selecionado 
      ? AppColors.primaryBlue 
      : (isDarkMode ? AppColors.mediumGrey.withOpacity(0.5) : AppColors.mediumGrey);

    return GestureDetector(
      onTap: () => setState(() => usuarioSelecionado = valor),
      child: Container(
        width: 90,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: backgroundColor,
          border: Border.all(
            color: borderColor,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icone, color: AppColors.primaryBlue, size: 32),
            const SizedBox(height: 8),
            Text(
              titulo,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: AppColors.primaryBlue,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
