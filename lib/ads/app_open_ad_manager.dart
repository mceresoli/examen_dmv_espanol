// [10/11/2026] App Open Ad — portado de appOpenAdsManager.dart de la app iOS
// "Examen de Manejo" (Argentina, versión aprobada con los fixes C1–C4 del
// 04/11/2026). — Claude (IA)
//
// - Cold start: showOnColdStart() desde el splash. Precarga y espera hasta
//   coldStartLoadWindow (8 s) a que el anuncio cargue; lo muestra sobre el
//   splash y navega en onComplete (nunca en el mismo frame que show()).
// - Retorno de background: MyApp llama notifyEnteringBackground() SOLO en
//   `paused` y tryShowOnForeground() en `resumed`. Exige un background real de
//   al menos 10 s, 45 s entre anuncios y como mucho 5 por sesión.
// - En el primer arranque después de instalar no se muestra al volver de
//   background (sí en el cold start, igual que la app aprobada).
// - Si el anuncio no carga o falla, la app sigue sin avisos ni reintentos.

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'ads_service.dart';

final AppOpenAdManager kAppOpenAdManager = AppOpenAdManager();

class AppOpenAdManager {
  AppOpenAdManager({
    this.minimumBackgroundDuration = const Duration(seconds: 10),
    this.minimumTimeBetweenAds = const Duration(seconds: 45),
    this.maxAdsPerSession = 5,
    this.loadTimeout = const Duration(seconds: 4),
    this.cachedAdExpiration = const Duration(hours: 4),
    this.coldStartLoadWindow = const Duration(seconds: 8),
    this.verboseLogging = kDebugMode,
  });

  static const String _kPrimerArranque = 'AppOpenAdManager.hasLaunchedBefore';

  final Duration minimumBackgroundDuration;
  final Duration minimumTimeBetweenAds;
  final int maxAdsPerSession;
  final Duration loadTimeout;
  final Duration cachedAdExpiration;
  final Duration coldStartLoadWindow;
  final bool verboseLogging;

  AppOpenAd? _ad;
  DateTime? _adLoadedAt;
  DateTime? _lastShownAt;
  DateTime? _backgroundEnteredAt;
  int _impressionsThisSession = 0;

  bool _isLoading = false;
  bool _isShowing = false;
  Object? _currentLoadToken;
  Timer? _loadTimeoutTimer;
  bool _coldStartDone = false;

  bool _firstLaunchKnown = false;
  bool _firstLaunchValue = true;

