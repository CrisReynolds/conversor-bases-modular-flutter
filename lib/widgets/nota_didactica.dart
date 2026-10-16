// ===========================================================================
//  widgets/nota_didactica.dart
// ---------------------------------------------------------------------------
//  El recuadro amarillo con una explicación de clase.
//
//  Fíjense en el nombre de la clase: en el monolito era `_Nota`, con
//  guión bajo, porque al estar en el mismo archivo el guión bajo bastaba
//  para marcarla como interna. Al mudarse a su propio archivo tuvo que
//  volverse pública: en Dart la privacidad es **por archivo** (library),
//  no por clase ni por carpeta. Un `_Nota` acá sería invisible para las
//  pestañas que la usan.
// ===========================================================================

import 'package:flutter/material.dart';

import '../tema/tema_app.dart';

class NotaDidactica extends StatelessWidget {
  const NotaDidactica({
    super.key,
    required this.titulo,
    required this.texto,
  });

  final String titulo;
  final String texto;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Paleta.notaFondo,
        border: Border.all(color: Paleta.dorado),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            titulo,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: Paleta.granateOscuro,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            texto,
            style: const TextStyle(fontSize: 12, height: 1.45),
          ),
        ],
      ),
    );
  }
}
