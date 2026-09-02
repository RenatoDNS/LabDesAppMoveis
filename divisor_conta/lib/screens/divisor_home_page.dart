import 'package:flutter/material.dart';

import '../models/divisao_conta.dart';
import '../utils/formatador.dart';
import '../widgets/campo_numerico.dart';

class DivisorHomePage extends StatefulWidget {
  const DivisorHomePage({super.key});

  @override
  State<DivisorHomePage> createState() => _DivisorHomePageState();
}

class _DivisorHomePageState extends State<DivisorHomePage> {
  // Chave que dá acesso ao estado do formulário (para validar tudo de uma vez).
  final _chaveFormulario = GlobalKey<FormState>();

  // Controllers leem e escrevem o texto de cada campo.
  final _controllerConta = TextEditingController();
  final _controllerPessoas = TextEditingController(text: '2');
  final _controllerGorjeta = TextEditingController(text: '10');

  // Guarda o resultado do último cálculo. Null = ainda não calculou.
  DivisaoConta? _resultado;

  @override
  void dispose() {
    // Libera os recursos dos controllers quando a tela sai da árvore.
    _controllerConta.dispose();
    _controllerPessoas.dispose();
    _controllerGorjeta.dispose();
    super.dispose();
  }

  void _calcular() {
    // validate() dispara o validator de cada campo do formulário.
    if (!_chaveFormulario.currentState!.validate()) return;

    // Esconde o teclado depois de calcular.
    FocusScope.of(context).unfocus();

    final conta = paraDouble(_controllerConta.text)!;
    final pessoas = int.parse(_controllerPessoas.text.trim());
    final gorjeta = paraDouble(_controllerGorjeta.text)!;

    // setState avisa o Flutter que o estado mudou e a tela deve ser
    // reconstruída com os novos valores.
    setState(() {
      _resultado = DivisaoConta(
        valorConta: conta,
        quantidadePessoas: pessoas,
        percentualGorjeta: gorjeta,
      );
    });
  }

  void _limpar() {
    _chaveFormulario.currentState!.reset();
    _controllerConta.clear();
    _controllerPessoas.text = '2';
    _controllerGorjeta.text = '10';
    setState(() => _resultado = null);
  }

  // ---------------------------------------------------------------
  // Validadores
  // ---------------------------------------------------------------

  String? _validarConta(String? valor) {
    final numero = paraDouble(valor ?? '');
    if (numero == null) return 'Informe o valor da conta';
    if (numero <= 0) return 'O valor deve ser maior que zero';
    return null; // null significa "campo válido"
  }

  String? _validarPessoas(String? valor) {
    final numero = int.tryParse((valor ?? '').trim());
    if (numero == null) return 'Informe a quantidade de pessoas';
    if (numero < 1) return 'Deve haver pelo menos 1 pessoa';
    if (numero > 100) return 'Máximo de 100 pessoas';
    return null;
  }

  String? _validarGorjeta(String? valor) {
    final numero = paraDouble(valor ?? '');
    if (numero == null) return 'Informe a porcentagem (use 0 se não houver)';
    if (numero < 0) return 'A gorjeta não pode ser negativa';
    if (numero > 100) return 'A gorjeta não pode passar de 100%';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Divisor de Conta'),
        actions: [
          IconButton(
            onPressed: _limpar,
            icon: const Icon(Icons.refresh),
            tooltip: 'Limpar',
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _chaveFormulario,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CampoNumerico(
                  controller: _controllerConta,
                  rotulo: 'Valor total da conta',
                  icone: Icons.receipt_long,
                  sufixo: 'R\$',
                  validador: _validarConta,
                ),
                const SizedBox(height: 16),
                CampoNumerico(
                  controller: _controllerPessoas,
                  rotulo: 'Quantidade de pessoas',
                  icone: Icons.groups,
                  apenasInteiros: true,
                  validador: _validarPessoas,
                ),
                const SizedBox(height: 16),
                CampoNumerico(
                  controller: _controllerGorjeta,
                  rotulo: 'Gorjeta do garçom',
                  icone: Icons.room_service,
                  sufixo: '%',
                  validador: _validarGorjeta,
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: _calcular,
                  icon: const Icon(Icons.calculate),
                  label: const Text('Calcular'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
                const SizedBox(height: 24),
                // Renderização condicional: só mostra o cartão de
                // resultado depois que o usuário calcula.
                if (_resultado != null) _CartaoResultado(divisao: _resultado!),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Cartão que exibe os três valores calculados.
class _CartaoResultado extends StatelessWidget {
  const _CartaoResultado({required this.divisao});

  final DivisaoConta divisao;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);

    return Card(
      elevation: 0,
      color: tema.colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Resultado', style: tema.textTheme.titleMedium),
            const Divider(height: 24),
            _LinhaResultado(
              rotulo: 'Parte do garçom',
              valor: formatarReal(divisao.valorGorjeta),
            ),
            const SizedBox(height: 12),
            _LinhaResultado(
              rotulo: 'Total a pagar (conta + gorjeta)',
              valor: formatarReal(divisao.valorTotalAPagar),
            ),
            const SizedBox(height: 12),
            _LinhaResultado(
              rotulo: 'Cada pessoa paga',
              valor: formatarReal(divisao.valorPorPessoa),
              destaque: true,
            ),
          ],
        ),
      ),
    );
  }
}

class _LinhaResultado extends StatelessWidget {
  const _LinhaResultado({
    required this.rotulo,
    required this.valor,
    this.destaque = false,
  });

  final String rotulo;
  final String valor;
  final bool destaque;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final estiloValor = destaque
        ? tema.textTheme.headlineSmall?.copyWith(
            color: tema.colorScheme.primary,
            fontWeight: FontWeight.bold,
          )
        : tema.textTheme.titleMedium;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Flexible(child: Text(rotulo, style: tema.textTheme.bodyMedium)),
        const SizedBox(width: 12),
        Text(valor, style: estiloValor),
      ],
    );
  }
}
