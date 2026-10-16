// ===========================================================================
//  test/operacion_logica_test.dart
// ---------------------------------------------------------------------------
//  Pruebas de lib/logica/operacion_logica.dart.
//
//  Con la lista de listas del monolito, estas pruebas eran imposibles: los
//  resultados se calculaban dentro del build() del widget. Mover las
//  operaciones a un enum con un método no fue solo cosmética — las hizo
//  verificables.
// ===========================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:conversor_modular/logica/operacion_logica.dart';

void main() {
  // Los valores con los que arranca la app.
  const int a = 0xAC; // 172 = 1010 1100
  const int b = 0x3F; // 63  = 0011 1111
  const int bits = 8;

  group('Resultados de cada operación', () {
    test('AND deja un 1 solo donde ambos tienen 1', () {
      // 1010 1100 AND 0011 1111 = 0010 1100
      expect(OperacionLogica.and.aplicar(a, b, bits), 0x2C);
    });

    test('OR deja un 1 donde cualquiera tiene 1', () {
      // 1010 1100 OR 0011 1111 = 1011 1111
      expect(OperacionLogica.or.aplicar(a, b, bits), 0xBF);
    });

    test('XOR deja un 1 donde son distintos', () {
      // 1010 1100 XOR 0011 1111 = 1001 0011
      expect(OperacionLogica.xor.aplicar(a, b, bits), 0x93);
    });

    test('NOT A invierte todos los bits de A', () {
      expect(OperacionLogica.notA.aplicar(a, b, bits), 0x53); // 255 - 172
    });

    test('los desplazamientos multiplican y dividen entre dos', () {
      expect(OperacionLogica.desplazarIzquierda.aplicar(a, b, bits), 88);
      expect(OperacionLogica.desplazarDerecha.aplicar(a, b, bits), 86);
    });
  });

  group('Propiedades del álgebra de Boole', () {
    test('x AND x == x  (idempotencia)', () {
      for (int x = 0; x <= 255; x++) {
        expect(OperacionLogica.and.aplicar(x, x, bits), x);
      }
    });

    test('x OR 0 == x  (elemento neutro)', () {
      for (int x = 0; x <= 255; x++) {
        expect(OperacionLogica.or.aplicar(x, 0, bits), x);
      }
    });

    test('x AND 0 == 0  (elemento absorbente)', () {
      for (int x = 0; x <= 255; x++) {
        expect(OperacionLogica.and.aplicar(x, 0, bits), 0);
      }
    });

    test('x XOR x == 0  (por eso se usa para limpiar un registro)', () {
      for (int x = 0; x <= 255; x++) {
        expect(OperacionLogica.xor.aplicar(x, x, bits), 0);
      }
    });

    test('x XOR 255 == NOT x  (XOR con todo unos invierte)', () {
      for (int x = 0; x <= 255; x++) {
        expect(
          OperacionLogica.xor.aplicar(x, 255, bits),
          OperacionLogica.notA.aplicar(x, 0, bits),
        );
      }
    });

    test('ley de De Morgan: NOT(x AND y) == (NOT x) OR (NOT y)', () {
      for (int x = 0; x <= 255; x += 17) {
        for (int y = 0; y <= 255; y += 23) {
          final int izquierda = OperacionLogica.notA.aplicar(
            OperacionLogica.and.aplicar(x, y, bits),
            0,
            bits,
          );
          final int derecha = OperacionLogica.or.aplicar(
            OperacionLogica.notA.aplicar(x, 0, bits),
            OperacionLogica.notA.aplicar(y, 0, bits),
            bits,
          );
          expect(izquierda, derecha, reason: 'falló con x=$x y=$y');
        }
      }
    });
  });

  group('El enum como fuente única de verdad', () {
    test('ninguna operación se sale del ancho', () {
      for (final OperacionLogica op in OperacionLogica.values) {
        expect(
          op.aplicar(a, b, bits),
          inInclusiveRange(0, 255),
          reason: '${op.simbolo} devolvió algo fuera de un byte',
        );
      }
    });

    test('toda operación tiene símbolo y explicación', () {
      for (final OperacionLogica op in OperacionLogica.values) {
        expect(op.simbolo, isNotEmpty);
        expect(op.explicacion.length, greaterThan(20));
      }
    });

    test('usaB distingue las binarias de las unarias', () {
      expect(OperacionLogica.and.usaB, isTrue);
      expect(OperacionLogica.or.usaB, isTrue);
      expect(OperacionLogica.xor.usaB, isTrue);
      expect(OperacionLogica.notA.usaB, isFalse);
      expect(OperacionLogica.desplazarIzquierda.usaB, isFalse);
      expect(OperacionLogica.desplazarDerecha.usaB, isFalse);
    });

    test('las operaciones unarias ignoran B', () {
      for (final OperacionLogica op in OperacionLogica.values) {
        if (op.usaB) continue;
        expect(
          op.aplicar(a, 0, bits),
          op.aplicar(a, 255, bits),
          reason: '${op.simbolo} no debería mirar B',
        );
      }
    });
  });
}
