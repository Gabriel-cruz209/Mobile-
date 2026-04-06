import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

void main() {
  runApp(MaterialApp(debugShowCheckedModeBanner: false, home: AppBanco()));
}

class AppBanco extends StatefulWidget {
  @override
  _AppBancoState createState() => _AppBancoState();
}

class _AppBancoState extends State<AppBanco> {
  TextEditingController controller = TextEditingController();
  List<Map<String, dynamic>> tarefas = [];

  Future<Database> criarBanco() async {
    final caminho = await getDatabasesPath();
    final path = join(caminho, "banco.db");

    return openDatabase(
      path,
      onCreate: (db, version) {
        return db.execute(
          "CREATE TABLE tarefas(id INTEGER PRIMARY KEY AUTOINCREMENT, nome TEXT)",
        );
      },
      version: 1,
    );
  }

  Future<void> inserirTarefa(String nome) async {
    final db = await criarBanco();

    await db.insert("tarefas", {"nome": nome});

    carregarTarefas();
  }

  Future<void> carregarTarefas() async {
    final db = await criarBanco();

    final lista = await db.query("tarefas");

    setState(() {
      tarefas = lista;
    });
  }

  Future<void> deletarTarefas(int id) async {
    final db = await criarBanco();
    await db.delete("tarefas", where: "id = ?", whereArgs: [id]);
    carregarTarefas();
  }

  @override
  void initState() {
    super.initState();
    carregarTarefas();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Banco de Dados")),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(10),
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                labelText: "Nova Tarefa",
                border: OutlineInputBorder(),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                inserirTarefa(controller.text);
                controller.clear();
              }
            },
            child: Text("Adicionar"),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: tarefas.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(tarefas[index]["nome"]),
                  trailing: IconButton(
                    onPressed: () {
                      deletarTarefas(tarefas[index]["id"]);
                    },
                    icon: Icon(Icons.delete),
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
