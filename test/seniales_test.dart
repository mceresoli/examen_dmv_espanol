// [10/11/2026] Prueba del catálogo de señales: tipos, grupo, detalle y
// "Practicar estas señales". Correr con: flutter test test/seniales_test.dart
// — Claude (IA)

import 'package:examen_manejo_dmv_espanol/pages/pages.dart';
import 'package:examen_manejo_dmv_espanol/provider/examen_provider.dart';
import 'package:examen_manejo_dmv_espanol/routes/routes.dart';
import 'package:examen_manejo_dmv_espanol/services/banco_preguntas_service.dart';
import 'package:examen_manejo_dmv_espanol/services/catalogo_seniales_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  for (final tam in const [Size(390, 844), Size(320, 568)]) {
    testWidgets('catálogo de señales en ${tam.width.toInt()}x${tam.height.toInt()}', (tester) async {
      SharedPreferences.setMockInitialValues({'estado_eeuu': 'TX'});
      await tester.runAsync(() => BancoPreguntasService.instancia.cargar());
      await tester.runAsync(() => CatalogoSenialesService.instancia.cargar());
      final prov = ExamenProvider();
      await tester.runAsync(prov.cargarPreferencias);
      await tester.binding.setSurfaceSize(tam);
      await tester.pumpWidget(ChangeNotifierProvider.value(
        value: prov,
        child: MaterialApp(routes: appRoutes, home: const SenialesPage()),
      ));
      final cat = CatalogoSenialesService.instancia;
      expect(cat.total, greaterThan(200));
      expect(find.text('Señales de tránsito'), findsOneWidget);

      // Todos los grupos tienen al menos una pregunta para practicar.
      for (final t in cat.tipos) {
        for (final g in t.grupos) {
          final codigos = {for (final s in g.seniales) s.codigo};
          final n = prov.banco.paraEstado('TX').where((p) => p.tema == 'senales' && codigos.contains(p.senial)).length;
          expect(n, greaterThan(0), reason: g.id);
        }
      }

      await tester.scrollUntilVisible(find.text('Curvas'), 120, scrollable: find.byType(Scrollable).first);
      await tester.tap(find.text('Curvas'));
      await tester.pumpAndSettle();
      expect(find.textContaining('señales · toca una'), findsOneWidget);

      await tester.tap(find.text('Curva cerrada a la derecha'));
      await tester.pumpAndSettle();
      expect(find.text('MUTCD W1-1R'), findsOneWidget);
      expect(find.text('En inglés: Sharp turn to the right'), findsOneWidget);
      await tester.tap(find.text('Cerrar'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Practicar estas señales'));
      await tester.pumpAndSettle();
      final curvas = {for (final s in cat.grupo('curvas')!.seniales) s.codigo};
      final n = prov.banco.paraEstado('TX').where((p) => p.tema == 'senales' && curvas.contains(p.senial)).length;
      expect(find.textContaining('Pregunta 1 de $n'), findsOneWidget);
      await tester.tap(find.byIcon(Icons.arrow_back_rounded).first);
      await tester.pumpAndSettle();
      expect(find.text('Practicar estas señales'), findsOneWidget);
    });
  }
}
