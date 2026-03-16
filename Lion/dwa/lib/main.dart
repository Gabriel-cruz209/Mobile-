import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

void main() => runApp(CasinoApp());

class CasinoApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.green,
      ),
      home: CasinoTabs(),
    );
  }
}

class CasinoTabs extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3, // Atualizado para 3 abas
      child: Scaffold(
        bottomNavigationBar: const TabBar(
          tabs: [
            Tab(icon: Icon(Icons.style), text: "Blackjack"),
            Tab(icon: Icon(Icons.casino), text: "Slots"),
            Tab(
              icon: Icon(Icons.pan_tool),
              text: "Truco",
            ), // Ícone de mão para Truco
          ],
          indicatorColor: Colors.yellow,
        ),
        body: TabBarView(
          children: [
            BlackjackGame(),
            SlotMachineGame(),
            TrucoGame(), // Novo Módulo
          ],
        ),
      ),
    );
  }
}

// --- MÓDULO TRUCO (NOVO) ---
class TrucoGame extends StatefulWidget {
  @override
  _TrucoGameState createState() => _TrucoGameState();
}

class _TrucoGameState extends State<TrucoGame> {
  // Truco (modelo simplificado porém mais realista):
  // - Vira define a Manilha (rank seguinte)
  // - Manilhas ganham de todas; desempate por hierarquia de naipes
  // Observação: não modela as manilhas fixas do Truco Paulista (4♣,7♥,A♠,7♦),
  // mas já deixa o jogo bem mais próximo do "vira/manilha" comum.
  final List<String> _ranksTruco = ['4', '5', '6', '7', 'Q', 'J', 'K', 'A', '2', '3'];
  final Map<String, int> _suitPower = {
    '♦️': 1,
    '♣️': 2,
    '♥️': 3,
    '♠️': 4,
  };

  List<CardModel> playerHand = [];
  List<CardModel> dealerHand = [];
  CardModel? lastPlayerCard;
  CardModel? lastDealerCard;
  CardModel? vira;
  String? manilhaRank;
  bool dealerLeadsTrick = false;

  int pontosPlayer = 0;
  int pontosDealer = 0;
  int rodadaVale = 1; // 1 normal, 3 se truco aceito
  String? trucoPendencia; // "player" | "dealer" | null

  // Placar das quedas: 1 = Você, 2 = Dealer, 0 = Empate
  List<int> quedasVencidas = [];
  String message = "Melhor de 3 quedas!";
  bool handOver = false;

  @override
  void initState() {
    super.initState();
    _startNewHand();
  }

  void _startNewHand() {
    setState(() {
      var deck = _generateTrucoDeck();
      deck.shuffle();
      // Distribui 3 cartas para cada
      playerHand = [deck.removeLast(), deck.removeLast(), deck.removeLast()];
      dealerHand = [deck.removeLast(), deck.removeLast(), deck.removeLast()];
      vira = deck.removeLast();
      manilhaRank = _nextRank(vira!.rank);
      quedasVencidas = [];
      lastPlayerCard = null;
      lastDealerCard = null;
      dealerLeadsTrick = false;
      rodadaVale = 1;
      trucoPendencia = null;
      message =
          "Vira: ${vira!.rank}${vira!.suit} • Manilha: $manilhaRank\nSua vez! Escolha uma carta.";
      handOver = false;

      // Dealer pode pedir truco logo no início se achar a mão forte
      _maybeDealerCallsTruco();
    });
  }

  List<CardModel> _generateTrucoDeck() {
    List<String> suits = ['♥️', '♠️', '♦️', '♣️'];
    List<String> ranks = ['4', '5', '6', '7', 'Q', 'J', 'K', 'A', '2', '3'];
    return [
      for (var s in suits)
        for (var r in ranks) CardModel(suit: s, rank: r, value: 0),
    ];
  }

