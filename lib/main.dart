import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart'; // Import para inicialização de data
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
  
  // CORREÇÃO: Inicializa os dados de formatação de data para o local pt_BR
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
      initialRoute: '/',
      // Usar onGenerateRoute para uma navegação mais robusta e segura
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

          // --- NOVAS ROTAS EXPLÍCITAS ---
          case '/home_estudante':
            final estudante = settings.arguments as Estudante?;
            if (estudante != null) {
              return MaterialPageRoute(builder: (_) => HomeEstudanteScreen(estudante: estudante));
            }
            break; // Se argumento for nulo, cai no fallback

          case '/home_tutor':
            final tutor = settings.arguments as Tutor?;
            if (tutor != null) {
              return MaterialPageRoute(builder: (_) => HomeTutorScreen(tutor: tutor));
            }
            break; // Se argumento for nulo, cai no fallback

          case '/home_coordenador':
            final coordenador = settings.arguments as Coordenador?;
            if (coordenador != null) {
              return MaterialPageRoute(builder: (_) => HomeCoordenadorScreen(coordenador: coordenador));
            }
            break; // Se argumento for nulo, cai no fallback
        }

        // Fallback: Se nenhuma rota corresponder, ou argumentos forem inválidos, volta para a tela de escolha.
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A1A46), // azul escuro de fundo
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Logo FMP
                Image.asset(
                  'assets/logo_fmp.png',
                  height: 90,
                ),
                const SizedBox(height: 40),

                // Card branco
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
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
                      const Text(
                        "Selecionar tipo de usuário",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 25),

                      // Botões de usuário
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _botaoUsuario("Estudante", Icons.person, "estudante"),
                          _botaoUsuario("Tutor", Icons.school, "tutor"),
                          _botaoUsuario("Coordenador", Icons.manage_accounts, "coordenador"),
                        ],
                      ),

                      const SizedBox(height: 30),

                      // Botão "Entrar"
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0056A6),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () {
                            if (usuarioSelecionado == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Selecione um tipo de usuário.'),
                                ),
                              );
                            } else {
                              // Navegar para tela de login com o tipo de usuário selecionado
                              Navigator.pushNamed(
                                context,
                                '/login',
                                arguments: usuarioSelecionado,
                              );
                            }
                          },
                          child: const Text(
                            "Entrar",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Link de cadastro
                      GestureDetector(
                        onTap: () {
                          if (usuarioSelecionado == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Selecione um tipo de usuário primeiro.'),
                              ),
                            );
                          } else {
                            // Navegar para tela de cadastro
                            Navigator.pushNamed(
                              context,
                              '/cadastro',
                              arguments: usuarioSelecionado,
                            );
                          }
                        },
                        child: const Text.rich(
                          TextSpan(
                            text: "Não possui login? ",
                            style: TextStyle(color: Colors.black54),
                            children: [
                              TextSpan(
                                text: "Cadastre-se",
                                style: TextStyle(
                                  color: Color(0xFF0056A6),
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
    final bool selecionado = usuarioSelecionado == valor;
    return GestureDetector(
      onTap: () => setState(() => usuarioSelecionado = valor),
      child: Container(
        width: 90,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selecionado ? const Color(0xFFE7F1FF) : Colors.white,
          border: Border.all(
            color: selecionado ? const Color(0xFF0056A6) : Colors.grey.shade300,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icone, color: const Color(0xFF0056A6), size: 32),
            const SizedBox(height: 8),
            Text(
              titulo,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: const Color(0xFF0056A6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
