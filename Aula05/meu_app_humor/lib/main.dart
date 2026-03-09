import 'package:flutter/material.dart';

// Feliz
// Neutro
// Bravo
void main() {
  runApp(MaterialApp(debugShowCheckedModeBanner: false, home: Humor()));
}

class Humor extends StatefulWidget {
  @override
  _HumorState createState() => _HumorState();
}

class _HumorState extends State<Humor> {
  int humor = 0;

  void estadoHumor() {
    setState(() {
      if (humor <= 1) {
        humor++;
      } else {
        humor = 0;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: humor == 0
          ? Colors.yellow
          : humor == 1
          ? Colors.grey
          : Colors.red,
          appBar: AppBar(
            backgroundColor: humor == 0
          ? Colors.yellow
          : humor == 1
          ? Colors.grey
          : Colors.red,
          title: Text("Emoções", style: TextStyle(color: humor == 0 ? Colors.yellow: humor == 1 ? Colors.grey: Colors.red),),
          ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center, children: [Text(
              humor == 0 ? "😁" : humor == 1? " 😐 " : " 😡 ", style: TextStyle(fontSize: 60),
            ), ElevatedButton(onPressed: estadoHumor, style: ElevatedButton.styleFrom(
              backgroundColor: humor == 0 ? Colors.yellow : humor == 1 ? Colors.grey : Colors.red,
            ),child: Text(humor == 0 ? "Feliz" : humor == 1 ? "Neutro" : "Bravo",) ,)],
          ),
        ),
    );
  }
}
