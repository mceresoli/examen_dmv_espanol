// [10/11/2026] Interstitial — un solo bloque de anuncios para toda la app, con
// reglas de frecuencia por lugar (como ManiobrasAdController de la app
// argentina, generalizado). — Claude (IA)
//
// Uso: en lugar de navegar directo, la pantalla llama
//   kInterstitial.mostrarYNavegar(LugarInterstitial.maniobras, () => Navigator...);
// El controller decide si corresponde mostrar el anuncio; si lo muestra,
// navega al cerrarse (o si falla). Si no hay anuncio listo, navega enseguida.
//
// Reglas:
//  - Mínimo 90 s entre dos interstitials (en cualquier lugar).
//  - No se muestra si hay un App Open en pantalla.
//  - Por lugar: cuántas veces tiene que pasar antes del primer anuncio y cada
//    cuántas veces se repite (ver kReglasInterstitial).

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'ads_service.dart';
import 'app_open_ad_manager.dart';

enum LugarInterstitial {
  /// Al terminar un simulacro, antes de ver el resultado.
  finExamen,

  /// Al salir del estudio por tema.
  estudio,

  /// Al volver de un grupo de señales a la lista.
  seniales,

  /// Al volver de una maniobra al menú del examen práctico.
  maniobras,
}

class ReglaInterstitial {
  const ReglaInterstitial({required this.minimoAntesDelPrimero, required this.cada});

  /// Veces que tiene que pasar por ese lugar antes del primer anuncio.
  final int minimoAntesDelPrimero;

  /// Después de un anuncio, cada cuántas pasadas se puede mostrar otro.
  final int cada;
}

const Map<LugarInterstitial, ReglaInterstitial> kReglasInterstitial = {
  LugarInterstitial.finExamen: ReglaInterstitial(minimoAntesDelPrimero: 1, cada: 1),
  LugarInterstitial.estudio: ReglaInterstitial(minimoAntesDelPrimero: 1, cada: 1),
  LugarInterstitial.seniales: ReglaInterstitial(minimoAntesDelPrimero: 3, cada: 2),
  LugarInterstitial.maniobras: ReglaInterstitial(minimoAntesDelPrimero: 3, cada: 2),
};

final InterstitialController kInterstitial = InterstitialController();

class InterstitialController {
  InterstitialController({this.intervaloMinimo = const Duration(seconds: 90)});

  final Duration intervaloMinimo;

  InterstitialAd? _ad;
  bool _cargando = false;
  DateTime? _ultimo;
  final Map<LugarInterstitial, int> _pasadas = {};
  final Map<LugarInterstitial, int> _desdeUltimo = {};

  void precargar() {
    if (!AdsService.activo || _ad != null || _cargando) return;
    _cargando = true;
    InterstitialAd.load(
      adUnitId: AdsService.interstitialId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _ad = ad;
          _cargando = false;
        },
        onAdFailedToLoad: (error) {
          _ad = null;
          _cargando = false;
          debugPrint('[Interstitial] error de carga: ${error.message}');
        },
      ),
    );
  }

  /// Decide si muestra el anuncio y siempre termina llamando a [navegar]
  /// exactamente una vez.
  void mostrarYNavegar(LugarInterstitial lugar, VoidCallback navegar) {
    _pasadas[lugar] = (_pasadas[lugar] ?? 0) + 1;
    _desdeUltimo[lugar] = (_desdeUltimo[lugar] ?? 0) + 1;

    if (!_puedeMostrar(lugar)) {
      precargar();
      navegar();
      return;
    }

    final ad = _ad!;
    _ad = null;
    _ultimo = DateTime.now();
    _desdeUltimo[lugar] = 0;

    var navegado = false;
    void listo() {
      if (navegado) return;
      navegado = true;
      navegar();
    }

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        precargar();
        listo();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        precargar();
        listo();
      },
    );
    ad.show();
  }

  bool _puedeMostrar(LugarInterstitial lugar) {
    if (!AdsService.activo || _ad == null) return false;
    if (kAppOpenAdManager.mostrando) return false;
    final regla = kReglasInterstitial[lugar]!;
    if ((_pasadas[lugar] ?? 0) < regla.minimoAntesDelPrimero) return false;
    // Antes del primer anuncio en este lugar alcanza con el mínimo; después,
    // hay que esperar `cada` pasadas.
    final huboAnuncioAca = (_pasadas[lugar] ?? 0) > (_desdeUltimo[lugar] ?? 0);
    if (huboAnuncioAca && (_desdeUltimo[lugar] ?? 0) < regla.cada) return false;
    final ultimo = _ultimo;
    if (ultimo != null && DateTime.now().difference(ultimo) < intervaloMinimo) return false;
    return true;
  }

  @visibleForTesting
  void reiniciarParaTest() {
    _pasadas.clear();
    _desdeUltimo.clear();
    _ultimo = null;
  }
}
