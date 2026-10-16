// ===========================================================================
//  test/conversor_test.dart
// ---------------------------------------------------------------------------
//  Pruebas de lib/logica/conversor.dart y lib/modelos/base_numerica.dart.
// ===========================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:conversor_modular/logica/conversor.dart';
import 'package:conversor_modular/modelos/base_numerica.dart';
import 'package:conversor_modular/modelos/paso_division.dart';

void main() {
  group('BaseNumerica', () {
    test('el alfabeto se deriva del radix', () {
      expect(BaseNumerica.binario.alfabeto, '01');
      expect(BaseNumerica.octal.alfabeto, '01234567');
      expect(BaseNumerica.decimal.alfabeto, '0123456789');
      expect(BaseNumerica.hexadecimal.alfabeto, '0123456789ABCDEF');
    });

    test('la longitud del alfabeto es el radix', () {
      // Imposible que queden desincronizados: uno se calcula del otro.
      for (final BaseNumerica b in BaseNumerica.values) {
        expect(b.alfabeto.length, b.radix);
      }
    });

    test('aceptaDigito no distingue mayúsculas', () {
      expect(BaseNumerica.hexadecimal.aceptaDigito('f'), isTrue);
      expect(BaseNumerica.hexadecimal.aceptaDigito('F'), isTrue);
      expect(BaseNumerica.hexadecimal.aceptaDigito('G'), isFalse);
      expect(BaseNumerica.binario.aceptaDigito('2'), isFalse);
    });
  });

  group('desdeTexto', () {
    test('interpreta cada base correctamente', () {
      expect(Conversor.desdeTexto('1010', BaseNumerica.binario), 10);
      expect(Conversor.desdeTexto('777', BaseNumerica.octal), 511);
      expect(Conversor.desdeTexto('2026', BaseNumerica.decimal), 2026);
      expect(Conversor.desdeTexto('FF', BaseNumerica.hexadecimal), 255);
    });

    test('no distingue mayúsculas ni se traba con espacios', () {
      expect(Conversor.desdeTexto('  ff  ', BaseNumerica.hexadecimal), 255);
      expect(Conversor.desdeTexto('7e a', BaseNumerica.hexadecimal), 2026);
    });

    test('devuelve null en lugar de lanzar excepción', () {
      // La diferencia entre int.tryParse e int.parse. Con parse, cada tecla
      // mal puesta del usuario sería una excepción que habría que atrapar.
      expect(Conversor.desdeTexto('2', BaseNumerica.binario), isNull);
      expect(Conversor.desdeTexto('8', BaseNumerica.octal), isNull);
      expect(Conversor.desdeTexto('G', BaseNumerica.hexadecimal), isNull);
      expect(Conversor.desdeTexto('hola', BaseNumerica.decimal), isNull);
      expect(Conversor.desdeTexto('', BaseNumerica.decimal), isNull);
      expect(Conversor.desdeTexto('   ', BaseNumerica.decimal), isNull);
    });

    test('rechaza lo que no cabe en 32 bits', () {
      expect(
        Conversor.desdeTexto('FFFFFFFF', BaseNumerica.hexadecimal),
        4294967295,
      );
      expect(
        Conversor.desdeTexto('100000000', BaseNumerica.hexadecimal),
        isNull,
      );
    });
  });

  group('enTexto', () {
    test('escribe el mismo número en cada base', () {
      expect(Conversor.enTexto(255, BaseNumerica.binario), '11111111');
      expect(Conversor.enTexto(255, BaseNumerica.octal), '377');
      expect(Conversor.enTexto(255, BaseNumerica.decimal), '255');
      expect(Conversor.enTexto(255, BaseNumerica.hexadecimal), 'FF');
    });

    test('2026, el valor con el que arranca la app', () {
      expect(Conversor.enTexto(2026, BaseNumerica.binario), '11111101010');
      expect(Conversor.enTexto(2026, BaseNumerica.hexadecimal), '7EA');
    });

    test('hexadecimal en mayúsculas', () {
      expect(Conversor.enTexto(0xABCDEF, BaseNumerica.hexadecimal), 'ABCDEF');
    });

    test('ida y vuelta: desdeTexto(enTexto(v)) == v', () {
      // La propiedad más importante de todo el archivo. Si esto se cumple
      // para las cuatro bases, la conversión no pierde información.
      const List<int> valores = <int>[0, 1, 7, 8, 42, 255, 2026, 65535, 4294967295];
      for (final BaseNumerica b in BaseNumerica.values) {
        for (final int v in valores) {
          expect(
            Conversor.desdeTexto(Conversor.enTexto(v, b), b),
            v,
            reason: 'falló $v en ${b.nombre}',
          );
        }
      }
    });
  });

  group('Formato', () {
    test('enBinario rellena con ceros al ancho pedido', () {
      expect(Conversor.enBinario(5, 8), '00000101');
      expect(Conversor.enBinario(172, 8), '10101100');
      expect(Conversor.enBinario(1, 16).length, 16);
    });

    test('enBinario recorta si el valor no cabe', () {
      // 300 no cabe en un byte: queda 44.
      expect(Conversor.enBinario(300, 8), '00101100');
      expect(Conversor.enBinario(300, 8).length, 8);
    });

    test('agrupar agrupa desde la derecha', () {
      expect(Conversor.agrupar('10101100'), '1010 1100');
      // Longitud que no es múltiplo de 4: el grupo corto queda a la
      // IZQUIERDA, como se leen los números. Con `i % 4` quedaría al revés.
      expect(Conversor.agrupar('11111101010'), '111 1110 1010');
      expect(Conversor.agrupar('1'), '1');
      expect(Conversor.agrupar(''), '');
    });

    test('conPrefijo agrega la notación de código fuente', () {
      expect(Conversor.conPrefijo(255, BaseNumerica.hexadecimal), '0xFF');
      expect(Conversor.conPrefijo(10, BaseNumerica.binario), '0b1010');
      expect(Conversor.conPrefijo(8, BaseNumerica.octal), '0o10');
      expect(Conversor.conPrefijo(99, BaseNumerica.decimal), '99');
    });
  });

  group('Divisiones sucesivas', () {
    test('los pasos de 13 hacia binario', () {
      final List<PasoDivision> pasos = Conversor.pasosDivision(13, 2);
      expect(pasos.length, 4);

      expect(pasos[0].dividendo, 13);
      expect(pasos[0].cociente, 6);
      expect(pasos[0].resto, 1);

      expect(pasos[3].dividendo, 1);
      expect(pasos[3].cociente, 0);
      expect(pasos[3].resto, 1);
    });

    test('el cero tiene un paso, no cero pasos', () {
      // El while no se ejecutaría ni una vez y la tabla saldría vacía.
      final List<PasoDivision> pasos = Conversor.pasosDivision(0, 2);
      expect(pasos.length, 1);
      expect(pasos.first.resto, 0);
    });

    test('el último cociente siempre es cero', () {
      for (final int v in <int>[0, 1, 13, 255, 2026]) {
        expect(Conversor.pasosDivision(v, 2).last.cociente, 0);
      }
    });

    test('leerRestos reconstruye el número', () {
      expect(Conversor.leerRestos(Conversor.pasosDivision(13, 2), 2), '1101');
      expect(Conversor.leerRestos(Conversor.pasosDivision(255, 16), 16), 'FF');
      expect(Conversor.leerRestos(Conversor.pasosDivision(0, 2), 2), '0');
    });

    test('las divisiones sucesivas coinciden con toRadixString', () {
      // Esta es la prueba que justifica mostrar el algoritmo en pantalla:
      // lo que se enseña en el pizarrón da exactamente lo mismo que la
      // función de la biblioteca. Antes de modularizar, esta línea vivía
      // dentro de un widget y no se podía verificar.
      for (final BaseNumerica b in BaseNumerica.values) {
        for (final int v in <int>[0, 1, 7, 13, 64, 255, 2026, 65535]) {
          expect(
            Conversor.leerRestos(Conversor.pasosDivision(v, b.radix), b.radix),
            Conversor.enTexto(v, b),
            reason: 'falló $v en ${b.nombre}',
          );
        }
      }
    });
  });
}
