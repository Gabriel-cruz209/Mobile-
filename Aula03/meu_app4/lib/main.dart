import 'dart:math';
import 'package:flutter/material.dart';


void main() {
  runApp(MaterialApp(home: PaginaNumeros(), debugShowCheckedModeBanner: false));
}

class PaginaNumeros extends StatefulWidget {
  @override
  _PaginaNumerosState createState() => _PaginaNumerosState();
}

class _PaginaNumerosState extends State<PaginaNumeros> {
  int numero = 0;

  void sortear() {
    setState(() {
      numero = Random().nextInt(11);
    });
  }

  void somar() {
    setState(() {
      numero++;
    });
  }

  void diminuir() {
    setState(() {
      numero--;
    });
  }

  void zerar() {
    setState(() {
      numero = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Meu Aplicativo")),
      body: Center(
        child: Text('Numero: $numero', style: TextStyle(fontSize: 30)),
      ),
      floatingActionButton: Row(children: [
        FloatingActionButton(onPressed: somar, backgroundColor: Colors.green, child: Icon(Icons.add),),
        FloatingActionButton(onPressed: diminuir, backgroundColor: Colors.red, child: Icon(Icons.remove),),
        FloatingActionButton(onPressed: zerar, backgroundColor: Colors.blueGrey, child: Text("Zerar", style: TextStyle(color: Colors.black),),),
        FloatingActionButton(onPressed: sortear, backgroundColor: Colors.purple, child: Text("Random", style: TextStyle(color: Colors.white),),),
      ],),
    );
  }
}
