import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lista_contatos/main.dart';

void main() {
  testWidgets('lista os 5 contatos com nome e telefone', (tester) async {
    await tester.pumpWidget(const ListaContatosApp());

    expect(find.byType(ListTile), findsNWidgets(5));
    for (final contato in contatos) {
      expect(find.text(contato.nome), findsOneWidget);
      expect(find.text(contato.telefone), findsOneWidget);
    }
    // Cada item tem a sua foto.
    expect(find.byType(FotoContato), findsNWidgets(5));
  });

  testWidgets('ao tocar no contato, abre a tela com o nome no AppBar',
      (tester) async {
    await tester.pumpWidget(const ListaContatosApp());

    final contato = contatos[2];
    await tester.tap(find.text(contato.nome));
    await tester.pumpAndSettle();

    expect(find.byType(TelaDetalheContato), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(AppBar),
        matching: find.text(contato.nome),
      ),
      findsOneWidget,
    );
    expect(find.text(contato.telefone), findsOneWidget);

    // O botão voltar do AppBar retorna para a lista.
    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(find.byType(TelaDetalheContato), findsNothing);
    expect(find.byType(ListTile), findsNWidgets(5));
  });
}
