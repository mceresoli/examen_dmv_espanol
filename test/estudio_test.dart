// [10/11/2026] Prueba del estudio por tema: lista de temas, responder con
// explicación, resumen y "Repasar mis errores".
// Correr con: flutter test test/estudio_test.dart — Claude (IA)

import 'package:examen_manejo_dmv_espanol/pages/pages.dart';
import 'package:examen_manejo_dmv_espanol/provider/examen_provider.dart';
import 'package:examen_manejo_dmv_espanol/routes/routes.dart';
import 'package:examen_manejo_dmv_espanol/services/banco_preguntas_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  for (final tam in const [Size(390, 844), Size(320, 568)]) {
    testWidgets('estudio por tema en ${tam.width.toInt()}x${tam.height.toInt()}', (tester) async {
      SharedPreferences.setMockInitialValues({'estado_eeuu': 'FL'});
      await tester.runAsync(() => BancoPreguntasService.instancia.cargar());
      final prov = ExamenProvider();
      await tester.runAsync(prov.cargarPreferencias);
      await tester.binding.setSurfaceSize(tam);
      await tester.pumpWidget(ChangeNotifierProvider.value(
        value: prov,
        child: MaterialApp(routes: appRoutes, home: const EstudioTemasPage()),
      ));
      expect(find.text('Todos los temas'), findsOneWidget);

      await tester.scrollUntilVisible(find.text('Estacionamiento'), 80, scrollable: find.byType(Scrollable).first);
      await tester.tap(find.text('Estacionamiento'));
      await tester.pumpAndSettle();

      final total = prov.banco.porTema('FL', 'estacionamiento').length;
      expect(find.text('Pregunta 1 de $total · 0 correctas'), findsOneWidget);

      // Recorre todas: la primera mal, una con "Ver la respuesta", el resto bien.
      for (var i = 0; i < total; i++) {
        final estado = tester.state(find.byType(EstudioPage)) as dynamic;
        final pe = (estado.preguntasParaTest as List)[i];
        if (i == 1) {
          await tester.tap(find.text('Ver la respuesta'));
        } else {
          final idx = i == 0 ? (pe.indiceCorrecto + 1) % pe.opciones.length : pe.indiceCorrecto;
          final f = find.text(pe.opciones[idx].es as String).first;
          await tester.ensureVisible(f);
          await tester.pumpAndSettle();
          await tester.tap(f);
        }
        await tester.pumpAndSettle();
        expect(find.text(i == 0 ? 'Incorrecto' : (i == 1 ? 'Esta es la respuesta correcta' : '¡Correcto!')), findsOneWidget);
        expect(find.text(pe.pregunta.explicacion.es as String), findsOneWidget);
        await tester.tap(find.text(i < total - 1 ? 'Siguiente pregunta' : 'Ver resumen'));
        await tester.pumpAndSettle();
      }
      expect(find.text('${total - 2} de $total correctas'), findsOneWidget);
      await tester.tap(find.text('Repasar mis errores'));
      await tester.pumpAndSettle();
      expect(find.text('Pregunta 1 de 2 · 0 correctas'), findsOneWidget);
    });
  }
}
