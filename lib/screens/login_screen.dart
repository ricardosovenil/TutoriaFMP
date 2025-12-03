import 'package:flutter/material.dart';
import '../models/usuario.dart';
import '../models/tutor.dart';
import '../services/auth_service.dart';
import 'pending_approval_screen.dart';

class LoginScreen extends StatefulWidget {
  final String tipoUsuario;

  const LoginScreen({super.key, required this.tipoUsuario});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  Future<void> _fazerLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final usuario = await AuthService.instance.login(
        _emailController.text,
        _senhaController.text,
      );

      if (usuario == null) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Email ou senha incorretos.')));
      } else if (usuario.tipoUsuario != widget.tipoUsuario) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Login falhou. Este usuário não é um ${widget.tipoUsuario}.')));
      } else {
        if (mounted) {
          if (usuario is Tutor) {
            if (usuario.aprovado == 0) {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const PendingApprovalScreen()),
                (Route<dynamic> route) => false,
              );
              return;
            }
          }

          String routeName;
          switch (usuario.tipoUsuario) {
            case 'estudante':
              routeName = '/home_estudante';
              break;
            case 'tutor':
              routeName = '/home_tutor';
              break;
            case 'coordenador':
              routeName = '/home_coordenador';
              break;
            default:
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tipo de usuário desconhecido!')));
              setState(() => _isLoading = false);
              return;
          }
          Navigator.pushReplacementNamed(context, routeName, arguments: usuario);
        }
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao fazer login: ${e.toString()}')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    String titulo = widget.tipoUsuario.replaceFirst(widget.tipoUsuario[0], widget.tipoUsuario[0].toUpperCase());

    return Scaffold(
      backgroundColor: const Color(0xFF0A1A46),
      appBar: AppBar(
        title: Text('Login - $titulo', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/logo_fmp.png', height: 70),
                const SizedBox(height: 30),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Email',
                          labelStyle: const TextStyle(color: Colors.white70),
                          prefixIcon: const Icon(Icons.email, color: Colors.white70),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.white54)),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.white, width: 2)),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Por favor, insira seu email';
                          if (!value.contains('@')) return 'Email inválido';
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _senhaController,
                        obscureText: _obscurePassword,
                         style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Senha',
                           labelStyle: const TextStyle(color: Colors.white70),
                          prefixIcon: const Icon(Icons.lock, color: Colors.white70),
                          suffixIcon: IconButton(icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off, color: Colors.white70), onPressed: () => setState(() => _obscurePassword = !_obscurePassword)),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.white54)),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.white, width: 2)),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Por favor, insira sua senha';
                          if (value.length < 6) return 'Senha deve ter pelo menos 6 caracteres';
                          return null;
                        },
                      ),
                      const SizedBox(height: 30),
                      SizedBox(
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: const Color(0xFF0056A6), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                          onPressed: _isLoading ? null : _fazerLogin,
                          child: _isLoading
                              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0056A6))))
                              : const Text("Entrar", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                 TextButton(
                    onPressed: () => Navigator.pushNamed(context, '/cadastro', arguments: widget.tipoUsuario),
                    child: const Text('Não possui conta? Cadastre-se', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
