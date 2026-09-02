/// Modelo de domínio: representa uma conta que será dividida entre
/// várias pessoas, com uma gorjeta (comissão do garçom) opcional.
///
/// Esta classe é Dart puro: NÃO importa nada do Flutter.
/// Isso permite testá-la de forma isolada, sem precisar de interface.
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
