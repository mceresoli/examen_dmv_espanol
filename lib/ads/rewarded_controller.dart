// [10/11/2026] Anuncio bonificado para "Repasar sólo mis errores", como en
// resultados_page de la app argentina: se precarga al iniciar los anuncios y
// después de cada uso. Si no hay anuncio listo, el repaso se regala (mejor
// que bloquear al usuario). — Claude (IA)

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'ads_service.dart';

enum ResultadoBonificado {
  /// Vio el anuncio completo: se entrega la recompensa.
  ganado,

  /// Cerró el anuncio antes de tiempo.
  cancelado,

  /// No había anuncio (sin red, error o anuncios apagados).
  noDisponible,
}

final RewardedController kBonificado = RewardedController();

class RewardedController {
  RewardedAd? _ad;
  bool _cargando = false;

  bool get listo => AdsService.activo && _ad != null;

  void precargar() {
    if (!AdsService.activo || _ad != null || _cargando) return;
    _cargando = true;
    RewardedAd.load(
      adUnitId: AdsService.bonificadoId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _ad = ad;
          _cargando = false;
        },
        onAdFailedToLoad: (error) {
          _ad = null;
          _cargando = false;
          debugPrint('[Bonificado] error de carga: ${error.message}');
        },
      ),
    );
  }

  Future<ResultadoBonificado> mostrar() {
    final ad = _ad;
    if (!AdsService.activo || ad == null) {
      precargar();
      return Future.value(ResultadoBonificado.noDisponible);
    }
    _ad = null;
    final completer = Completer<ResultadoBonificado>();
    var gano = false;
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        precargar();
        if (!completer.isCompleted) {
          completer.complete(gano ? ResultadoBonificado.ganado : ResultadoBonificado.cancelado);
        }
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        precargar();
        if (!completer.isCompleted) completer.complete(ResultadoBonificado.noDisponible);
      },
    );
    ad.show(onUserEarnedReward: (_, _) => gano = true);
    return completer.future;
  }
}
