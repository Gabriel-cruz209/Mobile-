import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MaterialApp(debugShowCheckedModeBanner: false, home: ListaCompras()));
}

class ListaCompras extends StatefulWidget {
  @override
  _ListaComprasState createState() => _ListaComprasState();
}

class _ListaComprasState extends State<ListaCompras> {
  List<String> itens = [];
  List<bool> comprado = [];
  TextEditingController controller = TextEditingController();

  // PASSO 1 – Adicionar item
  void adicionarItem() {
    if (controller.text.isNotEmpty) {
      setState(() {
        itens.add(controller.text);
        comprado.add(false);
        controller.clear();
      });
      salvarDados();
    }
  }

  // PASSO 2 – Alternar comprado
  void alternarComprado(int index) {
    setState(() {
      comprado[index] = !comprado[index];
    });
    salvarDados();
  }

  void removerItem(int index) {
    setState(() {
      itens.removeAt(index);
      comprado.removeAt(index);
    });
    salvarDados();
  }

  void limparLista() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Limpar Lista"),
        content: Text("Deseja realmente limpar toda a lista?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancelar"),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                itens.clear();
                comprado.clear();
              });
              salvarDados();
              Navigator.pop(context);
            },
            child: Text("Limpar", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // PASSO 3 – Salvar dados
  void salvarDados() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setStringList("itens", itens);
    prefs.setStringList("comprado", comprado.map((e) => e.toString()).toList());
  }

  // PASSO 4 – Carregar dados
  void carregarDados() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      itens = prefs.getStringList("itens") ?? [];
      List<String> listaBool = prefs.getStringList("comprado") ?? [];
      comprado = listaBool.map((e) => e == "true").toList();
    });
  }

  @override
  void initState() {
    super.initState();
    carregarDados();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  int get totalComprados => comprado.where((e) => e).length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Lista de Compras"),
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Contador de itens
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(15),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Total: ${itens.length} itens",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  "Comprados: $totalComprados",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          // Campo de entrada
          Padding(
            padding: EdgeInsets.all(10),
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                labelText: "Adicione um item",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.shopping_cart),
              ),
              onSubmitted: (_) => adicionarItem(),
            ),
          ),
          // Botões
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: adicionarItem,
                  icon: Icon(Icons.add),
                  label: Text("Adicionar"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: itens.isEmpty ? null : limparLista,
                  icon: Icon(Icons.delete_sweep),
                  label: Text("Limpar"),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                ),
              ],
            ),
          ),
          SizedBox(height: 10),
          // Lista de itens
          Expanded(
            child: itens.isEmpty
                ? Center(
                    child: Text(
                      "Nenhum item na lista",
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    itemCount: itens.length,
                    itemBuilder: (context, index) {
                      return Card(
                        margin: EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        child: ListTile(
                          // DESAFIO VISUAL - Checkbox com cor
                          leading: Checkbox(
                            value: comprado[index],
                            onChanged: (_) => alternarComprado(index),
                            activeColor: Colors.white,
                          ),
                          // Texto riscado se comprado
                          title: Text(
                            itens[index],
                            style: TextStyle(
                              fontSize: 16,
                              decoration: comprado[index]
                                  ? TextDecoration.lineThrough
                                  : TextDecoration.none,
                              color: comprado[index]
                                  ? Colors.grey
                                  : Colors.black,
                              fontWeight: comprado[index]
                                  ? FontWeight.normal
                                  : FontWeight.w500,
                            ),
                          ),
                          // Cor de fundo diferente quando comprado
                          tileColor: comprado[index]
                              ? Colors.white
                              : Colors.transparent,
                          // Botão de deletar
                          trailing: IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () => removerItem(index),
                          ),
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