  String _nextRank(String rank) {
    final idx = _ranksTruco.indexOf(rank);
    if (idx == -1) return _ranksTruco.first;
    return _ranksTruco[(idx + 1) % _ranksTruco.length];
  }

  int _rankBasePower(String rank) {
    final idx = _ranksTruco.indexOf(rank);
    if (idx == -1) return 0;
    return idx + 1; // 1..10
  }

  int _trucoPower(CardModel c) {
    // Manilha ganha de tudo. Desempate por naipe.
    final isManilha = (manilhaRank != null && c.rank == manilhaRank);
    if (isManilha) {
      final suitP = _suitPower[c.suit] ?? 0;
      return 100 + suitP; // sempre maior que qualquer base
    }
    return _rankBasePower(c.rank);
  }

  int _compareCards(CardModel a, CardModel b) {
    final pa = _trucoPower(a);
    final pb = _trucoPower(b);
    if (pa != pb) return pa.compareTo(pb);
    // Empate: se ambos são manilha, desempate por naipe já está no power.
    // Se ambos não são manilha, empate real.
    return 0;
  }

  CardModel _dealerChooseCard({required bool dealerIsLeading, CardModel? playerCard}) {
    // Heurística simples:
    // - Se o dealer responde, tenta vencer gastando a menor carta que ganhe.
    // - Se não dá para vencer, joga a menor carta (economiza força).
    // - Se o dealer puxa a rodada, prefere carta "média" no começo para não torrar manilha cedo.
    final hand = List<CardModel>.from(dealerHand);
    hand.sort((a, b) => _trucoPower(a).compareTo(_trucoPower(b)));

    if (!dealerIsLeading && playerCard != null) {
      final winners = hand.where((c) => _compareCards(c, playerCard) > 0).toList();
      if (winners.isNotEmpty) return winners.first;
      return hand.first;
    }

    // Dealer lidera
    if (hand.length <= 1) return hand.first;
    // tenta não abrir com manilha se existir alternativa
    final nonManilhas = hand.where((c) => c.rank != manilhaRank).toList();
    final candidates = nonManilhas.isNotEmpty ? nonManilhas : hand;
    candidates.sort((a, b) => _trucoPower(a).compareTo(_trucoPower(b)));
    // carta do meio (mais "humana")
    return candidates[(candidates.length / 2).floor()];
  }

  int _handStrength(List<CardModel> hand) {
    // Soma do poder das cartas (manilhas valem muito).
    return hand.fold<int>(0, (acc, c) => acc + _trucoPower(c));
  }

  void _maybeDealerCallsTruco() {
    if (handOver) return;
    if (trucoPendencia != null || rodadaVale > 1) return;
    if (dealerHand.isEmpty) return;

    final strength = _handStrength(dealerHand);
    // limiar ajustado para ser relativamente agressivo quando tem manilha
    final hasManilha = dealerHand.any((c) => c.rank == manilhaRank);
    final threshold = hasManilha ? 220 : 165;
    if (strength >= threshold) {
      trucoPendencia = "dealer";
      message =
          "O DEALER PEDIU TRUCO!\nVira: ${vira!.rank}${vira!.suit} • Manilha: $manilhaRank";
    }
  }

  void _playerCallsTruco() {
    if (handOver) return;
    if (trucoPendencia != null || rodadaVale > 1) return;
    setState(() {
      trucoPendencia = "player";
      message = "VOCÊ PEDIU TRUCO!\nAguardando resposta do dealer...";
    });

    // Dealer decide aceitar ou correr (IA simples)
    Future.delayed(const Duration(milliseconds: 550), () {
      if (!mounted) return;
      if (handOver) return;
      if (trucoPendencia != "player") return;

      final strength = _handStrength(dealerHand);
      final hasManilha = dealerHand.any((c) => c.rank == manilhaRank);
      final acceptThreshold = hasManilha ? 150 : 175;

      if (strength >= acceptThreshold) {
        setState(() {
          rodadaVale = 3;
          trucoPendencia = null;
          message =
              "DEALER ACEITOU! Agora a rodada vale $rodadaVale pontos.\nSua vez!";
        });
      } else {
        setState(() {
          pontosPlayer += 1; // quem pediu ganha 1 se o outro corre
          handOver = true;
          trucoPendencia = null;
          message = "DEALER CORREU! Você ganhou 1 ponto.\nPlacar: Você $pontosPlayer x $pontosDealer Dealer";
        });
      }
    });
  }

