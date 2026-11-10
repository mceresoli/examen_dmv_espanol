// [10/11/2026] Prueba del examen práctico: datos (imágenes y fuentes), menú por
// estado, maniobra paso a paso, idioma y frases del examinador.
// Correr con: flutter test test/practico_test.dart — Claude (IA)

import 'dart:io';

import 'package:examen_manejo_dmv_espanol/pages/pages.dart';
import 'package:examen_manejo_dmv_espanol/provider/examen_provider.dart';
import 'package:examen_manejo_dmv_espanol/routes/routes.dart';
import 'package:examen_manejo_dmv_espanol/services/banco_preguntas_service.dart';
import 'package:examen_manejo_dmv_espanol/services/practico_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('datos del examen práctico', () async {
    TestWidgetsFlutterBinding.ensureInitialized();
    final srv = PracticoService.instancia;
    await srv.cargar();
    expect(srv.maniobras.length, greaterThanOrEqualTo(8));
    expect(srv.frases.length, greaterThan(20));
    final ids = <String>{};
    for (final m in srv.maniobras) {
      expect(ids.add(m.id), isTrue, reason: 'id repetido ${m.id}');
      expect(m.pasos, isNotEmpty, reason: m.id);
      expect(m.fuentes, isNotEmpty, reason: '${m.id} sin fuente oficial');
      for (final p in m.pasos) {
        expect(p.texto.tieneIngles, isTrue, reason: m.id);
        if (p.rutaImagen != null) expect(File(p.rutaImagen!).existsSync(), isTrue, reason: p.rutaImagen);
      }
    }
    for (final codigo in const ['CA', 'TX', 'FL']) {
      final e = srv.evaluacion(codigo);
      expect(e, isNotNull, reason: codigo);
      expect(e!.maniobras.every((id) => srv.maniobra(id) != null), isTrue, reason: codigo);
      expect(srv.ordenadasPara(codigo).first.id, e.maniobras.first);
      expect(srv.ordenadasPara(codigo).length, srv.maniobras.length);
    }
  });

  for (final tam in const [Size(390, 844), Size(320, 568)]) {
    testWidgets('examen práctico en ${tam.width.toInt()}x${tam.height.toInt()}', (tester) async {
      SharedPreferences.setMockInitialValues({'estado_eeuu': 'TX'});
      await tester.runAsync(() => BancoPreguntasService.instancia.cargar());
      await tester.runAsync(() => PracticoService.instancia.cargar());
      final prov = ExamenProvider();
      await tester.runAsync(prov.cargarPreferencias);
      await tester.binding.setSurfaceSize(tam);
      await tester.pumpWidget(ChangeNotifierProvider.value(
        value: prov,
        child: MaterialApp(routes: appRoutes, home: const PracticoPage()),
      ));
      await tester.pumpAndSettle();
      expect(find.text('Qué te evalúan en Texas'), findsOneWidget);

      await tester.scrollUntilVisible(find.text('Estacionamiento en paralelo'), 120,
          scrollable: find.byType(Scrollable).first);
      expect(find.text('Se evalúa en Texas'), findsWidgets);
      await tester.ensureVisible(find.text('Estacionamiento en paralelo'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Estacionamiento en paralelo'));
      await tester.pumpAndSettle();
      expect(find.byType(ManiobraPage), findsOneWidget);
      expect(find.text('1'), findsOneWidget);
      expect(find.textContaining('Busca un espacio'), findsOneWidget);

      // Cambio a inglés y vuelta.
      await tester.tap(find.text('EN'));
      await tester.pumpAndSettle();
      expect(find.text('Parallel parking'), findsOneWidget);
      await tester.tap(find.text('ES'));
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(find.textContaining('Manual de Texas'), 200,
          scrollable: find.byType(Scrollable).first);
      expect(find.text('FUENTE OFICIAL'), findsOneWidget);
      expect(find.textContaining('Manual de Texas'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.arrow_back_rounded).first);
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(find.text('Frases del examinador'), 150,
          scrollable: find.byType(Scrollable).first);
      await tester.ensureVisible(find.text('Frases del examinador'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Frases del examinador'));
      await tester.pumpAndSettle();
      expect(find.byType(FrasesExaminadorPage), findsOneWidget);
      expect(find.text('Dobla a la izquierda en la próxima intersección.'), findsOneWidget);
      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();
      expect(find.text('Dobla a la izquierda en la próxima intersección.'), findsNothing);
      await tester.scrollUntilVisible(find.text('"Pull over to the curb."'), 80,
          scrollable: find.byType(Scrollable).first);
      await tester.ensureVisible(find.text('"Pull over to the curb."'));
      await tester.pumpAndSettle();
      expect(find.text('Arrímate a la acera y para.'), findsNothing);
      await tester.tap(find.text('"Pull over to the curb."'));
      await tester.pumpAndSettle();
      expect(find.text('Arrímate a la acera y para.'), findsOneWidget);
    });
  }

  testWidgets('sin estado elegido pide elegirlo', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.runAsync(() => BancoPreguntasService.instancia.cargar());
    await tester.runAsync(() => PracticoService.instancia.cargar());
    final prov = ExamenProvider();
    await tester.runAsync(prov.cargarPreferencias);
    await tester.pumpWidget(ChangeNotifierProvider.value(
      value: prov,
      child: MaterialApp(routes: appRoutes, home: const PracticoPage()),
    ));
    await tester.pumpAndSettle();
    expect(find.text('Elige tu estado'), findsOneWidget);
    expect(find.text('Se evalúa en Texas'), findsNothing);
  });
}
