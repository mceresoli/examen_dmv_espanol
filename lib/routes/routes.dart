import 'package:flutter/cupertino.dart';

import '../pages/pages.dart';

final Map<String, Widget Function(BuildContext)> appRoutes = {
  'splash': (_) => const SplashScreen(),
  'initialPage': (_) => const InitialPage(),
  // [06/11/2026] Rutas del simulacro — Claude (IA)
  'elegirEstado': (_) => const ElegirEstadoPage(),
  'examen': (_) => const ExamenPage(),
  'resultado': (_) => const ResultadoPage(),
  'repaso': (_) => const RepasoPage(),
  // [10/11/2026] Estudio por tema — Claude (IA)
  'estudioTemas': (_) => const EstudioTemasPage(),
  'estudio': (_) => const EstudioPage(),
  // [10/11/2026] Catálogo de señales — Claude (IA)
  'seniales': (_) => const SenialesPage(),
  'grupoSeniales': (_) => const GrupoSenialesPage(),
  // [10/11/2026] Examen práctico — Claude (IA)
  'practico': (_) => const PracticoPage(),
  'maniobra': (_) => const ManiobraPage(),
  'frasesExaminador': (_) => const FrasesExaminadorPage(),
};