  /// true mientras hay un App Open en pantalla (el interstitial no se superpone).
  bool get mostrando => _isShowing;

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _firstLaunchValue = !(prefs.getBool(_kPrimerArranque) ?? false);
    _firstLaunchKnown = true;
    _log('initialize: primer arranque=$_firstLaunchValue');
  }

  Future<void> _markFirstLaunchDone() async {
    if (!_firstLaunchValue) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kPrimerArranque, true);
    _firstLaunchValue = false;
  }

  // ── API pública ──

  void notifyEnteringBackground() {
    if (_isShowing) return;
    _backgroundEnteredAt ??= DateTime.now();
  }

  /// Cold start: se llama UNA vez desde el splash. [onComplete] se invoca
  /// exactamente una vez (al cerrar el anuncio, si falla o si no hubo anuncio).
  Future<void> showOnColdStart({required VoidCallback onComplete}) async {
    var completed = false;
    void complete() {
      if (completed) return;
      completed = true;
      onComplete();
    }

    if (!AdsService.activo) {
      _coldStartDone = true;
      complete();
      return;
    }

    if (_isLoading && _currentLoadToken != null) {
      _armLoadTimeout(_currentLoadToken!, coldStartLoadWindow);
    } else {
      loadAd(timeout: coldStartLoadWindow);
    }
    final deadline = DateTime.now().add(coldStartLoadWindow);
    while (_ad == null && DateTime.now().isBefore(deadline)) {
      await Future<void>.delayed(const Duration(milliseconds: 100));
    }

    _coldStartDone = true;
    _backgroundEnteredAt = null;
    await _markFirstLaunchDone();

    if (_ad == null) {
      _log('cold start: el anuncio no cargó en ${coldStartLoadWindow.inSeconds} s');
      loadAd();
      complete();
      return;
    }
    if (_isAdExpired()) {
      _disposeCurrentAd();
      loadAd();
      complete();
      return;
    }
    _showLoadedAd(onComplete: complete);
  }

  Future<void> tryShowOnForeground() async {
    if (!AdsService.activo || !_coldStartDone || !_firstLaunchKnown) return;
    if (_isShowing) return;

    final bgAt = _backgroundEnteredAt;
    _backgroundEnteredAt = null;
    if (bgAt == null) return; // no hubo background real
    if (DateTime.now().difference(bgAt) < minimumBackgroundDuration) {
      _log('skip: background muy corto');
      loadAd();
      return;
    }

    final skip = _evaluateSkipReason();
    if (skip != null) {
      _log('skip: $skip');
      loadAd();
      return;
    }
    if (_ad == null || _isAdExpired()) {
      _disposeCurrentAd();
      loadAd();
      return;
    }
    _showLoadedAd();
  }

  void loadAd({Duration? timeout}) {
    if (!AdsService.activo) return;
    if (_isLoading) return;
    if (_ad != null && !_isAdExpired()) return;

    _isLoading = true;
    final token = Object();
    _currentLoadToken = token;
    _armLoadTimeout(token, timeout ?? loadTimeout);

    AppOpenAd.load(
      adUnitId: AdsService.appOpenId,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          if (!identical(_currentLoadToken, token)) {
            ad.dispose();
            return;
          }
          _loadTimeoutTimer?.cancel();
          _currentLoadToken = null;
          _isLoading = false;
          _ad = ad;
          _adLoadedAt = DateTime.now();
          _log('cargado');
        },
        onAdFailedToLoad: (error) {
          if (!identical(_currentLoadToken, token)) return;
          _loadTimeoutTimer?.cancel();
          _currentLoadToken = null;
          _isLoading = false;
          _ad = null;
          _adLoadedAt = null;
          _log('error de carga: ${error.message}');
        },
      ),
    );
  }

  void _armLoadTimeout(Object token, Duration timeout) {
    _loadTimeoutTimer?.cancel();
    _loadTimeoutTimer = Timer(timeout, () {
      if (identical(_currentLoadToken, token) && _isLoading) {
        _isLoading = false;
        _currentLoadToken = null;
      }
    });
  }

  // ── Reglas ──

  String? _evaluateSkipReason() {
    if (!_firstLaunchKnown) return 'primer arranque desconocido';
    if (_firstLaunchValue) return 'primer arranque';
    final last = _lastShownAt;
    if (last != null && DateTime.now().difference(last) < minimumTimeBetweenAds) return 'muy seguido';
    if (_impressionsThisSession >= maxAdsPerSession) return 'tope de la sesión';
    return null;
  }

  bool _isAdExpired() {
    final loaded = _adLoadedAt;
    return loaded == null || DateTime.now().difference(loaded) > cachedAdExpiration;
  }

  // ── Presentación ──

  void _showLoadedAd({VoidCallback? onComplete}) {
    final ad = _ad;
    if (_isShowing || ad == null) {
      onComplete?.call();
      return;
    }
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (_) => _isShowing = true,
      onAdImpression: (_) {
        _impressionsThisSession += 1;
        _lastShownAt = DateTime.now();
      },
      onAdFailedToShowFullScreenContent: (_, error) {
        _log('no se pudo mostrar: ${error.message}');
        _isShowing = false;
        _disposeCurrentAd();
        loadAd();
        onComplete?.call();
      },
      onAdDismissedFullScreenContent: (_) {
        _isShowing = false;
        _backgroundEnteredAt = null;
        _disposeCurrentAd();
        loadAd();
        onComplete?.call();
      },
    );
    ad.show();
  }

  void _disposeCurrentAd() {
    _ad?.dispose();
    _ad = null;
    _adLoadedAt = null;
  }

  void _log(String m) {
    if (verboseLogging) debugPrint('[AppOpenAd] $m');
  }
}
