import 'package:flutter/material.dart';
import '../models/usuario.dart';
import '../models/tutor.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
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
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final usuario = await AuthService.instance.login(
        _emailController.text,
        _senhaController.text,
      );

      if (!mounted) return;

      if (usuario == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Email ou senha incorretos.')));
      } else if (usuario.tipoUsuario != widget.tipoUsuario) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Login falhou. Este usuário não é um ${widget.tipoUsuario}.')));
      } else {
        if (usuario is Tutor && usuario.aprovado == 0) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const PendingApprovalScreen()),
            (Route<dynamic> route) => false,
          );
          return;
        }

        String routeName;
        switch (usuario.tipoUsuario) {
          case 'estudante': routeName = '/home_estudante'; break;
          case 'tutor': routeName = '/home_tutor'; break;
          case 'coordenador': routeName = '/home_coordenador'; break;
          default:
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tipo de usuário desconhecido!')));
            setState(() => _isLoading = false);
            return;
        }
        Navigator.pushReplacementNamed(context, routeName, arguments: usuario);
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
      backgroundColor: AppColors.darkBlue,
      appBar: AppBar(
        title: Text('Login - $titulo', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/logo_fmp.png', height: 70),
              const SizedBox(height: 40),
              Card(
                elevation: 8,
                shadowColor: Colors.black.withOpacity(0.2),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                color: AppColors.white,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildTextFormField(
                          controller: _emailController,
                          labelText: 'Email',
                          prefixIcon: Icons.email,
                          keyboardType: TextInputType.emailAddress,
                          validator: (v) => (v == null || !v.contains('@')) ? 'Email inválido' : null,
                        ),
                        const SizedBox(height: 20),
                        _buildTextFormField(
                          controller: _senhaController,
                          labelText: 'Senha',
                          prefixIcon: Icons.lock,
                          obscureText: _obscurePassword,
                          suffixIcon: IconButton(
                            icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off, color: AppColors.darkGrey),
                            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                          ),
                          validator: (v) => (v == null || v.length < 6) ? 'Senha deve ter no mínimo 6 caracteres' : null,
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
                            onPressed: _isLoading ? null : _fazerLogin,
                            child: _isLoading
                                ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 3, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)))
                                : const Text("Entrar"),
                          ),
                        ),
                        const SizedBox(height: 20),
                        GestureDetector(
                          onTap: () => Navigator.pushNamed(context, '/cadastro', arguments: widget.tipoUsuario),
                          child: const Text.rich(
                            TextSpan(
                              text: "Não possui conta? ",
                              style: TextStyle(color: AppColors.darkGrey, fontSize: 14),
                              children: [
                                TextSpan(
                                  text: "Cadastre-se",
                                  style: TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.bold, fontSize: 14),
                                ),
                              ],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String labelText,
    required IconData prefixIcon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      style: const TextStyle(color: AppColors.textDark),
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: const TextStyle(color: AppColors.darkGrey),
        prefixIcon: Icon(prefixIcon, color: AppColors.darkGrey),
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.mediumGrey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primaryBlue, width: 2),
        ),
      ),
      validator: validator,
    );
  }
}
