// ===========================================================================
//  pantallas/pestana_conversor.dart
// ---------------------------------------------------------------------------
//  Pestaña 1: escribir un número en una base y verlo en las cuatro, más las
//  divisiones sucesivas hacia binario.
//
//  En el monolito esto era el método `_pestanaConversor()` de un State de
//  400 líneas. Como archivo propio, es un widget de 120 líneas que se abre
//  por su nombre y se entiende solo.
// ===========================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../estado/controlador_conversor.dart';
import '../estado/proveedor_conversor.dart';
import '../modelos/base_numerica.dart';
import '../tema/tema_app.dart';
import '../widgets/nota_didactica.dart';
import '../widgets/tabla_pasos.dart';
import '../widgets/tarjeta_resultado.dart';

class PestanaConversor extends StatelessWidget {
  const PestanaConversor({super.key});

  @override
  Widget build(BuildContext context) {
    final ControladorConversor c = ProveedorConversor.de(context);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        // ---- Base de entrada -------------------------------------------
        const Text('El número que escribo está en:', style: Tipografia.titulo),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: <Widget>[
            for (final BaseNumerica b in BaseNumerica.values)
              ChoiceChip(
                label: Text('${b.nombre}  (${b.radix})'),
                selected: c.baseEntrada == b,
                onSelected: (_) => c.cambiarBase(b),
              ),
          ],
        ),
        const SizedBox(height: 14),

        // ---- Campo de entrada -------------------------------------------
        _CampoNumero(controlador: c),
        const SizedBox(height: 18),

        // ---- El mismo número en las cuatro bases ------------------------
        for (final BaseNumerica b in BaseNumerica.values)
          TarjetaResultado(
            base: b,
            valor: c.valor,
            esBaseDeEntrada: b == c.baseEntrada,
          ),

        const SizedBox(height: 10),
        const NotaDidactica(
          titulo: 'Lo mismo, escrito distinto',
          texto: 'Las cuatro tarjetas muestran EL MISMO número. Cambiar de '
              'base no cambia la cantidad, solo la notación con la que se '
              'escribe. Es igual que decir "doce" o "una docena".',
        ),
        const SizedBox(height: 14),

        // ---- Divisiones sucesivas ---------------------------------------
        const Text('Divisiones sucesivas hacia binario',
            style: Tipografia.titulo),
        const SizedBox(height: 4),
        const Text(
          'Se divide una y otra vez entre 2 y se guardan los restos. El '
          'resultado se lee de ABAJO hacia ARRIBA.',
          style: Tipografia.ayuda,
        ),
        const SizedBox(height: 10),
        TablaPasos(
          pasos: c.pasosHaciaBinario,
          radix: 2,
          valor: c.valor,
        ),
      ],
    );
  }
}

/// El campo de texto, separado para que el `build` de arriba se lea de un
/// tirón. Un widget privado en el mismo archivo es perfectamente válido
/// cuando solo lo usa esta pestaña: no todo tiene que ir a `widgets/`.
class _CampoNumero extends StatelessWidget {
  const _CampoNumero({required this.controlador});

  final ControladorConversor controlador;

  @override
  Widget build(BuildContext context) {
    final BaseNumerica base = controlador.baseEntrada;

    return TextField(
      controller: controlador.entrada,
      onChanged: controlador.escribirTexto,
      textCapitalization: TextCapitalization.characters,

      // El filtro impide ESCRIBIR un 2 en binario o una G en hexadecimal.
      // Es mejor que validar después: el error no llega a existir, así que
      // no hay que explicarlo ni mostrarlo. La expresión regular se arma
      // desde `base.alfabeto`, que a su vez sale del radix: imposible que
      // queden desincronizados.
      inputFormatters: <TextInputFormatter>[
        FilteringTextInputFormatter.allow(
          RegExp('[${base.alfabeto}${base.alfabeto.toLowerCase()}]'),
        ),
      ],

      decoration: InputDecoration(
        labelText: 'Número en ${base.nombre.toLowerCase()}',
        prefixText: base.prefijo,
        border: const OutlineInputBorder(),
        errorText: controlador.textoValido ? null : 'No es válido en esta base',
        helperText: 'Dígitos permitidos: ${base.alfabeto}',
      ),
      style: const TextStyle(
        fontFamily: 'monospace',
        fontSize: 20,
        letterSpacing: 1,
      ),
    );
  }
}
