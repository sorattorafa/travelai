import 'package:flutter/material.dart';

/// Paleta oficial do GuIA.
///
/// Fonte única de verdade para todas as cores de marca do app.
/// Use semanticamente (ex: `AppColors.primary`) em vez de hex literal.
class AppColors {
  // Cores base da paleta
  static const Color slate = Color(0xFF393F50);   // Ardósia - texto escuro, fundo splash
  static const Color indigo = Color(0xFF435892);  // Índigo - cor primária de ação
  static const Color cream = Color(0xFFF2EEE7);   // Creme - fundo das telas
  static const Color sand = Color(0xFFBCAA8A);    // Areia - acento secundário

  // Variações
  static const Color slateDark = Color(0xFF2A2F3D);
  static const Color slateLight = Color(0xFF525A70);
  static const Color indigoLight = Color(0xFF5C73AD);
  static const Color indigoDark = Color(0xFF33447A);
  static const Color sandLight = Color(0xFFD4C4A4);
  static const Color creamDark = Color(0xFFE8E1D3);

  // Aliases semânticos
  static const Color primary = indigo;
  static const Color primaryDark = indigoDark;
  static const Color accent = sand;
  static const Color background = cream;
  static const Color surface = Colors.white;
  static const Color textPrimary = slate;
  static const Color textSecondary = slateLight;

  // Semânticas (mantidas – não fazem parte da marca)
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
  static const Color success = Color(0xFF22C55E);

  // Gradientes
  static const LinearGradient brandGradient = LinearGradient(
    colors: [indigo, slate],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [indigo, sand],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
