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
      if (emailExiste) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Este email já está cadastrado')));
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
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    String titulo = widget.tipoUsuario.replaceFirst(widget.tipoUsuario[0], widget.tipoUsuario[0].toUpperCase());

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Cadastro - $titulo'),
        backgroundColor: isDarkMode ? Colors.transparent : theme.appBarTheme.backgroundColor,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: theme.colorScheme.onSurface.withOpacity(0.1),
                      backgroundImage: _fotoPerfilFile != null ? FileImage(_fotoPerfilFile!) : null,
                      child: _fotoPerfilFile == null ? Icon(Icons.person, size: 60, color: theme.colorScheme.onSurface.withOpacity(0.4)) : null,
                    ),
                    Positioned(
                      bottom: 0, right: 0,
                      child: CircleAvatar(
                        backgroundColor: theme.colorScheme.surface,
                        child: IconButton(icon: Icon(Icons.camera_alt, color: theme.colorScheme.primary), onPressed: _selecionarFotoPerfil,),
                      )
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _buildTextFormField(theme, controller: _nomeController, labelText: 'Nome Completo', validator: (v) => v!.isEmpty ? 'Campo obrigatório' : null),
              const SizedBox(height: 16),
              _buildTextFormField(theme, controller: _emailController, labelText: 'Email', keyboardType: TextInputType.emailAddress, validator: (v) => v!.isEmpty || !v.contains('@') ? 'Email inválido' : null),
              const SizedBox(height: 16),
              _buildTextFormField(theme, controller: _senhaController, labelText: 'Senha (mín. 6 caracteres)', obscureText: true, validator: (v) => v!.length < 6 ? 'Senha muito curta' : null),
              const SizedBox(height: 16),
              _buildTextFormField(theme, controller: _confirmarSenhaController, labelText: 'Confirmar Senha', obscureText: true, validator: (v) => v != _senhaController.text ? 'As senhas não coincidem' : null),
              
              if (widget.tipoUsuario == 'estudante') ...[
                const SizedBox(height: 16),
                _buildTextFormField(theme, controller: _matriculaController, labelText: 'Matrícula', keyboardType: TextInputType.number, validator: (v) => v!.isEmpty ? 'Campo obrigatório' : null),
                const SizedBox(height: 16),
                _buildTextFormField(theme, controller: _cursoController, labelText: 'Curso', validator: (v) => v!.isEmpty ? 'Campo obrigatório' : null),
              ],

              if (widget.tipoUsuario == 'tutor') ...[
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(border: Border.all(color: theme.colorScheme.onSurface.withOpacity(0.4)), borderRadius: BorderRadius.circular(12)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Icon(Icons.picture_as_pdf_outlined, color: AppColors.primaryBlue), 
                      const SizedBox(width: 12),
                      Expanded(child: Text(_curriculoFile?.path.split(Platform.pathSeparator).last ?? 'Currículo (PDF, máx 5MB)', style: theme.textTheme.bodyMedium, overflow: TextOverflow.ellipsis)),
                      ElevatedButton(child: const Text('Anexar'), onPressed: _selecionarCurriculo),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _fazerCadastro,
                  child: _isLoading ? const CircularProgressIndicator() : const Text('Finalizar Cadastro'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextFormField(ThemeData theme, {required TextEditingController controller, required String labelText, bool obscureText = false, String? Function(String?)? validator, TextInputType? keyboardType}) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: TextStyle(color: theme.colorScheme.onSurface),
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.7)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: theme.colorScheme.onSurface.withOpacity(0.4))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: theme.colorScheme.primary, width: 2)),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: theme.colorScheme.error)),
        focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: theme.colorScheme.error, width: 2)),
      ),
      validator: validator,
    );
  }
}
