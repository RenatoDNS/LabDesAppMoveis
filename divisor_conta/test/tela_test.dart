import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:divisor_conta/main.dart';

void main() {
  testWidgets('exibe o resultado após preencher e calcular', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: DivisorHomePage()),
    );

    // Antes de calcular, o cartão não existe.
    expect(find.text('Resultado'), findsNothing);

    // Preenche o primeiro campo (valor da conta).
    await tester.enterText(find.byType(TextFormField).first, '250');

    await tester.tap(find.text('Calcular'));
    await tester.pumpAndSettle();

    expect(find.text('Resultado'), findsOneWidget);
    expect(find.text('R\$ 25,00'), findsOneWidget);
    expect(find.text('R\$ 275,00'), findsOneWidget);
    expect(find.text('R\$ 137,50'), findsOneWidget); // 2 pessoas (valor padrão)
  });
}
