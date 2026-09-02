import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const DivisorDeContaApp());
}

// =====================================================================
// Aplicativo e tema
// =====================================================================

class DivisorDeContaApp extends StatelessWidget {
  const DivisorDeContaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Divisor de Conta',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF00695C)),
      ),
      home: const DivisorHomePage(),
    );
  }
}

// =====================================================================
// Regra de negócio
// =====================================================================

/// Modelo de domínio: representa uma conta que será dividida entre
/// várias pessoas, com uma gorjeta (comissão do garçom) opcional.
///
/// Repare que a classe não tem um método calcular(): os três valores são
/// expostos como getters, calculados sob demanda a partir dos dados de
/// entrada. Assim é impossível existir um objeto com resultados
/// desatualizados.
class DivisaoConta {
  /// Valor total da conta, sem a gorjeta. Ex.: 250.00
  final double valorConta;

  /// Quantidade de pessoas que vão dividir a conta. Ex.: 4
  final int quantidadePessoas;

  /// Percentual da gorjeta sobre o valor da conta. Ex.: 10 (para 10%)
  final double percentualGorjeta;

  const DivisaoConta({
    required this.valorConta,
    required this.quantidadePessoas,
    required this.percentualGorjeta,
  })  : assert(valorConta >= 0, 'O valor da conta não pode ser negativo'),
        assert(quantidadePessoas > 0, 'É preciso ao menos 1 pessoa'),
        assert(percentualGorjeta >= 0, 'A gorjeta não pode ser negativa');

  /// Parte que cabe ao garçom.
  double get valorGorjeta => valorConta * (percentualGorjeta / 100);

  /// Conta + gorjeta: o valor que sai do bolso do grupo.
  double get valorTotalAPagar => valorConta + valorGorjeta;

  /// Quanto cada pessoa paga (já incluindo a parte da gorjeta).
  double get valorPorPessoa => valorTotalAPagar / quantidadePessoas;
}

// =====================================================================
// Conversão e formatação de números
// =====================================================================

/// Converte um double em texto no formato monetário brasileiro.
/// Ex.: 1234.5 -> "R$ 1.234,50"
String formatarReal(double valor) {
  final partes = valor.toStringAsFixed(2).split('.');
  final inteiros = partes[0].replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (_) => '.',
  );
  return 'R\$ $inteiros,${partes[1]}';
}

/// Converte o texto digitado pelo usuário em double.
/// Aceita tanto "1234.50" quanto "1.234,50" ou "1234,50".
/// Retorna null quando o texto não representa um número válido.
double? paraDouble(String texto) {
  var limpo = texto.trim();
  if (limpo.isEmpty) return null;
  // Se houver vírgula, ela é o separador decimal e o ponto é de milhar.
  if (limpo.contains(',')) {
    limpo = limpo.replaceAll('.', '').replaceAll(',', '.');
  }
  return double.tryParse(limpo);
}

// =====================================================================
// Campo de entrada reutilizável
// =====================================================================

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

// =====================================================================
// A tela e seu estado
// =====================================================================

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
    return null; // null significa campo válido
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

// =====================================================================
// O cartão de resultado
// =====================================================================

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
