class AppConfig {
  static bool IS_DEBUG = true;

  // [10/11/2026] ID de la app en AdMob (va también en ios/Runner/Info.plist,
  // clave GADApplicationIdentifier). — Claude (IA)
  static const String APP_ID_IOS = 'ca-app-pub-2267138103291790~4625232483';

  // CREDENCIALES DE PRODUCCION
  static const String CARGA_APP_AD_ID_IOS_PROD =
      'ca-app-pub-2267138103291790/4842735231';
  static const String BANNER_AD_ID_IOS_PROD =
      'ca-app-pub-2267138103291790/4675214273';
  static const String INTERSTITIAL_AD_ID_IOS_PROD =
      'ca-app-pub-2267138103291790/3801116304';

  static const String BONIFICADO_AD_ID_IOS_PROD =
      'ca-app-pub-2267138103291790/1175787112';

  // CREDENCIALES DE PRUEBA
  // [10/11/2026] Cambiados a los ids de prueba de Google para iOS: los que
  // estaban (…/9257395921, …/6300978111, …/1033173712) son los de Android y en
  // iPhone no cargan. Los de Android quedaron abajo para el emulador. — Claude (IA)
  static const String CARGA_APP_AD_ID_IOS_TEST =
      'ca-app-pub-3940256099942544/5575463023';
  static const String BANNER_AD_ID_IOS_TEST =
      'ca-app-pub-3940256099942544/2934735716';
  static const String INTERSTITIAL_AD_ID_IOS_TEST =
      'ca-app-pub-3940256099942544/4411468910';
  // [10/11/2026] Bonificado de prueba de Google para iOS. — Claude (IA)
  static const String BONIFICADO_AD_ID_IOS_TEST =
      'ca-app-pub-3940256099942544/1712485313';

  // [10/11/2026] Solo para probar en el emulador Android (la app se publica
  // solo en iOS): siempre anuncios de prueba. — Claude (IA)
  static const String CARGA_APP_AD_ID_ANDROID_TEST =
      'ca-app-pub-3940256099942544/9257395921';
  static const String BANNER_AD_ID_ANDROID_TEST =
      'ca-app-pub-3940256099942544/6300978111';
  static const String INTERSTITIAL_AD_ID_ANDROID_TEST =
      'ca-app-pub-3940256099942544/1033173712';
  static const String BONIFICADO_AD_ID_ANDROID_TEST =
      'ca-app-pub-3940256099942544/5224354917';
}
