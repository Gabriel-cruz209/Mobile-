import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(debugShowCheckedModeBanner: false, home: telaInicio()));
}

// ------- TELA 01 -------

class telaInicio extends StatelessWidget {
  final String nome = "Gabriel";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text("Pagina Inicial", style: TextStyle(color: Colors.white)),
      ),
      body: Center(
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SegundaTela(nome: nome)),
            );
          },
          child: Text("Proxima Página", style: TextStyle(fontSize: 15)),
        ),
      ),
    );
  }
}

class SegundaTela extends StatelessWidget {
  final String nome;

  SegundaTela({required this.nome});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red,
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: Text("Segunda Tela", style: TextStyle(color: Colors.white)),
      ),
      body: Center(
        child: Text(
          "Ola $nome!, Seja Bem Vindo a segunda tela",
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
      ),
    );
  }
}
