// ===========================================================================
//  pantallas/pestana_bits.dart
// ---------------------------------------------------------------------------
//  Pestaña 2: el mismo número visto como patrón de bits. Ancho de palabra,
//  rejilla editable, las dos lecturas (sin signo y en complemento a dos) y
//  los desplazamientos.
// ===========================================================================

import 'package:flutter/material.dart';

import '../estado/controlador_conversor.dart';
import '../estado/proveedor_conversor.dart';
import '../modelos/ancho_palabra.dart';
import '../tema/tema_app.dart';
import '../widgets/caja_valor.dart';
import '../widgets/nota_didactica.dart';
import '../widgets/nota_plataforma.dart';
import '../widgets/rejilla_bits.dart';

class PestanaBits extends StatelessWidget {
  const PestanaBits({super.key});

  @override
  Widget build(BuildContext context) {
    final ControladorConversor c = ProveedorConversor.de(context);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        // ---- Ancho de palabra -------------------------------------------
        const Text('Ancho de palabra', style: Tipografia.titulo),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: <Widget>[
            for (final AnchoPalabra a in AnchoPalabra.values)
              ChoiceChip(
                label: Text(a.etiqueta),
                selected: c.ancho == a,
                onSelected: (_) => c.cambiarAncho(a),
              ),
          ],
        ),
        const SizedBox(height: 16),

        // ---- Rejilla de bits ---------------------------------------------
        const Text(
          'Toca un bit para encenderlo o apagarlo',
          style: Tipografia.ayuda,
        ),
        const SizedBox(height: 8),
        RejillaBits(
          binario: c.binario,
          anchoBits: c.ancho.bits,
          alTocar: c.conmutarBit,
        ),
        const SizedBox(height: 8),
        _Descomposicion(controlador: c),
        const SizedBox(height: 16),

        // ---- Las dos lecturas del mismo patrón ---------------------------
        Row(
          children: <Widget>[
            Expanded(
              child: CajaValor(
                titulo: 'Sin signo',
                valor: '${c.valorRecortado}',
                detalle: 'Rango: 0 a ${c.maxSinSigno}',
                color: Paleta.sinSigno,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: CajaValor(
                titulo: 'Con signo (complemento a dos)',
                valor: '${c.valorConSigno}',
                detalle: 'Rango: ${c.minConSigno} a ${c.maxConSigno}',
                color: c.valorConSigno < 0
                    ? Paleta.conSignoNegativo
                    : Paleta.conSignoPositivo,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        const NotaDidactica(
          titulo: 'El mismo patrón, dos significados',
          texto: 'Los bits de arriba no saben si son un número con signo o '
              'sin signo: eso lo decide quien los interpreta. Si el bit más '
              'a la izquierda vale 1, la lectura con signo da negativo. '
              'Enciende ese bit y observa cómo cambian las dos cajas.',
        ),
        const SizedBox(height: 14),

        // ---- Desplazamientos ---------------------------------------------
        const Text('Desplazamientos y máscaras', style: Tipografia.titulo),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: <Widget>[
            _BotonBit('<< 1  (×2)', c.desplazarIzquierda),
            _BotonBit('>> 1  (÷2)', c.desplazarDerecha),
            _BotonBit('NOT', c.complementar),
            _BotonBit('Todo 1', c.todoUnos),
            _BotonBit('Todo 0', c.todoCeros),
          ],
        ),
        const SizedBox(height: 10),
        const NotaDidactica(
          titulo: 'Por qué desplazar es multiplicar',
          texto: 'Correr los bits una posición a la izquierda multiplica por '
              '2, igual que en decimal correr una posición multiplica por 10. '
              'Es la operación más barata que existe en un procesador, y por '
              'eso los compiladores reemplazan x*2 por x<<1.',
        ),
        const SizedBox(height: 14),

        const NotaPlataforma(),
      ],
    );
  }
}

/// Muestra el número como suma de potencias de dos: de dónde sale el valor.
class _Descomposicion extends StatelessWidget {
  const _Descomposicion({required this.controlador});

  final ControladorConversor controlador;

  @override
  Widget build(BuildContext context) {
    final List<int> partes = controlador.descomposicion;

    final String texto = partes.isEmpty
        ? 'Todos los bits apagados: el valor es 0.'
        : '${partes.join(' + ')} = ${controlador.valorRecortado}'
            '   ·   ${controlador.cuentaDeUnos} bits encendidos';

    return Text(texto, style: Tipografia.monoChico);
  }
}

class _BotonBit extends StatelessWidget {
  const _BotonBit(this.texto, this.alPulsar);

  final String texto;
  final VoidCallback alPulsar;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: alPulsar,
      child: Text(texto, style: Tipografia.mono),
    );
  }
}
