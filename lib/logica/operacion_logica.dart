// ===========================================================================
//  logica/operacion_logica.dart
// ---------------------------------------------------------------------------
//  Las seis operaciones de la tercera pestaña.
//
//  ESTO ES LO QUE MÁS GANÓ AL MODULARIZAR. En el monolito, las operaciones
//  eran una lista de listas con casts:
//
//      final operaciones = <List<Object>>[
//        ['A AND B', a & b, 'Un 1 solo donde AMBOS tienen 1...'],
//        ['A OR B',  a | b, '...'],
//      ];
//      ...
//      final nombre      = op[0] as String;   // <- cast a mano
//      final resultado   = op[1] as int;      // <- cast a mano
//      final explicacion = op[2] as String;   // <- cast a mano
//
//  Tres problemas: el orden de las columnas es una convención que solo vive
//  en la cabeza de quien lo escribió; equivocarse en un índice compila igual
//  y explota en ejecución; y los resultados se calculan TODOS cada vez que
//  se reconstruye el widget, estén visibles o no.
//
//  Con un enum mejorado el compilador se encarga de las tres cosas.
// ===========================================================================

import 'bits.dart';

enum OperacionLogica {
  and(
    'A AND B',
    'Un 1 solo donde AMBOS tienen 1. Sirve para enmascarar: apaga todo '
        'menos lo que interesa.',
  ),
  or(
    'A OR B',
    'Un 1 donde CUALQUIERA tiene 1. Sirve para encender banderas sin tocar '
        'las demás.',
  ),
  xor(
    'A XOR B',
    'Un 1 donde son DISTINTOS. Sirve para invertir bits y es la base de los '
        'sumadores y de los cifrados simples.',
  ),
  notA(
    'NOT A',
    'Invierte todos los bits de A. Con el ancho fijado equivale a '
        'restarle A al máximo: 255 − A para un byte.',
  ),
  desplazarIzquierda(
    'A << 1',
    'Desplaza a la izquierda: multiplica por dos. El bit que se sale por la '
        'izquierda se pierde.',
  ),
  desplazarDerecha(
    'A >> 1',
    'Desplaza a la derecha: divide entre dos descartando el resto.',
  );

  const OperacionLogica(this.simbolo, this.explicacion);

  /// Cómo se escribe la operación: `A AND B`, `A << 1`.
  final String simbolo;

  /// Para qué sirve en la práctica. Es material de clase, así que vive
  /// junto a la operación y no suelto en un widget.
  final String explicacion;

  /// ¿Usa el segundo operando? `NOT A` y los desplazamientos, no.
  /// La pantalla lo consulta para no mostrar una B que no participa.
  bool get usaB => this == and || this == or || this == xor;

  /// Aplica la operación.
  ///
  /// Un `switch` **como expresión** (Dart 3) sobre un enum es
  /// **exhaustivo**: si mañana agregamos `nand` y olvidamos su caso, esto
  /// no compila. Con la lista de listas del monolito, el olvido pasaba
  /// desapercibido hasta que alguien tocaba la pestaña.
  int aplicar(int a, int b, int anchoBits) => switch (this) {
        // &, | y ^ se usan acá a propósito: son el tema de la pestaña.
        // Es seguro porque los operandos son bytes, muy lejos del límite
        // de 32 bits donde web y Android dejan de coincidir.
        OperacionLogica.and => Bits.recortar(a & b, anchoBits),
        OperacionLogica.or => Bits.recortar(a | b, anchoBits),
        OperacionLogica.xor => Bits.recortar(a ^ b, anchoBits),

        // Para NOT usamos aritmética en lugar de ~: ver bits.dart.
        OperacionLogica.notA => Bits.complemento(a, anchoBits),

        OperacionLogica.desplazarIzquierda =>
          Bits.desplazarIzquierda(a, anchoBits),
        OperacionLogica.desplazarDerecha => Bits.desplazarDerecha(a),
      };
}
