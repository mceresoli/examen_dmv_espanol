// [10/11/2026] Reglas del pedido de reseña. Correr con:
// flutter test test/resena_test.dart — Claude (IA)

import 'package:examen_manejo_dmv_espanol/services/resena_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  final srv = ResenaService.instancia;
  setUp(srv.reiniciarParaTest);

  test('se pide al aprobar desde el 2do examen', () async {
    SharedPreferences.setMockInitialValues({});
    await srv.registrarExamen(aprobado: true);
    expect(srv.pendiente, isFalse, reason: 'primer examen');
    await srv.registrarExamen(aprobado: false);
    expect(srv.pendiente, isFalse, reason: 'no aprobó');
    await srv.registrarExamen(aprobado: true);
    expect(srv.pendiente, isTrue);
  });

  test('respeta el tope y los días entre pedidos', () async {
    SharedPreferences.setMockInitialValues({'resena.examenesTerminados': 5, 'resena.pedidos': 3});
    await srv.registrarExamen(aprobado: true);
    expect(srv.pendiente, isFalse, reason: 'ya se pidió 3 veces');

    final hace10Dias = DateTime.now().subtract(const Duration(days: 10)).millisecondsSinceEpoch;
    SharedPreferences.setMockInitialValues({'resena.examenesTerminados': 5, 'resena.pedidos': 1, 'resena.ultimoPedidoMs': hace10Dias});
    await srv.registrarExamen(aprobado: true);
    expect(srv.pendiente, isFalse, reason: 'pedido hace 10 días');

    final hace90Dias = DateTime.now().subtract(const Duration(days: 90)).millisecondsSinceEpoch;
    SharedPreferences.setMockInitialValues({'resena.examenesTerminados': 5, 'resena.pedidos': 1, 'resena.ultimoPedidoMs': hace90Dias});
    await srv.registrarExamen(aprobado: true);
    expect(srv.pendiente, isTrue);
  });
}
