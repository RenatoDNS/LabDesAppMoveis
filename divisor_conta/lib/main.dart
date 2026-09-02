import 'package:flutter/material.dart';

import 'screens/divisor_home_page.dart';

void main() {
  runApp(const DivisorDeContaApp());
}

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
