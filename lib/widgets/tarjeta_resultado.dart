// ===========================================================================
//  widgets/tarjeta_resultado.dart
// ---------------------------------------------------------------------------
//  Una de las cuatro tarjetas con el mismo número escrito en otra base,
//  con botón de copiar.
// ===========================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../logica/conversor.dart';
import '../modelos/base_numerica.dart';
import '../tema/tema_app.dart';

class TarjetaResultado extends StatelessWidget {
  const TarjetaResultado({
    super.key,
    required this.base,
    required this.valor,
    required this.esBaseDeEntrada,
  });

  final BaseNumerica base;
  final int valor;

  /// Se resalta la tarjeta de la base en la que el usuario está escribiendo.
  final bool esBaseDeEntrada;

  @override
  Widget build(BuildContext context) {
    final String texto = Conversor.enTexto(valor, base);

    // En binario se agrupa de a cuatro; en las otras bases, no: "1F4" no
    // gana nada con espacios, y "1 1111 0100" sí.
    final String mostrado =
        base == BaseNumerica.binario ? Conversor.agrupar(texto) : texto;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: esBaseDeEntrada ? Paleta.baseActiva : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: <Widget>[
            SizedBox(
              width: 52,
              child: Text(
                base.sigla,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: Color(0xFF5A6472),
                ),
              ),
            ),
            Expanded(
              // SelectableText en lugar de Text: el estudiante puede marcar
              // y copiar con el mouse en web, y con un toque largo en móvil.
              child: SelectableText(
                '${base.prefijo}$mostrado',
                style: Tipografia.monoGrande,
              ),
            ),
            IconButton(
              tooltip: 'Copiar',
              iconSize: 18,
              icon: const Icon(Icons.copy),
              onPressed: () => _copiar(context, texto),
            ),
          ],
        ),
      ),
    );
  }

  void _copiar(BuildContext context, String texto) {
    // El portapapeles funciona igual en web y en móvil: lo resuelve Flutter
    // con el canal de plataforma, sin que haya que escribir código nativo.
    // Se copia el texto SIN los espacios de agrupación, que son decorativos.
    Clipboard.setData(ClipboardData(text: texto));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Copiado: $texto'),
        duration: const Duration(seconds: 1),
      ),
    );
  }
}
