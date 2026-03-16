import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(const MiniGameApp());
}

class MiniGameApp extends StatelessWidget {
  const MiniGameApp({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF6D28D9),
      brightness: Brightness.dark,
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: colorScheme,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
        ),
      ),
      home: JogoApp(),
    );
  }
}

class JogoApp extends StatefulWidget {
  @override
  _JogoAppState createState() => _JogoAppState();
}

class _JogoAppState extends State<JogoApp> {
  IconData iconeComputador = Icons.hd;
  String resultado = "Escolha uma opção";
  int pontosJogador = 0;
  int pontosComputador = 0;
  List opcoes = ["pedra", "papel", "tesoura"];

  void jogar(String escolhaUsuario) {
    var numero = Random().nextInt(3);
    var escolhaComputador = opcoes[numero];
    setState(() {
      if (escolhaComputador == "pedra") {
        iconeComputador = Icons.landscape;
      }
      if (escolhaComputador == "papel") {
        iconeComputador = Icons.pan_tool;
      }
      if (escolhaComputador == "tesoura") {
        iconeComputador = Icons.content_cut;
      }
    });
    if (escolhaUsuario == escolhaComputador) {
      resultado = "Empate";
    } else if ((escolhaUsuario == "pedra" && escolhaComputador == "tesoura") ||
        (escolhaUsuario == "papel" && escolhaComputador == "pedra") ||
        (escolhaUsuario == "tesoura" && escolhaComputador == "papel")) {
      pontosJogador++;
      resultado = "Você venceu!";
    } else {
      pontosComputador++;
      resultado = "Computador venceu!";
    }
    pontosJogador++;
    if (pontosJogador == 5 && pontosComputador == 5) {
      resultado = " Você ganhou o campeonato!";
      pontosJogador = 0;
      pontosComputador = 0;
    }
  }

  void resetarPlacar() {
    setState(() {
      pontosComputador = 0;
      pontosJogador = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text("Pedra • Papel • Tesoura"),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0B1020),
              Color(0xFF1B1038),
              Color(0xFF0B1020),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Card(
                  elevation: 0,
                  color: theme.colorScheme.surface.withValues(alpha: 0.55),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                    side: BorderSide(
                      color: theme.colorScheme.outline.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Computador",
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.85),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surface.withValues(alpha: 0.7),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: theme.colorScheme.outline.withValues(alpha: 0.2),
                            ),
                          ),
                          child: Icon(iconeComputador, size: 72),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          resultado,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          alignment: WrapAlignment.center,
                          children: [
                            _ScoreChip(
                              label: "Você",
                              value: pontosJogador.toString(),
                              color: theme.colorScheme.primary,
                            ),
                            _ScoreChip(
                              label: "PC",
                              value: pontosComputador.toString(),
                              color: theme.colorScheme.tertiary,
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Sua jogada",
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.85),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          alignment: WrapAlignment.center,
                          children: [
                            _ChoiceButton(
                              icon: Icons.landscape,
                              label: "Pedra",
                              onPressed: () => jogar("pedra"),
                            ),
                            _ChoiceButton(
                              icon: Icons.pan_tool,
                              label: "Papel",
                              onPressed: () => jogar("papel"),
                            ),
                            _ChoiceButton(
                              icon: Icons.content_cut,
                              label: "Tesoura",
                              onPressed: () => jogar("tesoura"),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.tonalIcon(
                            onPressed: resetarPlacar,
                            icon: const Icon(Icons.refresh),
                            label: const Text("Resetar placar"),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ChoiceButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const _ChoiceButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 150,
      height: 52,
      child: FilledButton.tonalIcon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label),
      ),
    );
  }
}

class _ScoreChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _ScoreChip({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.85),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.2)),
            ),
            child: Text(
              value,
              style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }
}
