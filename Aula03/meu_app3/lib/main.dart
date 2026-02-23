import 'package:flutter/material.dart';

void main() {
  runApp(
    MaterialApp(home: PaginaContador(), debugShowCheckedModeBanner: false),
  );
}

class PaginaContador extends StatefulWidget {
  @override
  _PaginaContadorState createState() => _PaginaContadorState();
}

class _PaginaContadorState extends State<PaginaContador> {
  int contador = 0;
  int sorte = 0;

  void sortear(){
    setState(() {
      
    });
  }

  void incremente() {
    setState(() {
      contador++;
    });
  }

  void diminuir() {
    setState(() {
      contador--;
    });
  }

  void zerar() {
    setState(() {
      contador = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Meu App Contador")),
      body: Center(
        child: Text("Cliques: $contador", style: TextStyle(fontSize: 30)),
      ),
      floatingActionButton: Row(
        children: [
          FloatingActionButton(
            onPressed: incremente,
            backgroundColor: Colors.green,
            child: Icon(Icons.add),
          ),
          FloatingActionButton(
            onPressed: diminuir,
            backgroundColor: Colors.red,
            child: Icon(Icons.remove),
          ),
          FloatingActionButton(
            onPressed: zerar,
            backgroundColor: Colors.black,
            child: Text("zerar", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
