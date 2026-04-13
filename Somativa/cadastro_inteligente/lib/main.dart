import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

void main() {
  runApp(MaterialApp(debugShowCheckedModeBanner: false, home: AppCadastro()));
}

class AppCadastro extends StatefulWidget {
  @override
  _AppCadastroState createState() => _AppCadastroState();
}

class _AppCadastroState extends State<AppCadastro> {
  TextEditingController controller = TextEditingController();
  TextEditingController controllerDescricao = TextEditingController();
  List<Map<String, dynamic>> dados = [];

  Future<Database> criarBanco() async {
    final caminho = await getDatabasesPath();
    final path = join(caminho, "banco.db");

    return openDatabase(
      path,
      onCreate: (db, version) {
        return db.execute(
          "CREATE TABLE dados (id INTEGER PRIMARY KEY AUTOINCREMENT, titulo TEXT, descricao TEXT, data TEXT)",
        );
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute("ALTER TABLE dados ADD COLUMN data TEXT");
        }
      },
      version: 2,
    );
  }

  Future<void> inserirDados(String titulo, String descricao) async {
    final db = await criarBanco();
    final agora = DateTime.now();
    final dataFormatada =
        "${agora.day.toString().padLeft(2, '0')}/${agora.month.toString().padLeft(2, '0')}/${agora.year} "
        "${agora.hour.toString().padLeft(2, '0')}:${agora.minute.toString().padLeft(2, '0')}";

    await db.insert("dados", {
      "titulo": titulo,
      "descricao": descricao,
      "data": dataFormatada,
    });

    carregarDados();
  }

  Future<void> carregarDados() async {
    final db = await criarBanco();

    final lista = await db.query("dados", orderBy: "titulo ASC");

    setState(() {
      dados = lista;
    });
  }

  Future<void> deletarDados(int id) async {
    final db = await criarBanco();
    await db.delete("dados", where: "id = ?", whereArgs: [id]);
    carregarDados();
  }

  Future<void> atualizarDados(int id, String titulo, String descricao) async {
    final db = await criarBanco();
    await db.update(
      "dados",
      {"titulo": titulo, "descricao": descricao},
      where: "id = ?",
      whereArgs: [id],
    );
    carregarDados();
  }

  void abrirEdicao(BuildContext ctx, Map<String, dynamic> item) {
    final editTitulo = TextEditingController(text: item["titulo"]);
    final editDescricao = TextEditingController(text: item["descricao"]);

    showDialog(
      context: ctx,
      builder: (buildContext) {
        return AlertDialog(
          title: Text("Editar Cadastro"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: editTitulo,
                decoration: InputDecoration(
                  labelText: "Título",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: editDescricao,
                decoration: InputDecoration(
                  labelText: "Descrição",
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(buildContext),
              child: Text("Cancelar"),
            ),
            ElevatedButton(
              onPressed: () {
                if (editTitulo.text.isNotEmpty) {
                  atualizarDados(
                    item["id"],
                    editTitulo.text,
                    editDescricao.text,
                  );
                  Navigator.pop(buildContext);
                }
              },
              child: Text("Salvar"),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    carregarDados();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Cadastros de dados')),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(10),
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                labelText: "Título",
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(10, 0, 10, 10),
            child: TextField(
              controller: controllerDescricao,
              decoration: InputDecoration(
                labelText: "Descrição",
                border: OutlineInputBorder(),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                inserirDados(controller.text, controllerDescricao.text);
                controller.clear();
                controllerDescricao.clear();
              }
            },
            child: Text("Salvar"),
          ),
          Expanded(
            child: dados.isEmpty
                ? Center(
                    child: Text(
                      "Nenhum item cadastrado",
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    itemCount: dados.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(dados[index]["titulo"] ?? ""),
                        subtitle: Text(
                          "${dados[index]["descricao"] ?? ""}\nCriado em: ${dados[index]["data"] ?? ""}",
                        ),
                        isThreeLine: true,
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              onPressed: () {
                                abrirEdicao(context, dados[index]);
                              },
                              icon: Icon(Icons.edit),
                            ),
                            IconButton(
                              onPressed: () {
                                deletarDados(dados[index]["id"]);
                              },
                              icon: Icon(Icons.delete),
                            ),
                          ],
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
