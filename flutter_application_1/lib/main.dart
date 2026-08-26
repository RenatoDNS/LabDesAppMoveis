import 'package:flutter/material.dart';

  void main() {
  runApp(MaterialApp(home: Home()));
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  var num1 = TextEditingController();
  var num2 = TextEditingController();
  double total = 0;
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Calculadora")),
      body: body(),
    );
  }

  Widget body(){
    return Column(children: [
        Text("Valor 1"),
        TextField(
            decoration: InputDecoration(labelText: "Digite um número"),
            controller: num1,
          ),
        Text("Valor 2"),
        TextField(
            decoration: InputDecoration(labelText: "Digite um número"),
            controller: num2,
          ),
        ElevatedButton(onPressed: calcular, child: Text("Calcular")),
        Text("A soma é: " + total.toString()),
      ],
    );
  }

  void calcular() {
    total = double.parse(num1.text) + double.parse(num2.text);
    setState(() {});
  }   
}

