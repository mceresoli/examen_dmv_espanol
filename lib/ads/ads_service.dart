// [10/11/2026] Publicidad (AdMob) — mismo esquema que la app iOS "Examen de
// Manejo" de Argentina, aprobada por Apple:
//   1. El SplashScreen llama ensureAdsInitialized(): espera la respuesta del
//      permiso ATT (lo pide el lado nativo en AppDelegate.swift) y recién
//      entonces inicializa MobileAds y el App Open Ad.
//   2. El splash muestra el App Open Ad (cold start) y después navega.
//   3. MyApp observa el ciclo de vida: App Open Ad al volver de background.
//   4. Banner al pie del menú inicial e interstitials en transiciones
//      naturales (fin del examen, salir del estudio, señales y maniobras).
//   5. Bonificado opcional: "Repasar sólo mis errores" en el resultado.
// En los tests (o si el SDK falla) los anuncios quedan apagados y la app
// navega igual. — Claude (IA)

import 'dart:io';

import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../config/appConfig.dart';
import 'app_open_ad_manager.dart';
import 'interstitial_controller.dart';
import 'rewarded_controller.dart';

class AdsService {
  AdsService._();

  /// true cuando MobileAds quedó inicializado. Mientras sea false ningún
  /// anuncio se carga ni se muestra.
  static bool activo = false;
  static bool _iniciado = false;

  /// Plataforma con SDK de anuncios (no en tests ni en desktop).
  static bool get plataformaSoportada => !kIsWeb && (Platform.isIOS || Platform.isAndroid);

  /// Ids de prueba salvo en release con IS_DEBUG = false (así nunca se ven
  /// anuncios reales mientras desarrollas, que AdMob penaliza).
  static bool get usarIdsDePrueba => AppConfig.IS_DEBUG || !kReleaseMode;

  static String get appOpenId => Platform.isAndroid
      ? AppConfig.CARGA_APP_AD_ID_ANDROID_TEST
      : (usarIdsDePrueba ? AppConfig.CARGA_APP_AD_ID_IOS_TEST : AppConfig.CARGA_APP_AD_ID_IOS_PROD);

  static String get bannerId => Platform.isAndroid
      ? AppConfig.BANNER_AD_ID_ANDROID_TEST
      : (usarIdsDePrueba ? AppConfig.BANNER_AD_ID_IOS_TEST : AppConfig.BANNER_AD_ID_IOS_PROD);

  static String get interstitialId => Platform.isAndroid
      ? AppConfig.INTERSTITIAL_AD_ID_ANDROID_TEST
      : (usarIdsDePrueba ? AppConfig.INTERSTITIAL_AD_ID_IOS_TEST : AppConfig.INTERSTITIAL_AD_ID_IOS_PROD);

  static String get bonificadoId => Platform.isAndroid
      ? AppConfig.BONIFICADO_AD_ID_ANDROID_TEST
      : (usarIdsDePrueba ? AppConfig.BONIFICADO_AD_ID_IOS_TEST : AppConfig.BONIFICADO_AD_ID_IOS_PROD);

  /// ATT primero, anuncios después. Se llama una sola vez desde el splash.
  static Future<void> ensureAdsInitialized() async {
    if (_iniciado) return;
    _iniciado = true;
    if (!plataformaSoportada) return;

    if (Platform.isIOS) {
      try {
        // El prompt lo dispara AppDelegate.swift; acá esperamos la respuesta
        // (hasta ~30 s).
        var status = await AppTrackingTransparency.trackingAuthorizationStatus;
        var esperas = 0;
        while (status == TrackingStatus.notDetermined && esperas < 150) {
          await Future<void>.delayed(const Duration(milliseconds: 200));
          status = await AppTrackingTransparency.trackingAuthorizationStatus;
          esperas++;
        }
        debugPrint('[ATT] estado antes de iniciar anuncios: $status');
      } catch (e) {
        debugPrint('[ATT] no se pudo leer el estado: $e');
      }
    }

    try {
      await MobileAds.instance.initialize();
      activo = true;
      await kAppOpenAdManager.initialize();
      kInterstitial.precargar();
      kBonificado.precargar();
      debugPrint('[Ads] inicializados (${usarIdsDePrueba ? 'ids de prueba' : 'ids de producción'})');
    } catch (e) {
      activo = false;
      debugPrint('[Ads] no se pudieron inicializar: $e');
    }
  }
}