  void _acceptTruco() {
    if (handOver) return;
    if (trucoPendencia != "dealer") return;
    setState(() {
      rodadaVale = 3;
      trucoPendencia = null;
      message =
          "Você ACEITOU! Agora a rodada vale $rodadaVale pontos.\nJogue uma carta.";
    });
  }

  void _runFromTruco() {
    if (handOver) return;
    if (trucoPendencia != "dealer") return;
    setState(() {
      pontosDealer += 1; // quem pediu ganha 1 ponto
      handOver = true;
      trucoPendencia = null;
      message =
          "Você CORREU! Dealer ganhou 1 ponto.\nPlacar: Você $pontosPlayer x $pontosDealer Dealer";
    });
  }

  void _playCard(CardModel card) {
    if (handOver) return;
    if (trucoPendencia == "dealer") return; // precisa responder o truco antes

    setState(() {
      if (dealerLeadsTrick) {
        // Dealer abre a queda, jogador responde (aqui)
        final dealerCard = _dealerChooseCard(dealerIsLeading: true);
        dealerHand.remove(dealerCard);
        lastDealerCard = dealerCard;

        lastPlayerCard = card;
        playerHand.remove(card);
      } else {
        // Jogador abre, dealer responde
        lastPlayerCard = card;
        playerHand.remove(card);

        final dealerCard =
            _dealerChooseCard(dealerIsLeading: false, playerCard: lastPlayerCard);
        dealerHand.remove(dealerCard);
        lastDealerCard = dealerCard;
      }

      final cmp = _compareCards(lastPlayerCard!, lastDealerCard!);
      if (cmp > 0) {
        quedasVencidas.add(1);
        message = "Você ganhou esta queda!";
        dealerLeadsTrick = false;
      } else if (cmp < 0) {
        quedasVencidas.add(2);
        message = "Dealer ganhou esta queda!";
        dealerLeadsTrick = true;
      } else {
        quedasVencidas.add(0);
        message = "Empatou (Canguá)!";
        // em empate, mantém a liderança para a próxima como estava (jogo mais equilibrado)
      }

      _checkWinner();
      if (!handOver && dealerLeadsTrick) {
        message =
            "Vira: ${vira!.rank}${vira!.suit} • Manilha: $manilhaRank\nDealer vai puxar a próxima queda.";
      } else if (!handOver && !dealerLeadsTrick) {
        message =
            "Vira: ${vira!.rank}${vira!.suit} • Manilha: $manilhaRank\nSua vez! Escolha uma carta.";
      }

      // Após a primeira queda, dealer pode pedir truco em momento oportuno
      if (!handOver && trucoPendencia == null && rodadaVale == 1) {
        _maybeDealerCallsTruco();
      }
    });
  }

