// ===========================================================================
//  logica/bits.dart
// ---------------------------------------------------------------------------
//  Todo lo que tiene que ver con bits y ancho de palabra. Dart puro: ni un
//  import de Flutter.
//
//  EL PROBLEMA QUE RESUELVE ESTE ARCHIVO
//
//  En Android (y en cualquier compilación nativa) un `int` de Dart es de
//  64 bits con signo. En el navegador, en cambio, se apoya en el tipo
//  numérico de JavaScript y **los operadores bit a bit truncan a 32 bits**.
//  Eso hace que expresiones como `1 << 32` o `~0` den resultados distintos
//  según dónde corra el mismo código.
//
//  LA SOLUCIÓN QUE ADOPTAMOS
//
//  Toda la maquinaria de ancho de palabra está escrita con ARITMÉTICA
//  (multiplicar, dividir, módulo, restar) y no con operadores bit a bit.
//  La aritmética de enteros es exacta en las dos plataformas mucho más
//  allá de los 32 bits, así que el resultado coincide por construcción,
//  no por casualidad:
//
//      en lugar de  1 << n          ->  potencias[n]
//      en lugar de  v & mascara     ->  v % potencias[ancho]
//      en lugar de  ~v              ->  maxSinSigno(ancho) - v
//      en lugar de  v ^ (1 << p)    ->  v + peso  /  v - peso
//
//  Los operadores &, | y ^ sobreviven en un solo lugar: la pestaña de
//  operaciones lógicas, donde SON el tema de la clase y los operandos son
//  bytes, muy lejos del límite de los 32 bits.
// ===========================================================================

class Bits {
  // Contenedor de funciones: no se instancia nunca.
  const Bits._();

  /// Ancho máximo que maneja la aplicación.
  static const int anchoMaximo = 32;

  // -------------------------------------------------------------------------
  //  La tabla de potencias: el corazón de todo el archivo
  // -------------------------------------------------------------------------

  /// `potencias[n]` es 2 elevado a n, para n de 0 a 32.
  ///
  /// Se construye multiplicando por dos, no desplazando. La función anónima
  /// que se invoca al instante — `() { … }()` — permite inicializar una
  /// variable `static final` con varias líneas de código. Se ejecuta una
  /// sola vez, la primera vez que alguien lee `potencias`.
  static final List<int> potencias = List<int>.unmodifiable(() {
    final List<int> lista = <int>[];
    int v = 1;
    for (int i = 0; i <= anchoMaximo; i++) {
      lista.add(v);
      v *= 2;
    }
    return lista;
  }());

  /// El peso de un bit: cuánto vale un 1 en esa posición.
  /// El bit 0 es el de la derecha y vale 1; el bit 7 vale 128.
  static int pesoDelBit(int posicion) => potencias[posicion];

  // -------------------------------------------------------------------------
  //  Rangos
  // -------------------------------------------------------------------------

  /// Mayor valor representable sin signo: 2^ancho − 1.
  ///
  /// Ese número es, en binario, **todos unos**. Por eso sirve también como
  /// máscara del ancho completo: 8 bits -> 255 -> 1111 1111.
  static int maxSinSigno(int anchoBits) => potencias[anchoBits] - 1;

  /// Rango con signo en complemento a dos: de −2^(n−1) a 2^(n−1) − 1.
  /// Nótese que es asimétrico: hay un negativo más que positivos, porque
  /// el cero ocupa un lugar del lado positivo.
  static int minConSigno(int anchoBits) => -potencias[anchoBits - 1];
  static int maxConSigno(int anchoBits) => potencias[anchoBits - 1] - 1;

  // -------------------------------------------------------------------------
  //  Operaciones
  // -------------------------------------------------------------------------

  /// Recorta un valor al ancho indicado: los bits que se salen se pierden,
  /// igual que en el hardware real.
  ///
  /// `%` en lugar de `&`: en Dart el resto con divisor positivo siempre
  /// devuelve un valor entre 0 y el divisor, incluso para entradas
  /// negativas. Así `recortar(-173, 16)` da 65363 en Android y en web.
  static int recortar(int valor, int anchoBits) =>
      valor % potencias[anchoBits];

  /// Interpreta el mismo patrón de bits como número **con signo**, en
  /// complemento a dos: si el bit más significativo vale 1, el número es
  /// negativo y equivale a `valor − 2^ancho`.
  ///
  /// Es la misma cuenta que se hace a mano en el pizarrón, y la razón de
  /// que 1111 1111 sea −1 y no 255: depende de quién lo lea.
  static int comoConSigno(int valor, int anchoBits) {
    final int v = recortar(valor, anchoBits);
    final int mitad = potencias[anchoBits - 1];
    return v >= mitad ? v - potencias[anchoBits] : v;
  }

  /// ¿Está encendido el bit de esa posición?
  /// División entera y resto: exacto en las dos plataformas.
  static bool bitEncendido(int valor, int posicion) =>
      (valor ~/ potencias[posicion]) % 2 == 1;

  /// Invierte un bit concreto.
  ///
  /// Encender un bit es **sumar su peso**; apagarlo es **restarlo**. Dicho
  /// así, la rejilla de bits de la pantalla deja de ser magia: es un número
  /// escrito como suma de potencias de dos.
  static int conmutarBit(int valor, int posicion, int anchoBits) {
    final int v = recortar(valor, anchoBits);
    final int peso = potencias[posicion];
    return bitEncendido(v, posicion) ? v - peso : v + peso;
  }

  /// NOT dentro del ancho de palabra: invierte todos los bits.
  ///
  /// Con el ancho fijado, invertir todo es simplemente `máximo − valor`.
  /// Para 8 bits: NOT 1010 1100 = 255 − 172 = 83 = 0101 0011. Se puede
  /// verificar a mano, y da lo mismo en toda plataforma.
  static int complemento(int valor, int anchoBits) =>
      maxSinSigno(anchoBits) - recortar(valor, anchoBits);

  /// Desplazar a la izquierda es multiplicar por dos, igual que en decimal
  /// correr una posición multiplica por diez. El recorte descarta lo que
  /// se sale del ancho.
  static int desplazarIzquierda(int valor, int anchoBits) =>
      recortar(valor * 2, anchoBits);

  /// Desplazar a la derecha es dividir entre dos descartando el resto.
  static int desplazarDerecha(int valor) => valor ~/ 2;

  /// Cuántos unos tiene el número (en inglés *population count*).
  /// Se usa en criptografía, en detección de errores y en bases de datos.
  static int cuentaDeUnos(int valor, int anchoBits) {
    int v = recortar(valor, anchoBits);
    int unos = 0;
    while (v > 0) {
      unos += v % 2;
      v = v ~/ 2;
    }
    return unos;
  }

  /// Descomposición en potencias de dos: `[128, 32, 8, 4]` para 172.
  /// Sirve para mostrar de dónde sale el valor de la rejilla.
  static List<int> descomponer(int valor, int anchoBits) {
    final List<int> partes = <int>[];
    for (int p = anchoBits - 1; p >= 0; p--) {
      if (bitEncendido(recortar(valor, anchoBits), p)) {
        partes.add(potencias[p]);
      }
    }
    return partes;
  }
}
