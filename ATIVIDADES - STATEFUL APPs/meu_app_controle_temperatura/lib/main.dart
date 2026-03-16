import 'package:flutter/material.dart';

void main() {
  runApp(const TemperaturaRootApp());
}

class TemperaturaRootApp extends StatelessWidget {
  const TemperaturaRootApp({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF0EA5E9),
      brightness: Brightness.dark,
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: colorScheme,
        scaffoldBackgroundColor: Colors.transparent,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.transparent,
        ),
      ),
      home: TemperaturaApp(),
    );
  }
}

class TemperaturaApp extends StatefulWidget {
  @override
  _TemperaturaAppState createState() => _TemperaturaAppState();
}

class _TemperaturaAppState extends State<TemperaturaApp> {
  int temperatura = 20;

  void aumentar() {
    setState(() {
      temperatura++;
    });
  }

  void diminuir() {
    setState(() {
      temperatura--;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Color corBase;
    IconData icone;
    String status;

    if (temperatura < 15) {
      corBase = const Color(0xFF38BDF8); // frio
      icone = Icons.ac_unit;
      status = "Frio";
    } else if (temperatura < 30) {
      corBase = const Color(0xFF22C55E); // agradável
      icone = Icons.wb_sunny;
      status = "Agradável";
    } else {
      corBase = const Color(0xFFFB7185); // quente
      icone = Icons.local_fire_department;
      status = "Quente";
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(title: const Text("Controle de Temperatura")),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF020617),
              corBase.withValues(alpha: 0.35),
              const Color(0xFF0B1020),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Card(
                  elevation: 0,
                  color: theme.colorScheme.surface.withValues(alpha: 0.6),
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
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                corBase.withValues(alpha: 0.25),
                                theme.colorScheme.surface,
                              ],
                            ),
                            border: Border.all(
                              color: theme.colorScheme.outline.withValues(alpha: 0.2),
                            ),
                          ),
                          child: Icon(icone, size: 64, color: corBase),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          status,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "$temperatura °C",
                          style: theme.textTheme.displaySmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            letterSpacing: -1,
                          ),
                        ),
                        const SizedBox(height: 18),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton.filledTonal(
                              onPressed: diminuir,
                              icon: const Icon(Icons.remove),
                              tooltip: "Diminuir",
                            ),
                            const SizedBox(width: 16),
                            IconButton.filled(
                              onPressed: aumentar,
                              icon: const Icon(Icons.add),
                              tooltip: "Aumentar",
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Opacity(
                          opacity: 0.8,
                          child: Text(
                            "Frio < 15°C • Agradável 15–29°C • Quente ≥ 30°C",
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodySmall,
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
