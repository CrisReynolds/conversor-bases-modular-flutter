// ===========================================================================
//  estado/controlador_conversor.dart
// ---------------------------------------------------------------------------
//  El estado de la aplicación en un solo lugar: el valor actual, la base en
//  la que se escribe, el ancho de palabra y los dos operandos de la pestaña
//  de operaciones.
//
//  En el monolito todo esto vivía dentro de `_PantallaConversorState`, junto
//  con los tres métodos que construían las pestañas: una clase de 400 líneas
//  que era a la vez estado, lógica de presentación y tres pantallas.
//
//  NOTA SOBRE LA CAPA: este archivo importa `package:flutter/widgets.dart`
//  porque guarda un TextEditingController. Es una línea que conviene
//  defender en clase: el texto escrito ES parte del estado de la conversión,
//  y mantenerlo sincronizado con el valor numérico es justamente el trabajo
//  de esta clase. Lo que NO se negocia es `logica/` y `modelos/`: ahí no
//  entra Flutter ni para esto.
// ===========================================================================

import 'package:flutter/widgets.dart';

import '../logica/bits.dart';
import '../logica/conversor.dart';
import '../modelos/ancho_palabra.dart';
import '../modelos/base_numerica.dart';
import '../modelos/paso_division.dart';

class ControladorConversor extends ChangeNotifier {
  ControladorConversor({int valorInicial = 2026})
      : _valor = valorInicial,
        entrada = TextEditingController(text: '$valorInicial');

  /// La pestaña de operaciones trabaja siempre con un byte: ocho bits se
  /// leen de un golpe y caben en la pantalla de un teléfono.
  static const AnchoPalabra anchoOperaciones = AnchoPalabra.byte;

  // -------------------------------------------------------------------------
  //  Estado
  // -------------------------------------------------------------------------

  /// El campo de texto. Público porque el TextField lo necesita, pero el
  /// `.text` solo se escribe desde esta clase.
  final TextEditingController entrada;

  int _valor;
  int get valor => _valor;

  BaseNumerica _baseEntrada = BaseNumerica.decimal;
  BaseNumerica get baseEntrada => _baseEntrada;

  AnchoPalabra _ancho = AnchoPalabra.mediaPalabra;
  AnchoPalabra get ancho => _ancho;

  bool _textoValido = true;
  bool get textoValido => _textoValido;

  int _a = 0xAC;
  int _b = 0x3F;
  int get a => Bits.recortar(_a, anchoOperaciones.bits);
  int get b => Bits.recortar(_b, anchoOperaciones.bits);

  // -------------------------------------------------------------------------
  //  Valores derivados
  //
  //  Son getters, no campos: se calculan cuando alguien los pide y nunca
  //  pueden quedar desactualizados. En el monolito estas seis líneas se
  //  recalculaban a mano al principio de cada método de pestaña, y había
  //  que acordarse de hacerlo.
  // -------------------------------------------------------------------------

  int get valorRecortado => Bits.recortar(_valor, _ancho.bits);

  String get binario => Conversor.enBinario(_valor, _ancho.bits);

  int get valorConSigno => Bits.comoConSigno(_valor, _ancho.bits);

  int get maxSinSigno => Bits.maxSinSigno(_ancho.bits);
  int get minConSigno => Bits.minConSigno(_ancho.bits);
  int get maxConSigno => Bits.maxConSigno(_ancho.bits);

  int get cuentaDeUnos => Bits.cuentaDeUnos(_valor, _ancho.bits);

  List<int> get descomposicion => Bits.descomponer(_valor, _ancho.bits);

  List<PasoDivision> get pasosHaciaBinario =>
      Conversor.pasosDivision(_valor, 2);

  /// El valor escrito en una base cualquiera. Lo usan las cuatro tarjetas.
  String enBase(BaseNumerica base) => Conversor.enTexto(_valor, base);

  // -------------------------------------------------------------------------
  //  Acciones sobre el valor
  // -------------------------------------------------------------------------

  /// Reacciona a lo que el usuario escribe.
  ///
  /// Importante: acá **no** se toca `entrada.text`. Si lo hiciéramos,
  /// pelearíamos con el usuario mientras tipea (el cursor saltaría al final
  /// en cada tecla). El texto solo se reescribe cuando el cambio viene de
  /// otro lado: cambiar de base, tocar un bit, desplazar.
  void escribirTexto(String texto) {
    final int? nuevo = Conversor.desdeTexto(texto, _baseEntrada);
    _textoValido = texto.trim().isEmpty || nuevo != null;
    if (nuevo != null) _valor = nuevo;
    notifyListeners();
  }

  /// Cambia la base de entrada **conservando el valor**.
  ///
  /// Es una decisión de diseño que vale discutir: al pasar de decimal a
  /// hexadecimal, el 255 se reescribe como FF. No se reinterpreta el texto
  /// "255" como hexadecimal (que daría 597). El número es el mismo; lo único
  /// que cambia es la notación.
  void cambiarBase(BaseNumerica nueva) {
    if (nueva == _baseEntrada) return;
    _baseEntrada = nueva;
    _textoValido = true;
    _sincronizarTexto();
    notifyListeners();
  }

  void cambiarAncho(AnchoPalabra nuevo) {
    if (nuevo == _ancho) return;
    _ancho = nuevo;
    notifyListeners();
  }

  /// Punto único de entrada para todo cambio de valor que no venga del
  /// teclado. Recorta, sincroniza el texto y notifica: tres cosas que antes
  /// se repetían en cada botón.
  void establecerValor(int nuevo) {
    _valor = Bits.recortar(nuevo, _ancho.bits);
    _textoValido = true;
    _sincronizarTexto();
    notifyListeners();
  }

  void conmutarBit(int posicion) =>
      establecerValor(Bits.conmutarBit(_valor, posicion, _ancho.bits));

  void desplazarIzquierda() =>
      establecerValor(Bits.desplazarIzquierda(valorRecortado, _ancho.bits));

  void desplazarDerecha() =>
      establecerValor(Bits.desplazarDerecha(valorRecortado));

  void complementar() =>
      establecerValor(Bits.complemento(_valor, _ancho.bits));

  void todoUnos() => establecerValor(maxSinSigno);

  void todoCeros() => establecerValor(0);

  // -------------------------------------------------------------------------
  //  Acciones de la pestaña de operaciones
  // -------------------------------------------------------------------------

  void conmutarBitDeA(int posicion) {
    _a = Bits.conmutarBit(_a, posicion, anchoOperaciones.bits);
    notifyListeners();
  }

  void conmutarBitDeB(int posicion) {
    _b = Bits.conmutarBit(_b, posicion, anchoOperaciones.bits);
    notifyListeners();
  }

  // -------------------------------------------------------------------------
  //  Interno
  // -------------------------------------------------------------------------

  void _sincronizarTexto() {
    entrada.text = Conversor.enTexto(_valor, _baseEntrada);
  }

  @override
  void dispose() {
    // Un TextEditingController también hay que desecharlo: mantiene
    // suscriptores y un FocusNode asociado.
    entrada.dispose();
    super.dispose();
  }
}
