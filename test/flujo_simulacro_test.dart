// [06/11/2026] Prueba de punta a punta del simulacro: elegir estado, responder
// 20 preguntas (con una saltada), resultado, repaso y vuelta al inicio.
// Correr con: flutter test test/flujo_simulacro_test.dart — Claude (IA)

import 'package:examen_manejo_dmv_espanol/model/model.dart';
import 'package:examen_manejo_dmv_espanol/pages/pages.dart';
import 'package:examen_manejo_dmv_espanol/provider/examen_provider.dart';
import 'package:examen_manejo_dmv_espanol/routes/routes.dart';
import 'package:examen_manejo_dmv_espanol/services/banco_preguntas_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('flujo completo del simulacro', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.runAsync(() => BancoPreguntasService.instancia.cargar());
    final prov = ExamenProvider();
    await tester.runAsync(prov.cargarPreferencias);
    await tester.binding.setSurfaceSize(const Size(390, 844));
    await tester.pumpWidget(ChangeNotifierProvider.value(
      value: prov,
      child: MaterialApp(routes: appRoutes, home: const InitialPage()),
    ));
    expect(find.text('Primero elige tu estado'), findsOneWidget);
    await tester.tap(find.text('Iniciar nuevo examen'));
    await tester.pumpAndSettle();
    expect(find.text('Elige tu estado'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Florida'), 80, scrollable: find.byType(Scrollable).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Florida'));
    await tester.pumpAndSettle();
    // Cantidad del simulacro: 15, o 5 si AppConfig.IS_DEBUG.
    final fl = BancoPreguntasService.instancia.estados.firstWhere((e) => e.codigo == 'FL');
    final necesarios = fl.aciertosPara(fl.preguntasSimulacro);
    await tester.scrollUntilVisible(find.textContaining('necesitas $necesarios correctas'), 80, scrollable: find.byType(Scrollable).first);
    expect(find.textContaining('necesitas $necesarios correctas'), findsOneWidget);
    await tester.runAsync(() async {
      await tester.tap(find.text('Iniciar examen'));
      await Future.delayed(const Duration(milliseconds: 200));
    });
    await tester.pumpAndSettle();
    // Puede ser menor que preguntasSimulacro si el banco no alcanza.
    final n = prov.examen!.preguntas.length;
    expect(find.text('Pregunta 1 de $n'), findsOneWidget);
    // EN toggle
    await tester.runAsync(() async { await tester.tap(find.text('EN')); });
    await tester.pumpAndSettle();
    expect(prov.idioma, Idioma.en);
    await tester.runAsync(() async { await tester.tap(find.text('ES')); });
    await tester.pumpAndSettle();
    // responder siempre la correcta salvo 1 equivocada y 1 saltada
    // (solo si sobra margen para seguir aprobando).
    final margen = n - prov.examen!.aciertosNecesarios;
    final saltar = margen >= 1 ? 1 : -1;
    final errar = margen >= 2 ? 3 : -1;
    for (var i = 0; i < n; i++) {
      final pe = prov.actual;
      if (i == saltar) {
        await tester.tap(find.text('Saltar pregunta'));
      } else {
        final idx = i == errar ? (pe.indiceCorrecto + 1) % pe.opciones.length : pe.indiceCorrecto;
        await tester.ensureVisible(find.text(pe.opciones[idx].es).first);
        await tester.pumpAndSettle();
        await tester.tap(find.text(pe.opciones[idx].es).first);
      }
      await tester.pumpAndSettle();
    }
    expect(find.text('Resultados'), findsOneWidget);
    expect(prov.examen!.aciertos, n - (saltar >= 0 ? 1 : 0) - (errar >= 0 ? 1 : 0));
    expect(find.text('¡Felicidades!'), findsOneWidget);
    expect(find.text('Para aprobar necesitabas ${prov.examen!.aciertosNecesarios} de $n'), findsOneWidget);
    await tester.tap(find.text('Ver respuestas'));
    await tester.pumpAndSettle();
    expect(find.text('Repaso · 1 de $n'), findsOneWidget);
    for (var i = 0; i < n - 1; i++) {
      await tester.tap(find.byIcon(Icons.arrow_forward_rounded));
      await tester.pumpAndSettle();
    }
    expect(find.text('Repaso · $n de $n'), findsOneWidget);
    await tester.tap(find.text('Finalizar'));
    await tester.pumpAndSettle();
    // [10/11/2026] Repaso sólo de errores (sin anuncios en el test se regala). — Claude (IA)
    final malas = prov.examen!.incorrectas;
    if (malas > 0) {
      await tester.tap(find.text('Repasar sólo mis errores ($malas)'));
      await tester.pumpAndSettle();
      expect(find.text('Tus errores · 1 de $malas'), findsOneWidget);
      expect(find.text('Incorrecta').evaluate().length + find.text('Saltada').evaluate().length, greaterThan(0));
      expect(find.text('Correcta'), findsNothing);
      await tester.tap(find.text('Finalizar'));
      await tester.pumpAndSettle();
    }
    await tester.tap(find.text('Cerrar y volver al inicio'));
    await tester.pumpAndSettle();
    expect(find.text('Ver mi último examen'), findsOneWidget);
    expect(find.textContaining('apruebas con $necesarios en Florida'), findsOneWidget);
  });
}
