// [10/11/2026] Anuncios apagados (como en los tests): la app navega igual y el
// splash pasa al menú a los 8 s. Correr con: flutter test test/ads_test.dart
// — Claude (IA)

import 'package:examen_manejo_dmv_espanol/ads/ads_service.dart';
import 'package:examen_manejo_dmv_espanol/ads/interstitial_controller.dart';
import 'package:examen_manejo_dmv_espanol/pages/pages.dart';
import 'package:examen_manejo_dmv_espanol/provider/examen_provider.dart';
import 'package:examen_manejo_dmv_espanol/routes/routes.dart';
import 'package:examen_manejo_dmv_espanol/services/banco_preguntas_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('sin anuncios, cada lugar navega una sola vez', () {
    expect(AdsService.activo, isFalse);
    kInterstitial.reiniciarParaTest();
    for (final lugar in LugarInterstitial.values) {
      var veces = 0;
      for (var i = 0; i < 5; i++) {
        kInterstitial.mostrarYNavegar(lugar, () => veces++);
      }
      expect(veces, 5, reason: lugar.name);
      expect(kReglasInterstitial[lugar], isNotNull);
    }
  });

  testWidgets('el splash pasa al menú sin anuncios', (tester) async {
    SharedPreferences.setMockInitialValues({'estado_eeuu': 'FL'});
    await tester.runAsync(() => BancoPreguntasService.instancia.cargar());
    final prov = ExamenProvider();
    await tester.runAsync(prov.cargarPreferencias);
    await tester.pumpWidget(ChangeNotifierProvider.value(
      value: prov,
      child: MaterialApp(routes: appRoutes, initialRoute: 'splash'),
    ));
    expect(find.byType(SplashScreen), findsOneWidget);
    await tester.pump(const Duration(seconds: 9));
    await tester.pumpAndSettle();
    expect(find.byType(InitialPage), findsOneWidget);
    expect(find.text('Iniciar nuevo examen'), findsOneWidget);
  });
}
