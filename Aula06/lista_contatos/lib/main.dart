import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lista de Contatos',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const ListaContatos(),
    );
  }
}


class Contato {
  final String nome;
  final String telefone;
  final IconData icone;
  final Color cor;

  const Contato({
    required this.nome,
    required this.telefone,
    required this.icone,
    required this.cor,
  });
}

// -------- TELA 01 --------

class ListaContatos extends StatelessWidget {
  const ListaContatos({super.key});

  static const List<Contato> _contatos = [
    Contato(
      nome: 'Ana Silva',
      telefone: '(11) 91234-5678',
      icone: Icons.person,
      cor: Colors.indigo,
    ),
    Contato(
      nome: 'Bruno Oliveira',
      telefone: '(21) 98765-4321',
      icone: Icons.person_2,
      cor: Colors.teal,
    ),
    Contato(
      nome: 'Carla Santos',
      telefone: '(31) 99999-0000',
      icone: Icons.person_3,
      cor: Colors.deepOrange,
    ),
    Contato(
      nome: 'Daniel Costa',
      telefone: '(41) 97777-8888',
      icone: Icons.person_4,
      cor: Colors.purple,
    ),
    Contato(
      nome: 'Eduarda Lima',
      telefone: '(51) 96666-1111',
      icone: Icons.face,
      cor: Colors.green,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: const Text(
          'Meus Contatos',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        itemCount: _contatos.length,
        separatorBuilder: (context, index) => const SizedBox(height: 6),
        itemBuilder: (context, index) {
          final contato = _contatos[index];
          return _ContatoCard(contato: contato);
        },
      ),
    );
  }
}


class _ContatoCard extends StatelessWidget {
  final Contato contato;

  const _ContatoCard({required this.contato});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: contato.cor,
          radius: 26,
          child: Icon(contato.icone, color: Colors.white, size: 28),
        ),
        title: Text(
          contato.nome,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Text(
          contato.telefone,
          style: TextStyle(color: Colors.grey[600]),
        ),
        trailing: Icon(Icons.arrow_forward_ios,
            size: 16, color: contato.cor),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetalheContato(
                nome: contato.nome,
                telefone: contato.telefone,
                icone: contato.icone,
                cor: contato.cor,
              ),
            ),
          );
        },
      ),
    );
  }
}

// ------- TELA 02 ----------

class DetalheContato extends StatefulWidget {
  final String nome;
  final String telefone;
  final IconData icone;
  final Color cor;

  const DetalheContato({
    super.key,
    required this.nome,
    required this.telefone,
    required this.icone,
    required this.cor,
  });

  @override
  State<DetalheContato> createState() => _DetalheContatoState();
}

class _DetalheContatoState extends State<DetalheContato> {
  String _mensagem = '';

  void _ligar() {
    setState(() {
      _mensagem = 'Ligando para ${widget.nome}...';
    });

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() => _mensagem = '');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: widget.cor,
        title: const Text(
          'Detalhes',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                backgroundColor: widget.cor,
                radius: 60,
                child: Icon(widget.icone, color: Colors.white, size: 64),
              ),
              const SizedBox(height: 28),

              Text(
                widget.nome,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.phone, color: widget.cor),
                  const SizedBox(width: 8),
                  Text(
                    widget.telefone,
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),

              ElevatedButton.icon(
                onPressed: _ligar,
                icon: const Icon(Icons.call),
                label: const Text('Ligar', style: TextStyle(fontSize: 16)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.cor,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              if (_mensagem.isNotEmpty)
                AnimatedOpacity(
                  opacity: _mensagem.isNotEmpty ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 400),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: widget.cor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _mensagem,
                      style: TextStyle(
                        color: widget.cor,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

              const SizedBox(height: 32),

              OutlinedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Voltar', style: TextStyle(fontSize: 16)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: widget.cor,
                  side: BorderSide(color: widget.cor, width: 2),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
