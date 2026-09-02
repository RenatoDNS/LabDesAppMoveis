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
