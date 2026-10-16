// ===========================================================================
//  widgets/rejilla_bits.dart
// ---------------------------------------------------------------------------
//  La rejilla de casillas 0/1 con el exponente debajo de cada una.
//
//  Widget de PRESENTACIÓN: recibe el binario ya formateado y una función
//  para avisar qué bit se tocó. No conoce el controlador, así que la usan
//  tanto la pestaña de bits (con 8, 16 o 32) como el editor de operandos
//  de la pestaña de operaciones (con 8). **Un solo widget, dos usos**: eso
//  es lo que se gana al no acoplarlo al estado.
// ===========================================================================

import 'package:flutter/material.dart';

import '../tema/tema_app.dart';

class RejillaBits extends StatelessWidget {
  const RejillaBits({
    super.key,
    required this.binario,
    required this.anchoBits,
    required this.alTocar,
  });

  /// El número en binario, ya rellenado con ceros a [anchoBits] caracteres.
  final String binario;

  final int anchoBits;

  /// Avisa qué POSICIÓN se tocó. Posición 0 es el bit de la derecha.
  final void Function(int posicion) alTocar;

  @override
  Widget build(BuildContext context) {
    // Ocho bits por fila: así entra en un celular y se lee como se escribe
    // en el pizarrón. Con 32 bits salen cuatro filas.
    final int filas = (anchoBits / 8).ceil();

    return Column(
      children: List<Widget>.generate(filas, (int fila) {
        final int desde = fila * 8;
        return Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Row(
            children: List<Widget>.generate(8, (int k) {
              final int indiceTexto = desde + k;

              // CUIDADO con esta línea, es donde se equivocan todos:
              // el texto se lee de IZQUIERDA a derecha, pero las posiciones
              // de los bits se cuentan de DERECHA a izquierda. El bit más
              // a la izquierda de 8 bits es la posición 7, no la 0.
              final int posicion = anchoBits - 1 - indiceTexto;

              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: _Casilla(
                    encendido: binario[indiceTexto] == '1',
                    posicion: posicion,
                    onTap: () => alTocar(posicion),
                  ),
                ),
              );
            }),
          ),
        );
      }),
    );
  }
}

class _Casilla extends StatelessWidget {
  const _Casilla({
    required this.encendido,
    required this.posicion,
    required this.onTap,
  });

  final bool encendido;
  final int posicion;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: <Widget>[
          AspectRatio(
            aspectRatio: 1, // casillas cuadradas en cualquier ancho
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: encendido ? Paleta.bitEncendido : Paleta.bitApagado,
                border: Border.all(
                  color: encendido ? Paleta.bitEncendido : Paleta.bordeApagado,
                ),
                borderRadius: BorderRadius.circular(6),
              ),
              // FittedBox encoge el texto si la casilla queda muy chica,
              // en lugar de desbordar. Con 32 bits en un celular angosto
              // cada casilla mide pocos píxeles.
              child: Center(
                child: FittedBox(
                  child: Padding(
                    padding: const EdgeInsets.all(6),
                    child: Text(
                      encendido ? '1' : '0',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: encendido ? Colors.white : Colors.black38,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 2),
          // El exponente: este bit vale 2 elevado a este número.
          FittedBox(
            child: Text(
              '$posicion',
              style: const TextStyle(fontSize: 9, color: Colors.black45),
            ),
          ),
        ],
      ),
    );
  }
}
