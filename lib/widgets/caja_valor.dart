// ===========================================================================
//  widgets/caja_valor.dart
// ---------------------------------------------------------------------------
//  El recuadro con un número grande, su título y el rango debajo.
//  Se usa dos veces en la pestaña de bits: lectura sin signo y con signo.
// ===========================================================================

import 'package:flutter/material.dart';

class CajaValor extends StatelessWidget {
  const CajaValor({
    super.key,
    required this.titulo,
    required this.valor,
    required this.detalle,
    required this.color,
  });

  final String titulo;
  final String valor;
  final String detalle;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            titulo,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          // FittedBox: con 32 bits el valor sin signo llega a 4 294 967 295,
          // diez dígitos que no caben a tamaño 24 en media pantalla de
          // celular. En lugar de desbordar, el texto se encoge.
          FittedBox(
            child: Text(
              valor,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
                fontFamily: 'monospace',
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            detalle,
            style: const TextStyle(fontSize: 10, color: Colors.black54),
          ),
        ],
      ),
    );
  }
}
