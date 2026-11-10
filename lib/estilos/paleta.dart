// [06/11/2026] Paleta y fondo de la app, copiados del rediseño de la app
// argentina (Examen de manejo, mayo 2026): índigo, degradé suave, sin AppBar.
// En la app argentina cada pantalla repetía estas constantes; acá están
// centralizadas. — Claude (IA)

import 'package:flutter/material.dart';

class Paleta {
  static const Color primary = Color(0xFF1A237E); // índigo oscuro - títulos
  static const Color accent = Color(0xFF304FFE); // azul vibrante - acciones
  static const Color accent2 = Color(0xFF5C6BC0); // índigo medio
  static const Color surface = Colors.white; // tarjetas
  static const Color muted = Color(0xFF7986CB); // texto secundario
  static const Color success = Color(0xFF2E7D32);
  static const Color danger = Color(0xFFD32F2F);
  static const Color opcionBg = Color(0xFFF5F7FF);

  static const BoxDecoration fondo = BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFFEEF1FF), Color(0xFFFFFFFF)],
      stops: [0.0, 0.6],
    ),
  );

  static const LinearGradient gradienteAccent = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accent, accent2],
  );

  static const LinearGradient gradienteAprobado = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1B5E20), Color(0xFF388E3C)],
  );

  static List<BoxShadow> sombraSuave = [
    BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 12, offset: const Offset(0, 4)),
  ];

  static List<BoxShadow> sombraAccent = [
    BoxShadow(color: accent.withValues(alpha: 0.35), blurRadius: 14, offset: const Offset(0, 6)),
  ];
}
