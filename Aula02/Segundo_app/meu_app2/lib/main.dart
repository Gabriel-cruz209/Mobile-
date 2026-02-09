import 'package:flutter/material.dart';

void main() {
  runApp(const Myapp());
}

class Myapp extends StatelessWidget {
  const Myapp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner:
          false, // Tira a (faixa de Debug) no Canto que o Flutter Coloca
      theme: ThemeData(primarySwatch: Colors.indigo),
      home: const PaginaContador(),
    );
  }
}

class PaginaContador extends StatefulWidget {
  const PaginaContador({super.key});

  @override
  State<PaginaContador> createState() => _PaginaContadorState();
}

class _PaginaContadorState extends State<PaginaContador> {
  int numero = 0;

  void aumentar() {
    setState(() {
      numero++;
    });
  }

  void diminuir() {
    setState(() {
      numero--;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Teste Contador"),
        centerTitle: true,
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: Center(child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text("Contagem Atual", style: TextStyle(fontSize: 18),),
          Text("$numero",
          style: const TextStyle(
            fontSize: 80, fontWeight: FontWeight.bold,
            color: Colors.indigo,
          ),)
        ],
      ) ,),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(onPressed: diminuir,
          backgroundColor: Colors.red,
          child: const Icon(Icons.remove, color: Colors.white,),),
          
          const SizedBox(width: 15),

          FloatingActionButton(onPressed: aumentar,
          backgroundColor: Colors.green,
          child: const Icon(Icons.add, color: Colors.white,),)
        ],
      ),
    );
  }
}
