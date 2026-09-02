import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Campo de texto reutilizável para entrada de números.
///
/// Encapsula o teclado numérico, o ícone, o rótulo e o validador,
/// evitando repetir o mesmo bloco de código três vezes na tela.
class CampoNumerico extends StatelessWidget {
  const CampoNumerico({
    super.key,
    required this.controller,
    required this.rotulo,
    required this.icone,
    required this.validador,
    this.sufixo,
    this.apenasInteiros = false,
    this.aoAlterar,
  });

  final TextEditingController controller;
  final String rotulo;
  final IconData icone;
  final String? Function(String?) validador;
  final String? sufixo;
  final bool apenasInteiros;
  final void Function(String)? aoAlterar;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.numberWithOptions(decimal: !apenasInteiros),
      inputFormatters: [
        FilteringTextInputFormatter.allow(
          apenasInteiros ? RegExp(r'[0-9]') : RegExp(r'[0-9.,]'),
        ),
      ],
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        labelText: rotulo,
        prefixIcon: Icon(icone),
        suffixText: sufixo,
        border: const OutlineInputBorder(),
      ),
      validator: validador,
      onChanged: aoAlterar,
    );
  }
}
