import 'package:flutter/material.dart';

// Centraliza a paleta de cores do aplicativo para garantir consistência.
class AppColors {
  // Cores Primárias
  static const Color primaryBlue = Color(0xFF0056A6); // Azul principal para botões e interações
  static const Color darkBlue = Color(0xFF0A1A46);    // Azul escuro para fundos (dark mode)

  // Cores Neutras
  static const Color white = Colors.white;
  static const Color lightGrey = Color(0xFFF2F4F7); // Fundo de telas no modo claro
  static const Color mediumGrey = Color(0xFFD0D5DD); // Bordas e divisórias
  static const Color darkGrey = Color(0xFF475467);   // Textos secundários

  // Cores de Feedback
  static const Color success = Color(0xFF12B76A);     // Verde para status "Aprovado"
  static const Color warning = Color(0xFFF79009);     // Laranja para "Aguardando Aprovação"
  static const Color error = Color(0xFFF04438);       // Vermelho para "Cancelar" e erros

  // Cores de Texto
  static const Color textDark = Color(0xFF1D2939);   // Texto principal no modo claro
  static const Color textLight = Colors.white;        // Texto principal no modo escuro
}

// Define os temas claro e escuro para o aplicativo.
class AppTheme {
  static final _baseElevatedButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: AppColors.primaryBlue,
    foregroundColor: AppColors.white,
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
  );

  // TEMA CLARO (LIGHT)
  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: AppColors.primaryBlue,
      scaffoldBackgroundColor: AppColors.lightGrey,
      
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.lightGrey,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.textDark),
        titleTextStyle: TextStyle(
          color: AppColors.textDark,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),

      cardTheme: CardThemeData(
        color: AppColors.white,
        elevation: 1,
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.mediumGrey, width: 0.5),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(style: _baseElevatedButtonStyle),

      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: AppColors.textDark),
        bodyMedium: TextStyle(color: AppColors.darkGrey),
        headlineSmall: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold),
      ),

      colorScheme: const ColorScheme.light(
        primary: AppColors.primaryBlue,
        secondary: AppColors.primaryBlue,
        surface: AppColors.white,
        background: AppColors.lightGrey,
        error: AppColors.error,
      ),
    );
  }

  // TEMA ESCURO (DARK)
  static ThemeData get darkTheme {
    return ThemeData(
      primaryColor: AppColors.primaryBlue,
      scaffoldBackgroundColor: AppColors.darkBlue,

      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.darkBlue,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.textLight),
        titleTextStyle: TextStyle(
          color: AppColors.textLight,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),

      cardTheme: CardThemeData(
        color: AppColors.darkBlue.withOpacity(0.8),
        elevation: 1,
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.primaryBlue, width: 0.5),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(style: _baseElevatedButtonStyle),

      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: AppColors.textLight),
        bodyMedium: TextStyle(color: AppColors.mediumGrey),
        headlineSmall: TextStyle(color: AppColors.textLight, fontWeight: FontWeight.bold),
      ),
      
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primaryBlue,
        secondary: AppColors.primaryBlue,
        surface: AppColors.darkBlue,
        background: AppColors.darkBlue,
        error: AppColors.error,
      ),
    );
  }
}
