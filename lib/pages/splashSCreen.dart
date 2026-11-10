import 'dart:async';

import 'package:flutter/material.dart';

import '../ads/ads_service.dart';
import '../ads/app_open_ad_manager.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  // [10/11/2026] Esquema de la app argentina aprobada: el splash espera el
  // permiso ATT, inicializa los anuncios, muestra el App Open (cold start) y
  // navega al cerrarse. El watchdog es la red de seguridad por si el anuncio
  // nunca avisa (ATT puede tardar ~30 s + 8 s de carga). — Claude (IA)
  bool _navegado = false;
  Timer? _watchdog;

  @override
  void initState() {
    super.initState();
    _watchdog = Timer(const Duration(seconds: 45), _irAlInicio);
    _arrancar();
  }

  Future<void> _arrancar() async {
    final inicio = DateTime.now();
    await AdsService.ensureAdsInitialized();
    if (!mounted) return;
    if (!AdsService.activo) {
      // Sin anuncios (tests, simulador sin red, error del SDK): el splash dura
      // lo mismo que antes, 8 s en total.
      final resto = const Duration(seconds: 8) - DateTime.now().difference(inicio);
      if (resto > Duration.zero) await Future<void>.delayed(resto);
      _irAlInicio();
      return;
    }
    await kAppOpenAdManager.showOnColdStart(onComplete: _irAlInicio);
  }

  void _irAlInicio() {
    if (_navegado) return;
    _navegado = true;
    _watchdog?.cancel();
    // pushReplacementNamed: así "atrás" no vuelve al splash.
    if (mounted) Navigator.pushReplacementNamed(context, 'initialPage');
  }

  @override
  void dispose() {
    _watchdog?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('lib/assets/fondo.webp'),
              fit: BoxFit.cover,
            ),
          ),
          width: double.infinity,
          height: double.infinity,

          child: const Stack(
            children: [
              Column(
                children: [
                  SizedBox(height: 150.0),
                  Center(
                    child: Text(
                      'Examen de Manejo DMV Español',
                      style: TextStyle(color: Colors.white, fontSize: 20.0),
                    ),
                  ),
                  Center(
                    child: Text(
                      'Versión 1.0.0',
                      style: TextStyle(color: Colors.white, fontSize: 12.0),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(40.0),
                    child: Image(
                      image: AssetImage('lib/assets/imagenes/conos.png'),
                      height: 80.0,
                    ),
                  ),
                ],
              ),
              Center(
                child: SizedBox(
                  width: 50,
                  height: 50,
                  child: CircularProgressIndicator(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
