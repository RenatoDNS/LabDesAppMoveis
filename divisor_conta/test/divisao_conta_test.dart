import 'package:flutter_test/flutter_test.dart';
import 'package:divisor_conta/main.dart';

void main() {
  group('DivisaoConta', () {
    test('calcula gorjeta, total e valor por pessoa', () {
      const d = DivisaoConta(
        valorConta: 250,
        quantidadePessoas: 4,
        percentualGorjeta: 10,
      );

      expect(d.valorGorjeta, closeTo(25.0, 0.001));
      expect(d.valorTotalAPagar, closeTo(275.0, 0.001));
      expect(d.valorPorPessoa, closeTo(68.75, 0.001));
    });

    test('gorjeta zero não altera o total', () {
      const d = DivisaoConta(
        valorConta: 100,
        quantidadePessoas: 3,
        percentualGorjeta: 0,
      );

      expect(d.valorGorjeta, 0);
      expect(d.valorTotalAPagar, 100);
      expect(d.valorPorPessoa, closeTo(33.333, 0.001));
    });

    test('uma pessoa paga o total', () {
      const d = DivisaoConta(
        valorConta: 80,
        quantidadePessoas: 1,
        percentualGorjeta: 10,
      );

      expect(d.valorPorPessoa, closeTo(d.valorTotalAPagar, 0.001));
    });
  });
}
