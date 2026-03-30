import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MaterialApp(debugShowCheckedModeBanner: false, home: AppNotas()));
}

class AppNotas extends StatefulWidget {
  @override
  _AppNotasState createState() => _AppNotasState();
}

class _AppNotasState extends State<AppNotas> {
  List<String> notas = [];
  TextEditingController controller = TextEditingController();
  void adicionarNota() {
    if (controller.text.isNotEmpty) {
      setState(() {
        notas.add(controller.text);
        controller.clear();
      });
      salvarNotas();
    }
  }

  void removerNota(int index) {
    setState(() {
      notas.removeAt(index);
    });
    salvarNotas();
  }

  void salvarNotas() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setStringList("notas", notas);
  }

  void carregarNotas() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      notas = prefs.getStringList("notas") ?? [];
    });
  }

  @override
  void initState() {
    super.initState();
    carregarNotas();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Minhas Notas")),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(10),
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                labelText: "Digite uma nota",
                border: OutlineInputBorder(),
              ),
              onSubmitted: (_) => adicionarNota(),
            ),
          ),
          ElevatedButton(
            onPressed: adicionarNota,
            child: Text("Adicionar Nota"),
          ),
          Expanded(
            child: notas.isEmpty
                ? Center(child: Text("Nenhuma nota ainda"))
                : ListView.builder(
                    itemCount: notas.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(notas[index]),
                        trailing: IconButton(
                          icon: Icon(Icons.delete),

                          onPressed: () => removerNota(index),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
