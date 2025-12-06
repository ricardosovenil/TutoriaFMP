import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';

class CadastroScreen extends StatefulWidget {
  final String tipoUsuario;

  const CadastroScreen({super.key, required this.tipoUsuario});

  @override
  State<CadastroScreen> createState() => _CadastroScreenState();
}

class _CadastroScreenState extends State<CadastroScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  final _confirmarSenhaController = TextEditingController();
  bool _isLoading = false;
  bool _obscureSenha = true;
  bool _obscureConfirmarSenha = true;

  File? _fotoPerfilFile;
  File? _curriculoFile;

  final _matriculaController = TextEditingController();
  final _cursoController = TextEditingController();

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _senhaController.dispose();
    _confirmarSenhaController.dispose();
    _matriculaController.dispose();
    _cursoController.dispose();
    super.dispose();
  }

  Future<void> _selecionarFotoPerfil() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null && result.files.single.path != null) {
      setState(() => _fotoPerfilFile = File(result.files.single.path!));
    }
  }

  Future<void> _selecionarCurriculo() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);
    if (result != null && result.files.single.path != null) {
      final file = File(result.files.single.path!);
      if (file.lengthSync() > 5 * 1024 * 1024) {
        if(mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Erro: O PDF não pode ter mais de 5MB.')));
        return;
      }
      setState(() => _curriculoFile = file);
    }
  }

  Future<void> _fazerCadastro() async {
    if (!_formKey.currentState!.validate()) return;
    if (widget.tipoUsuario == 'tutor' && _curriculoFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Por favor, anexe seu currículo em PDF.')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final emailExiste = await AuthService.instance.emailJaExiste(_emailController.text);
      if (mounted && emailExiste) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Este email já está cadastrado')));
        setState(() => _isLoading = false);
        return;
      }

      switch (widget.tipoUsuario) {
        case 'estudante':
          await AuthService.instance.cadastrarEstudante(
            nome: _nomeController.text, email: _emailController.text, senha: _senhaController.text,
            matricula: int.tryParse(_matriculaController.text) ?? 0, curso: _cursoController.text,
            fotoPerfil: _fotoPerfilFile,
          );
          break;
        case 'tutor':
          await AuthService.instance.cadastrarTutor(
            nome: _nomeController.text, email: _emailController.text, senha: _senhaController.text,
            curriculoFile: _curriculoFile!,
            fotoPerfil: _fotoPerfilFile,
          );
          break;
        case 'coordenador':
           await AuthService.instance.cadastrarCoordenador(nome: _nomeController.text, email: _emailController.text, senha: _senhaController.text, fotoPerfil: _fotoPerfilFile,);
           break;
        default: throw Exception('Tipo de usuário inválido');
      }

      if (mounted) {
        final successMessage = widget.tipoUsuario == 'tutor' 
            ? 'Cadastro enviado para análise com sucesso!'
            : 'Cadastro realizado com sucesso!';
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(successMessage)));
        Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao cadastrar: ${e.toString()}')));
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
        title: Text('Cadastro - $titulo', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Card(
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
                    _buildAvatarSelector(),
                    const SizedBox(height: 30),
                    _buildTextFormField(controller: _nomeController, labelText: 'Nome Completo', prefixIcon: Icons.person, validator: (v) => v!.isEmpty ? 'Campo obrigatório' : null),
                    const SizedBox(height: 16),
                    _buildTextFormField(controller: _emailController, labelText: 'Email', prefixIcon: Icons.email, keyboardType: TextInputType.emailAddress, validator: (v) => v!.isEmpty || !v.contains('@') ? 'Email inválido' : null),
                    const SizedBox(height: 16),
                    _buildTextFormField(controller: _senhaController, labelText: 'Senha (mín. 6 caracteres)', prefixIcon: Icons.lock, obscureText: _obscureSenha, suffixIcon: IconButton(icon: Icon(_obscureSenha ? Icons.visibility : Icons.visibility_off, color: AppColors.darkGrey), onPressed: () => setState(() => _obscureSenha = !_obscureSenha)), validator: (v) => v!.length < 6 ? 'Senha muito curta' : null),
                    const SizedBox(height: 16),
                    _buildTextFormField(controller: _confirmarSenhaController, labelText: 'Confirmar Senha', prefixIcon: Icons.lock, obscureText: _obscureConfirmarSenha, suffixIcon: IconButton(icon: Icon(_obscureConfirmarSenha ? Icons.visibility : Icons.visibility_off, color: AppColors.darkGrey), onPressed: () => setState(() => _obscureConfirmarSenha = !_obscureConfirmarSenha)), validator: (v) => v != _senhaController.text ? 'As senhas não coincidem' : null),
                    if (widget.tipoUsuario == 'estudante') _buildCamposEstudante(),
                    if (widget.tipoUsuario == 'tutor') _buildCurriculoSelector(),
                    const SizedBox(height: 32),
                    _buildBotaoCadastro(),
                    const SizedBox(height: 20),
                    _buildLinkLogin(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarSelector() {
    return Center(
      child: Stack(
        children: [
          CircleAvatar(
            radius: 60,
            backgroundColor: AppColors.lightGrey,
            backgroundImage: _fotoPerfilFile != null ? FileImage(_fotoPerfilFile!) : null,
            child: _fotoPerfilFile == null ? const Icon(Icons.person, size: 60, color: AppColors.mediumGrey) : null,
          ),
          Positioned(
            bottom: 0, right: 0,
            child: CircleAvatar(
              backgroundColor: AppColors.white,
              child: IconButton(icon: const Icon(Icons.camera_alt, color: AppColors.primaryBlue), onPressed: _selecionarFotoPerfil),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCamposEstudante() {
    return Column(
      children: [
        const SizedBox(height: 16),
        _buildTextFormField(controller: _matriculaController, labelText: 'Matrícula', prefixIcon: Icons.school, keyboardType: TextInputType.number, validator: (v) => v!.isEmpty ? 'Campo obrigatório' : null),
        const SizedBox(height: 16),
        _buildTextFormField(controller: _cursoController, labelText: 'Curso', prefixIcon: Icons.book, validator: (v) => v!.isEmpty ? 'Campo obrigatório' : null),
      ],
    );
  }

  Widget _buildCurriculoSelector() {
    return Padding(
      padding: const EdgeInsets.only(top: 24.0),
      child: OutlinedButton.icon(
        icon: const Icon(Icons.picture_as_pdf_outlined),
        label: Flexible(child: Text(_curriculoFile?.path.split(Platform.pathSeparator).last ?? 'Currículo (PDF, máx 5MB)', overflow: TextOverflow.ellipsis)),
        onPressed: _selecionarCurriculo,
        style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16), side: const BorderSide(color: AppColors.mediumGrey)),
      ),
    );
  }

  Widget _buildBotaoCadastro() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryBlue,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        onPressed: _isLoading ? null : _fazerCadastro,
        child: _isLoading 
            ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 3, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)))
            : const Text('Finalizar Cadastro'),
      ),
    );
  }

  Widget _buildLinkLogin() {
    return GestureDetector(
      onTap: () => Navigator.pop(context), // Volta para a tela de login
      child: const Text.rich(
        TextSpan(
          text: "Já possui conta? ",
          style: TextStyle(color: AppColors.darkGrey, fontSize: 14),
          children: [
            TextSpan(
              text: "Entre",
              style: TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ],
        ),
        textAlign: TextAlign.center,
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
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.mediumGrey)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primaryBlue, width: 2)),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.error)),
        focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.error, width: 2)),
      ),
      validator: validator,
    );
  }
}
