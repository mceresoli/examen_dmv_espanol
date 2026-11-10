import 'package:examen_manejo_dmv_espanol/ads/app_open_ad_manager.dart';
import 'package:examen_manejo_dmv_espanol/provider/estadoProvider.dart';
import 'package:examen_manejo_dmv_espanol/provider/examen_provider.dart';
import 'package:examen_manejo_dmv_espanol/routes/routes.dart';
import 'package:examen_manejo_dmv_espanol/services/banco_preguntas_service.dart';
import 'package:examen_manejo_dmv_espanol/services/catalogo_seniales_service.dart';
import 'package:examen_manejo_dmv_espanol/services/practico_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // [05/11/2026] Carga el banco de preguntas (assets/preguntas/*.json) antes de
  // abrir la app. Los problemas de datos salen por consola con "[Banco]".
  // — Claude (IA)
  await BancoPreguntasService.instancia.cargar();
  // [10/11/2026] Catálogo de la sección "Señales de tránsito". — Claude (IA)
  await CatalogoSenialesService.instancia.cargar();
  // [10/11/2026] Maniobras del examen práctico. — Claude (IA)
  await PracticoService.instancia.cargar();

  // [06/11/2026] Estado elegido e idioma guardados en el teléfono. — Claude (IA)
  final examenProvider = ExamenProvider();
  await examenProvider.cargarPreferencias();

  runApp(AppState(examenProvider: examenProvider));
}

class AppState extends StatelessWidget {
  const AppState({super.key, required this.examenProvider});

  final ExamenProvider examenProvider;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => EstadoProvider(), lazy: false),
        ChangeNotifierProvider.value(value: examenProvider),
      ],
      child: const MyApp(),
    );
  }
}

// [10/11/2026] MyApp observa el ciclo de vida para el App Open Ad al volver de
// background (solo `paused` marca background; `inactive` aparece sin salir de
// la app, p. ej. Centro de control o Face ID). — Claude (IA)
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.paused:
        kAppOpenAdManager.notifyEnteringBackground();
      case AppLifecycleState.resumed:
        kAppOpenAdManager.tryShowOnForeground();
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Examen de Manejo DMV',
      theme: _theme(),
      initialRoute: 'splash',
      routes: appRoutes,
    );
  }

  ThemeData _theme() {
    const Color accent = Color(0xFF4B27E0);

    final base = ThemeData.light();
    final colorScheme = ColorScheme.fromSeed(
      seedColor: accent,
      brightness: Brightness.light,
    );

    return base.copyWith(
      colorScheme: colorScheme,
      primaryColor: accent,
      scaffoldBackgroundColor: const Color(0xFFF7F7FB),
      appBarTheme: AppBarTheme(
        backgroundColor: accent,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: accent,
        unselectedItemColor: Colors.blueGrey,
        selectedIconTheme: IconThemeData(size: 28),
        unselectedIconTheme: IconThemeData(size: 24),
        showUnselectedLabels: false,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: accent,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        margin: const EdgeInsets.all(8),
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Color(0xFFE9E9EF)),
        ),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: accent,
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE9E9EF)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE9E9EF)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: accent, width: 1.5),
        ),
        hintStyle: const TextStyle(color: Colors.black38),
      ),
      textTheme: base.textTheme
          .apply(bodyColor: Colors.black87, displayColor: Colors.black87)
          .copyWith(
            titleLarge: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
            titleMedium: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
            bodyLarge: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
            bodyMedium: const TextStyle(fontSize: 14),
            labelLarge: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.black87,
        contentTextStyle: TextStyle(color: Colors.white),
      ),
      chipTheme: base.chipTheme.copyWith(
        backgroundColor: const Color(0xFFEDE7FF),
        selectedColor: accent.withValues(alpha: 0.15),
        labelStyle: const TextStyle(color: Colors.black87),
        secondaryLabelStyle: const TextStyle(color: Colors.black87),
        side: const BorderSide(color: Color(0xFFE9E9EF)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
