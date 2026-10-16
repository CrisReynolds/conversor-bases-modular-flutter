// ===========================================================================
//  logica/conversor.dart
// ---------------------------------------------------------------------------
//  Texto <-> número, y el formato con el que se muestra. Dart puro.
//
//  En el monolito esto estaba junto con las operaciones de bits en una sola
//  clase `Conversor` de 120 líneas. Son dos responsabilidades distintas:
//
//    conversor.dart  -> cómo se ESCRIBE un número (notación, formato)
//    bits.dart       -> cómo se MANIPULA un número (ancho, bits, rangos)
//
//  La prueba de que la separación es real: este archivo importa `bits.dart`
//  solo para una línea (el tope de valor aceptado), y `bits.dart` no sabe
//  que este archivo existe.
// ===========================================================================

import '../modelos/base_numerica.dart';
import '../modelos/paso_division.dart';
import 'bits.dart';

class Conversor {
  const Conversor._();

  // -------------------------------------------------------------------------
  //  Texto -> número
  // -------------------------------------------------------------------------

  /// Devuelve `null` si el texto no representa un número válido en [base].
  ///
  /// `int.tryParse` con `radix` hace el trabajo pesado y **nunca lanza
  /// excepción**: devuelve null. Esa es la diferencia con `int.parse`, y es
  /// la razón de preferirlo al validar lo que escribe un usuario.
  static int? desdeTexto(String texto, BaseNumerica base) {
    final String limpio =
        texto.trim().toUpperCase().replaceAll(' ', '').replaceAll('_', '');
    if (limpio.isEmpty) return null;

    final int? valor = int.tryParse(limpio, radix: base.radix);
    if (valor == null) return null;
    if (valor < 0 || valor > Bits.maxSinSigno(Bits.anchoMaximo)) return null;
    return valor;
  }

  // -------------------------------------------------------------------------
  //  Número -> texto
  // -------------------------------------------------------------------------

  /// El mismo número escrito en otra base. Una línea, porque `toRadixString`
  /// ya está en la biblioteca estándar de Dart.
  static String enTexto(int valor, BaseNumerica base) =>
      valor.toRadixString(base.radix).toUpperCase();

  /// Con el prefijo convencional: `0xFF`, `0b1010`, `0o17`.
  static String conPrefijo(int valor, BaseNumerica base) =>
      '${base.prefijo}${enTexto(valor, base)}';

  /// En binario, rellenado con ceros a la izquierda hasta el ancho dado.
  /// Recorta primero, para que nunca devuelva más caracteres que el ancho.
  static String enBinario(int valor, int anchoBits) =>
      Bits.recortar(valor, anchoBits).toRadixString(2).padLeft(anchoBits, '0');

  /// Agrupa de a [tamano] caracteres para que se pueda leer:
  ///     "11010110"  ->  "1101 0110"
  ///
  /// Se agrupa desde la DERECHA, que es como se leen los números. De ahí el
  /// `(texto.length - i) % tamano`, en lugar del `i % tamano` que sería
  /// natural escribir y agruparía al revés cuando la longitud no es
  /// múltiplo del tamaño.
  static String agrupar(String texto, [int tamano = 4]) {
    final StringBuffer buffer = StringBuffer();
    for (int i = 0; i < texto.length; i++) {
      if (i != 0 && (texto.length - i) % tamano == 0) buffer.write(' ');
      buffer.write(texto[i]);
    }
    return buffer.toString();
  }

  /// Igual que [enBinario] pero agrupado de a cuatro.
  static String binarioLegible(int valor, int anchoBits) =>
      agrupar(enBinario(valor, anchoBits));

  // -------------------------------------------------------------------------
  //  Divisiones sucesivas
  // -------------------------------------------------------------------------

  /// Los pasos del algoritmo que se enseña en el pizarrón.
  ///
  /// El caso del cero merece su propia línea: el `while` no se ejecutaría
  /// ni una vez y la tabla saldría vacía, cuando lo correcto es mostrar
  /// `0 ÷ 2 = 0 resto 0`.
  static List<PasoDivision> pasosDivision(int valor, int radix) {
    if (valor == 0) {
      return const <PasoDivision>[
        PasoDivision(dividendo: 0, cociente: 0, resto: 0),
      ];
    }

    final List<PasoDivision> pasos = <PasoDivision>[];
    int actual = valor;
    while (actual > 0) {
      pasos.add(PasoDivision(
        dividendo: actual,
        cociente: actual ~/ radix, // división entera
        resto: actual % radix,
      ));
      actual = actual ~/ radix;
    }
    return pasos;
  }

  /// Lee los restos de abajo hacia arriba y arma el resultado.
  ///
  /// En el monolito esta línea vivía dentro del widget de la tabla, así que
  /// no se podía probar. Acá sí: es la última prueba de `conversor_test.dart`.
  static String leerRestos(List<PasoDivision> pasos, int radix) => pasos.reversed
      .map((PasoDivision p) => p.resto.toRadixString(radix).toUpperCase())
      .join();
}
