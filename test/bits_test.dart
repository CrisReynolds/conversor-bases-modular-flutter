// ===========================================================================
//  test/bits_test.dart
// ---------------------------------------------------------------------------
//  Pruebas de lib/logica/bits.dart. Corren sin emulador y sin navegador,
//  porque bits.dart no importa Flutter.
//
//  En Android Studio: clic derecho sobre el archivo -> Run.
//  En terminal:        flutter test
//
//  Y algo que no es menor: estas mismas pruebas se pueden correr compiladas
//  a JavaScript con
//        flutter test --platform chrome
//  Si pasan en las dos, está demostrado que la aritmética da el mismo
//  resultado en Android y en el navegador. Eso es exactamente lo que la
//  app afirma en la nota de plataforma, verificado en lugar de prometido.
// ===========================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:conversor_modular/logica/bits.dart';

void main() {
  group('Tabla de potencias', () {
    test('tiene 33 entradas, de 2^0 a 2^32', () {
      expect(Bits.potencias.length, 33);
    });

    test('los valores son las potencias de dos', () {
      expect(Bits.potencias[0], 1);
      expect(Bits.potencias[1], 2);
      expect(Bits.potencias[8], 256);
      expect(Bits.potencias[16], 65536);
      expect(Bits.potencias[31], 2147483648);
      expect(Bits.potencias[32], 4294967296);
    });

    test('2^32 es exacto, que es donde 1 << 32 falla en web', () {
      // Esta es la razón de existir de la tabla. La multiplicación
      // sucesiva es exacta; el desplazamiento no lo es en el navegador.
      expect(Bits.potencias[32], Bits.potencias[31] * 2);
    });

    test('es inmodificable', () {
      expect(() => Bits.potencias[0] = 99, throwsUnsupportedError);
    });
  });

  group('Rangos', () {
    test('máximo sin signo', () {
      expect(Bits.maxSinSigno(8), 255);
      expect(Bits.maxSinSigno(16), 65535);
      expect(Bits.maxSinSigno(32), 4294967295);
    });

    test('rango con signo es asimétrico', () {
      // Hay un negativo más que positivos: el cero ocupa un lugar del
      // lado positivo. Es la pregunta de examen clásica.
      expect(Bits.minConSigno(8), -128);
      expect(Bits.maxConSigno(8), 127);
      expect(Bits.minConSigno(16), -32768);
      expect(Bits.maxConSigno(16), 32767);
      expect(Bits.minConSigno(32), -2147483648);
      expect(Bits.maxConSigno(32), 2147483647);
    });

    test('el máximo sin signo es todo unos', () {
      for (final int ancho in <int>[8, 16, 32]) {
        expect(Bits.cuentaDeUnos(Bits.maxSinSigno(ancho), ancho), ancho);
      }
    });
  });

  group('recortar', () {
    test('descarta lo que se sale del ancho', () {
      expect(Bits.recortar(300, 8), 44); // 300 - 256
      expect(Bits.recortar(0x12345, 16), 0x2345);
      expect(Bits.recortar(255, 8), 255);
    });

    test('devuelve un valor no negativo incluso para entradas negativas', () {
      // Acá se ve por qué usamos % y no &: el resto con divisor positivo
      // siempre cae en [0, divisor) en las dos plataformas.
      expect(Bits.recortar(-173, 16), 65363); // 65536 - 173
      expect(Bits.recortar(-1, 8), 255);
    });

    test('2^31 sobrevive al recorte de 32 bits', () {
      // Con `valor & 0xFFFFFFFF` este caso es justo el que puede volverse
      // negativo al compilar a JavaScript.
      expect(Bits.recortar(2147483648, 32), 2147483648);
      expect(Bits.recortar(4294967295, 32), 4294967295);
    });

    test('recortar dos veces es igual que recortar una', () {
      for (final int v in <int>[0, 1, 172, 65535, 2147483648]) {
        expect(Bits.recortar(Bits.recortar(v, 16), 16), Bits.recortar(v, 16));
      }
    });
  });

  group('Complemento a dos', () {
    test('todo unos es menos uno', () {
      expect(Bits.comoConSigno(255, 8), -1);
      expect(Bits.comoConSigno(65535, 16), -1);
      expect(Bits.comoConSigno(4294967295, 32), -1);
    });

    test('el bit más significativo marca el signo', () {
      expect(Bits.comoConSigno(127, 8), 127); // 0111 1111
      expect(Bits.comoConSigno(128, 8), -128); // 1000 0000
    });

    test('los valores chicos no cambian', () {
      expect(Bits.comoConSigno(0, 8), 0);
      expect(Bits.comoConSigno(42, 8), 42);
    });

    test('nunca sale del rango con signo', () {
      for (int v = 0; v <= 255; v++) {
        final int s = Bits.comoConSigno(v, 8);
        expect(s, inInclusiveRange(Bits.minConSigno(8), Bits.maxConSigno(8)));
      }
    });
  });

  group('Bits individuales', () {
    // 172 = 1010 1100 -> bits encendidos: 7, 5, 3, 2
    const int valor = 172;

    test('bitEncendido lee la posición correcta', () {
      expect(Bits.bitEncendido(valor, 0), isFalse);
      expect(Bits.bitEncendido(valor, 1), isFalse);
      expect(Bits.bitEncendido(valor, 2), isTrue);
      expect(Bits.bitEncendido(valor, 3), isTrue);
      expect(Bits.bitEncendido(valor, 4), isFalse);
      expect(Bits.bitEncendido(valor, 5), isTrue);
      expect(Bits.bitEncendido(valor, 6), isFalse);
      expect(Bits.bitEncendido(valor, 7), isTrue);
    });

    test('encender un bit suma su peso', () {
      expect(Bits.conmutarBit(valor, 0, 8), 173); // 172 + 1
      expect(Bits.conmutarBit(valor, 1, 8), 174); // 172 + 2
    });

    test('apagar un bit resta su peso', () {
      expect(Bits.conmutarBit(valor, 2, 8), 168); // 172 - 4
      expect(Bits.conmutarBit(valor, 7, 8), 44); // 172 - 128
    });

    test('conmutar dos veces vuelve al original', () {
      for (int p = 0; p < 8; p++) {
        expect(Bits.conmutarBit(Bits.conmutarBit(valor, p, 8), p, 8), valor);
      }
    });

    test('conmutar el bit 31 funciona con 32 bits', () {
      // El caso límite: 2^31 no cabe en un int de 32 bits CON SIGNO, que
      // es como JavaScript trata los operandos de los operadores bit a bit.
      expect(Bits.conmutarBit(0, 31, 32), 2147483648);
      expect(Bits.conmutarBit(2147483648, 31, 32), 0);
    });
  });

  group('complemento (NOT dentro del ancho)', () {
    test('invierte todos los bits', () {
      expect(Bits.complemento(172, 8), 83); // 255 - 172
      expect(Bits.complemento(0, 8), 255);
      expect(Bits.complemento(255, 8), 0);
    });

    test('NOT de cero en 32 bits da el máximo sin signo', () {
      // Con el operador ~ esto daría -1 en Android y 4294967295 en web.
      // Con aritmética da lo mismo en las dos.
      expect(Bits.complemento(0, 32), 4294967295);
    });

    test('aplicarlo dos veces vuelve al original', () {
      for (final int v in <int>[0, 1, 172, 255]) {
        expect(Bits.complemento(Bits.complemento(v, 8), 8), v);
      }
    });
  });

  group('Desplazamientos', () {
    test('a la izquierda multiplica por dos', () {
      expect(Bits.desplazarIzquierda(1, 8), 2);
      expect(Bits.desplazarIzquierda(43, 8), 86);
    });

    test('a la izquierda se pierde lo que sale del ancho', () {
      expect(Bits.desplazarIzquierda(128, 8), 0); // 256 no cabe en un byte
      expect(Bits.desplazarIzquierda(172, 8), 88); // 344 - 256
    });

    test('a la derecha divide entre dos descartando el resto', () {
      expect(Bits.desplazarDerecha(172), 86);
      expect(Bits.desplazarDerecha(1), 0);
      expect(Bits.desplazarDerecha(0), 0);
    });
  });

  group('cuentaDeUnos y descomponer', () {
    test('cuenta los bits encendidos', () {
      expect(Bits.cuentaDeUnos(172, 8), 4); // 1010 1100
      expect(Bits.cuentaDeUnos(0, 8), 0);
      expect(Bits.cuentaDeUnos(255, 8), 8);
      expect(Bits.cuentaDeUnos(4294967295, 32), 32);
    });

    test('descompone en potencias de dos, de mayor a menor', () {
      expect(Bits.descomponer(172, 8), <int>[128, 32, 8, 4]);
      expect(Bits.descomponer(0, 8), isEmpty);
      expect(Bits.descomponer(1, 8), <int>[1]);
    });

    test('la suma de la descomposición es el valor', () {
      for (int v = 0; v <= 255; v++) {
        final int suma = Bits.descomponer(v, 8)
            .fold<int>(0, (int acumulado, int p) => acumulado + p);
        expect(suma, v);
      }
    });

    test('la descomposición tiene tantos términos como unos', () {
      for (int v = 0; v <= 255; v++) {
        expect(Bits.descomponer(v, 8).length, Bits.cuentaDeUnos(v, 8));
      }
    });
  });
}