  void _checkWinner() {
    int vitoriasPlayer = quedasVencidas.where((v) => v == 1).length;
    int vitoriasDealer = quedasVencidas.where((v) => v == 2).length;
    int empates = quedasVencidas.where((v) => v == 0).length;

    // Regra: Ganha quem fizer 2 quedas primeiro
    // Ou se houver empate na primeira, quem ganhar a segunda leva.
    if (vitoriasPlayer == 2 ||
        (vitoriasPlayer == 1 && empates >= 1 && quedasVencidas.length >= 2)) {
      pontosPlayer += rodadaVale;
      message =
          "VOCÊ GANHOU A RODADA! 🏆 (+$rodadaVale)\nPlacar: Você $pontosPlayer x $pontosDealer Dealer";
      handOver = true;
    } else if (vitoriasDealer == 2 ||
        (vitoriasDealer == 1 && empates >= 1 && quedasVencidas.length >= 2)) {
      pontosDealer += rodadaVale;
      message =
          "O DEALER GANHOU A RODADA! ❌ (+$rodadaVale)\nPlacar: Você $pontosPlayer x $pontosDealer Dealer";
      handOver = true;
    } else if (quedasVencidas.length == 3) {
      if (vitoriasPlayer > vitoriasDealer) {
        pontosPlayer += rodadaVale;
        message =
            "GANHOU NA 3ª QUEDA! (+$rodadaVale)\nPlacar: Você $pontosPlayer x $pontosDealer Dealer";
      } else if (vitoriasDealer > vitoriasPlayer) {
        pontosDealer += rodadaVale;
        message =
            "PERDEU NA 3ª QUEDA! (+$rodadaVale)\nPlacar: Você $pontosPlayer x $pontosDealer Dealer";
      } else {
        message = "EMPATE TOTAL!\nPlacar: Você $pontosPlayer x $pontosDealer Dealer";
      }
      handOver = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF0D47A1),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          const Text(
            "TRUCO: 2 DE 3",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.orange,
            ),
          ),
          Text(
            "Placar: Você $pontosPlayer x $pontosDealer Dealer • Rodada vale: $rodadaVale",
            style: const TextStyle(color: Colors.white70),
            textAlign: TextAlign.center,
          ),
          if (vira != null && manilhaRank != null)
            Text(
              "Vira: ${vira!.rank}${vira!.suit} • Manilha: $manilhaRank",
              style: const TextStyle(color: Colors.white70),
              textAlign: TextAlign.center,
            ),

