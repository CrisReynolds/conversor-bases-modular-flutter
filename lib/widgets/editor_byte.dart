// ===========================================================================
//  widgets/editor_byte.dart
// ---------------------------------------------------------------------------
//  Un operando de la pestaña de operaciones: la etiqueta de color, el valor
//  en decimal y hexadecimal, y la rejilla de ocho bits para editarlo.
//
//  Reutiliza `RejillaBits` sin modificarla. Eso solo es posible porque la
//  rejilla no consulta el controlador: recibe el binario y devuelve la
//  posición tocada, y le da igual si el número es el valor principal o un
//  operando. **La reutilización es consecuencia de no acoplar al estado.**
// ===========================================================================

import 'package:flutter/material.dart';

import '../logica/conversor.dart';
import '../modelos/base_numerica.dart';

import 'rejilla_bits.dart';

class EditorByte extends StatelessWidget {
  const EditorByte({
    super.key,
    required this.etiqueta,
    required this.valor,
    required this.color,
    required this.alConmutarBit,
  });

  final String etiqueta;
  final int valor;
  final Color color;
  final void Function(int posicion) alConmutarBit;

  static const int _bits = 8;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                _Etiqueta(texto: etiqueta, color: color),
                const SizedBox(width: 10),
                Text(
                  '$valor',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  // El relleno va sobre los DÍGITOS, no sobre el texto con
                  // prefijo: `'0x5'.padLeft(4, '0')` daría "00x5".
                  '0x${Conversor.enTexto(valor, BaseNumerica.hexadecimal).padLeft(2, '0')}',
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            RejillaBits(
              binario: Conversor.enBinario(valor, _bits),
              anchoBits: _bits,
              alTocar: alConmutarBit,
            ),
          ],
        ),
      ),
    );
  }
}

class _Etiqueta extends StatelessWidget {
  const _Etiqueta({required this.texto, required this.color});

  final String texto;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        texto,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
