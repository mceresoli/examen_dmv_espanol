// [10/11/2026] Banner al pie de pantalla (como en initial_page de la app
// argentina). No ocupa lugar hasta que el anuncio carga. — Claude (IA)

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'ads_service.dart';

class BannerInferior extends StatefulWidget {
  const BannerInferior({super.key});

  @override
  State<BannerInferior> createState() => _BannerInferiorState();
}

class _BannerInferiorState extends State<BannerInferior> {
  BannerAd? _banner;
  bool _cargado = false;

  @override
  void initState() {
    super.initState();
    if (!AdsService.activo) return;
    _banner = BannerAd(
      size: AdSize.banner,
      adUnitId: AdsService.bannerId,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          if (mounted) setState(() => _cargado = true);
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          _banner = null;
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    _banner?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final b = _banner;
    if (!_cargado || b == null) return const SizedBox.shrink();
    return SizedBox(
      width: b.size.width.toDouble(),
      height: b.size.height.toDouble(),
      child: AdWidget(ad: b),
    );
  }
}