          // Indicador Visual de Quedas (Bolinhas)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(3, (i) {
              Color cor = Colors.white24;
              if (i < quedasVencidas.length) {
                if (quedasVencidas[i] == 1) cor = Colors.green;
                if (quedasVencidas[i] == 2) cor = Colors.red;
                if (quedasVencidas[i] == 0) cor = Colors.yellow;
              }
              return Container(
                margin: const EdgeInsets.all(5),
                width: 15,
                height: 15,
                decoration: BoxDecoration(color: cor, shape: BoxShape.circle),
              );
            }),
          ),

          // Cartas na Mesa
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (lastDealerCard != null) _buildCardWidget(lastDealerCard!),
              const SizedBox(
                width: 20,
                child: Center(
                  child: Text(
                    "VS",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              if (lastPlayerCard != null) _buildCardWidget(lastPlayerCard!),
            ],
          ),

          Text(
            message,
            style: const TextStyle(fontSize: 18, color: Colors.white),
            textAlign: TextAlign.center,
          ),

          if (!handOver && trucoPendencia == null)
            ElevatedButton(
              onPressed: _playerCallsTruco,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.deepOrange),
              child: const Text("TRUCO! (valer 3)"),
            ),
          if (!handOver && trucoPendencia == "dealer")
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _acceptTruco,
                  style:
                      ElevatedButton.styleFrom(backgroundColor: Colors.green[700]),
                  child: const Text("Aceitar"),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _runFromTruco,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red[700]),
                  child: const Text("Correr"),
                ),
              ],
            ),

          // Mão do Jogador
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: playerHand
                .map(
                  (c) => GestureDetector(
                    onTap: () => _playCard(c),
                    child: _buildCardWidget(c),
                  ),
                )
                .toList(),
          ),

          if (handOver)
            ElevatedButton(
              onPressed: _startNewHand,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              child: const Text("Nova Rodada"),
            ),
        ],
      ),
    );
  }

  Widget _buildCardWidget(CardModel card) {
    bool isRed = card.suit == '♥️' || card.suit == '♦️';
    return Container(
      margin: const EdgeInsets.all(4),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      width: 60,
      height: 85,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: Text(
              card.rank,
              style: TextStyle(
                color: isRed ? Colors.red : Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          Text(
            card.suit,
            style: TextStyle(
              fontSize: 24,
              color: isRed ? Colors.red : Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}

// --- MANTENHA SEUS MÓDULOS BLACKJACK E SLOT MACHINE ABAIXO ---
// (O código de SlotMachineGame e BlackjackGame permanece o mesmo do passo anterior)

class CardModel {
  final String suit;
  final String rank;
  final int value;

  CardModel({required this.suit, required this.rank, required this.value});
}

class BlackjackGame extends StatefulWidget {
  @override
  _BlackjackGameState createState() => _BlackjackGameState();
}

class _BlackjackGameState extends State<BlackjackGame> {
  List<CardModel> playerHand = [];
  List<CardModel> dealerHand = [];
  List<CardModel> deck = [];
  String result = "Bem-vindo ao Blackjack!";
  bool gameOver = false;
  bool revealDealerHoleCard = false;

  int balance = 200;
  int bet = 10;

  void _startGame() {
    setState(() {
      deck = _generateDeck();
      deck.shuffle();
      playerHand = [deck.removeLast(), deck.removeLast()];
      dealerHand = [deck.removeLast(), deck.removeLast()];
      revealDealerHoleCard = false;

      if (balance < bet) {
        bet = max(1, balance);
      }
      if (bet <= 0) {
        result = "Sem saldo. Reinicie o app para jogar de novo.";
        gameOver = true;
        return;
      }

      balance -= bet; // aposta é debitada ao iniciar a mão (mais realista)
      result = "Sua vez! Hit ou Stand? (Aposta: $bet)";
      gameOver = false;

      // Checa blackjack natural já no início
      final playerValue = _calculateHandValue(playerHand);
      final dealerValue = _calculateHandValue(dealerHand);
      final playerBJ = playerValue == 21 && playerHand.length == 2;
      final dealerBJ = dealerValue == 21 && dealerHand.length == 2;
      if (playerBJ || dealerBJ) {
        revealDealerHoleCard = true;
        if (playerBJ && dealerBJ) {
          // push
          balance += bet;
          result = "Blackjack dos dois! Empate. (+$bet)";
        } else if (playerBJ) {
          // 3:2 payout -> lucro 1.5x + devolve aposta
          final payout = (bet * 2.5).floor();
          balance += payout;
          result = "BLACKJACK! Você ganhou (+$payout)";
        } else {
          result = "Dealer tem Blackjack. Você perdeu.";
        }
        gameOver = true;
      }
    });
  }

  List<CardModel> _generateDeck() {
    List<String> suits = ['♥️', '♠️', '♦️', '♣️'];
    List<String> ranks = [
      '2',
      '3',
      '4',
      '5',
      '6',
      '7',
      '8',
      '9',
      '10',
      'J',
      'Q',
      'K',
      'A',
    ];
    Map<String, int> values = {
      '2': 2,
      '3': 3,
      '4': 4,
      '5': 5,
      '6': 6,
      '7': 7,
      '8': 8,
      '9': 9,
      '10': 10,
      'J': 10,
      'Q': 10,
      'K': 10,
      'A': 11,
    };
    return [
      for (var s in suits)
        for (var r in ranks) CardModel(suit: s, rank: r, value: values[r]!),
    ];
  }

  int _calculateHandValue(List<CardModel> hand) {
    int value = 0;
    int aces = 0;
    for (var card in hand) {
      value += card.value;
      if (card.rank == 'A') aces++;
    }
    while (value > 21 && aces > 0) {
      value -= 10;
      aces--;
    }
    return value;
  }

  bool _isSoft17(List<CardModel> hand) {
    // Soft 17: total 17 com Ás contando como 11
    int total = 0;
    int aces = 0;
    for (final c in hand) {
      total += c.value;
      if (c.rank == 'A') aces++;
    }
    // Reduz A(s) até ficar <=21, como no cálculo normal
    while (total > 21 && aces > 0) {
      total -= 10;
      aces--;
    }
    // Se total == 17 e ainda existe pelo menos 1 Ás valendo 11,
    // então é soft 17. Isso acontece quando existe Ás na mão e NÃO foi reduzido.
    if (total != 17) return false;
    // Para haver Ás valendo 11, precisa existir ao menos um Ás e que o valor bruto
    // (com todos Ás valendo 11) não tenha sido reduzido até perder todos os "11".
    // Uma forma prática: recalcula contando todos Ás como 1 e vê se dá +10.
    int minTotal = 0;
    for (final c in hand) {
      if (c.rank == 'A') {
        minTotal += 1;
      } else {
        minTotal += c.value;
      }
    }
    return minTotal + 10 == 17;
  }

  void _hit() {
    if (gameOver) return;
    setState(() {
      playerHand.add(deck.removeLast());
      if (_calculateHandValue(playerHand) > 21) {
        revealDealerHoleCard = true;
        result = "Bust! Você perdeu.";
        gameOver = true;
      }
    });
  }

  void _stand() {
    if (gameOver) return;
    setState(() {
      revealDealerHoleCard = true;
      // Regra mais difícil/realista: dealer compra em soft 17
      while (_calculateHandValue(dealerHand) < 17 || _isSoft17(dealerHand)) {
        dealerHand.add(deck.removeLast());
      }
      int playerValue = _calculateHandValue(playerHand);
      int dealerValue = _calculateHandValue(dealerHand);
      if (dealerValue > 21 || playerValue > dealerValue) {
        final payout = bet * 2; // devolve aposta + lucro 1x
        balance += payout;
        result = "Você ganhou! (+$payout)";
      } else if (playerValue < dealerValue) {
        result = "Dealer ganhou!";
      } else {
        balance += bet; // push devolve aposta
        result = "Empate! (+$bet)";
      }
      gameOver = true;
    });
  }

  @override
  void initState() {
    super.initState();
    _startGame();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.green[900],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "BLACKJACK",
            style: TextStyle(fontSize: 24, color: Colors.white),
          ),
          SizedBox(height: 20),
          Text(
            "Saldo: $balance  •  Aposta: $bet",
            style: const TextStyle(color: Colors.white70),
          ),
          if (!gameOver)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: balance <= 0
                        ? null
                        : () => setState(() {
                              bet = max(1, bet - 5);
                              if (bet > balance) bet = balance;
                            }),
                    icon: const Icon(Icons.remove, color: Colors.white),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: balance <= 0
                        ? null
                        : () => setState(() {
                              final next = bet + 5;
                              bet = min(next, max(1, balance));
                            }),
                    icon: const Icon(Icons.add, color: Colors.white),
                  ),
                ],
              ),
            ),
          Text(
            "Dealer: ${revealDealerHoleCard ? _calculateHandValue(dealerHand) : "?"}",
            style: TextStyle(color: Colors.white),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: dealerHand.asMap().entries.map((entry) {
              final i = entry.key;
              final c = entry.value;
              if (!revealDealerHoleCard && i == 1) {
                return _buildHiddenCardWidget();
              }
              return _buildCardWidget(c);
            }).toList(),
          ),
          SizedBox(height: 20),
          Text(
            "Você: ${_calculateHandValue(playerHand)}",
            style: TextStyle(color: Colors.white),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: playerHand.map((c) => _buildCardWidget(c)).toList(),
          ),
          SizedBox(height: 20),
          Text(result, style: TextStyle(color: Colors.yellow)),
          if (!gameOver)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(onPressed: _hit, child: Text("Hit")),
                SizedBox(width: 10),
                ElevatedButton(onPressed: _stand, child: Text("Stand")),
              ],
            ),
          if (gameOver)
            ElevatedButton(onPressed: _startGame, child: Text("Novo Jogo")),
        ],
      ),
    );
  }

  Widget _buildCardWidget(CardModel card) {
    bool isRed = card.suit == '♥️' || card.suit == '♦️';
    return Container(
      margin: EdgeInsets.all(4),
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      width: 50,
      height: 70,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: Text(
              card.rank,
              style: TextStyle(
                color: isRed ? Colors.red : Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Text(
            card.suit,
            style: TextStyle(
              fontSize: 20,
              color: isRed ? Colors.red : Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHiddenCardWidget() {
    return Container(
      margin: EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.blueGrey[800],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white24),
      ),
      width: 50,
      height: 70,
      child: const Center(
        child: Text("🂠", style: TextStyle(fontSize: 20)),
      ),
    );
  }
}

class SlotMachineGame extends StatefulWidget {
  @override
  _SlotMachineGameState createState() => _SlotMachineGameState();
}

class _SlotMachineGameState extends State<SlotMachineGame> {
  final List<String> symbols = const ['🍒', '🍋', '🍊', '🍇', '💎'];
  List<String> reels = ['🍒', '🍒', '🍒'];
  String result = "Gire para jogar!";
  bool spinning = false;
  Timer? _spinTimer;
  final _rng = Random();

  @override
  void dispose() {
    _spinTimer?.cancel();
    super.dispose();
  }

  String _randomSymbol() => symbols[_rng.nextInt(symbols.length)];

  Future<void> _spin() async {
    if (spinning) return;
    setState(() {
      spinning = true;
      result = "Girando...";
    });

    // Animação de giro: troca símbolos rapidamente por ~1.6s
    _spinTimer?.cancel();
    int ticks = 0;
    _spinTimer = Timer.periodic(const Duration(milliseconds: 90), (_) {
      ticks++;
      if (!mounted) return;
      setState(() {
        reels = [_randomSymbol(), _randomSymbol(), _randomSymbol()];
      });
      if (ticks >= 18) {
        _spinTimer?.cancel();
      }
    });

    await Future.delayed(const Duration(milliseconds: 1650));
    if (!mounted) return;

    setState(() {
      // “Parada” final com um pequeno desfasamento visual
      reels = [_randomSymbol(), _randomSymbol(), _randomSymbol()];
      if (reels[0] == reels[1] && reels[1] == reels[2]) {
        result = "Jackpot! Você ganhou!";
      } else {
        result = "Tente novamente!";
      }
      spinning = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.purple[900],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "SLOT MACHINE",
            style: TextStyle(fontSize: 24, color: Colors.white),
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: reels
                .map(
                  (s) => _SlotReel(symbol: s, spinning: spinning),
                )
                .toList(),
          ),
          SizedBox(height: 20),
          Text(result, style: TextStyle(color: Colors.yellow, fontSize: 18)),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: spinning ? null : _spin,
            child: Text(spinning ? "Girando..." : "GIRAR"),
          ),
        ],
      ),
    );
  }
}

class _SlotReel extends StatelessWidget {
  final String symbol;
  final bool spinning;

  const _SlotReel({
    required this.symbol,
    required this.spinning,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: spinning ? 16 : 10,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 120),
        switchInCurve: Curves.easeOutBack,
        switchOutCurve: Curves.easeIn,
        transitionBuilder: (child, anim) {
          return ScaleTransition(
            scale: Tween<double>(begin: 0.85, end: 1).animate(anim),
            child: FadeTransition(opacity: anim, child: child),
          );
        },
        child: Text(
          symbol,
          key: ValueKey(symbol),
          style: const TextStyle(fontSize: 44),
        ),
      ),
    );
  }
}
