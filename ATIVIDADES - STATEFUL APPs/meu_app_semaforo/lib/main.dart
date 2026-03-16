import 'package:flutter/material.dart';

void main() {
  runApp(const SemaforoRootApp());
}

class SemaforoRootApp extends StatelessWidget {
  const SemaforoRootApp({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF2563EB),
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
      home: SemaforoApp(),
    );
  }
}

class SemaforoApp extends StatefulWidget {
  @override
  _SemaforoAppState createState() => _SemaforoAppState();
}

class _SemaforoAppState extends State<SemaforoApp> {
  int estado = 0;

  void mudarSemaforo() {
    setState(() {
      estado++;
      if (estado > 2) {
        estado = 0;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("Semáforo de Trânsito"),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF020617),
              Color(0xFF0F172A),
              Color(0xFF020617),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Card(
                      elevation: 0,
                      color: theme.colorScheme.surface.withValues(alpha: 0.6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                        side: BorderSide(
                          color: theme.colorScheme.outline.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 24,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "Semáforo",
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Container(
                              width: 130,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 14,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(26),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black54,
                                    blurRadius: 16,
                                    offset: Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  _LuzSemaforo(
                                    ativa: estado == 2,
                                    corAtiva: Colors.red,
                                  ),
                                  const SizedBox(height: 10),
                                  _LuzSemaforo(
                                    ativa: estado == 1,
                                    corAtiva: Colors.yellow,
                                  ),
                                  const SizedBox(height: 10),
                                  _LuzSemaforo(
                                    ativa: estado == 0,
                                    corAtiva: Colors.green,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  estado == 2
                                      ? Icons.directions_walk
                                      : Icons.pan_tool_alt_outlined,
                                  size: 56,
                                  color:
                                      estado == 2 ? Colors.greenAccent : Colors.redAccent,
                                ),
                                const SizedBox(width: 12),
                                Flexible(
                                  child: Text(
                                    estado == 2
                                        ? "PEDESTRE: ATRAVESSE"
                                        : "PEDESTRE: AGUARDE",
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            SizedBox(
                              width: double.infinity,
                              child: FilledButton.icon(
                                onPressed: mudarSemaforo,
                                icon: const Icon(Icons.sync),
                                label: const Text("Mudar semáforo"),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Opacity(
                      opacity: 0.8,
                      child: Text(
                        "Toque no botão para alternar entre verde, amarelo e vermelho.",
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
    );
  }
}

class _LuzSemaforo extends StatelessWidget {
  final bool ativa;
  final Color corAtiva;

  const _LuzSemaforo({
    required this.ativa,
    required this.corAtiva,
  });

  @override
  Widget build(BuildContext context) {
    final corBase = ativa ? corAtiva : Colors.grey[700]!;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      width: 76,
      height: 76,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            ativa ? corBase.withValues(alpha: 0.1) : Colors.black,
            corBase,
          ],
        ),
        boxShadow: ativa
            ? [
                BoxShadow(
                  color: corAtiva.withValues(alpha: 0.7),
                  blurRadius: 18,
                  spreadRadius: 1,
                ),
              ]
            : const [],
      ),
    );
  }
}
