import 'package:flutter/material.dart';
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
  final Map<String, int> powerMap = {
    '4': 1,
    '5': 2,
    '6': 3,
    '7': 4,
    'Q': 5,
    'J': 6,
    'K': 7,
    'A': 8,
    '2': 9,
    '3': 10,
  };

  List<CardModel> playerHand = [];
  List<CardModel> dealerHand = [];
  CardModel? lastPlayerCard;
  CardModel? lastDealerCard;

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
      quedasVencidas = [];
      lastPlayerCard = null;
      lastDealerCard = null;
      message = "Sua vez! Escolha uma carta.";
      handOver = false;
    });
  }

  List<CardModel> _generateTrucoDeck() {
    List<String> suits = ['♥️', '♠️', '♦️', '♣️'];
    List<String> ranks = ['4', '5', '6', '7', 'Q', 'J', 'K', 'A', '2', '3'];
    return [
      for (var s in suits)
        for (var r in ranks) CardModel(suit: s, rank: r, value: powerMap[r]!),
    ];
  }

  void _playCard(CardModel card) {
    if (handOver) return;

    setState(() {
      lastPlayerCard = card;
      playerHand.remove(card);

      // Dealer joga a carta dele (sempre a primeira da lista dele)
      lastDealerCard = dealerHand.removeAt(0);

      // Comparação de força
      if (lastPlayerCard!.value > lastDealerCard!.value) {
        quedasVencidas.add(1);
        message = "Você ganhou esta queda!";
      } else if (lastPlayerCard!.value < lastDealerCard!.value) {
        quedasVencidas.add(2);
        message = "Dealer ganhou esta queda!";
      } else {
        quedasVencidas.add(0);
        message = "Empatou (Canguá)!";
      }

      _checkWinner();
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
      message = "VOCÊ GANHOU A RODADA! 🏆";
      handOver = true;
    } else if (vitoriasDealer == 2 ||
        (vitoriasDealer == 1 && empates >= 1 && quedasVencidas.length >= 2)) {
      message = "O DEALER GANHOU A RODADA! ❌";
      handOver = true;
    } else if (quedasVencidas.length == 3) {
      if (vitoriasPlayer > vitoriasDealer) {
        message = "GANHOU NA 3ª QUEDA!";
      } else if (vitoriasDealer > vitoriasPlayer) {
        message = "PERDEU NA 3ª QUEDA!";
      } else {
        message = "EMPATE TOTAL!";
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

  void _startGame() {
    setState(() {
      deck = _generateDeck();
      deck.shuffle();
      playerHand = [deck.removeLast(), deck.removeLast()];
      dealerHand = [deck.removeLast(), deck.removeLast()];
      result = "Sua vez! Hit ou Stand?";
      gameOver = false;
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

  void _hit() {
    if (gameOver) return;
    setState(() {
      playerHand.add(deck.removeLast());
      if (_calculateHandValue(playerHand) > 21) {
        result = "Bust! Você perdeu.";
        gameOver = true;
      }
    });
  }

  void _stand() {
    if (gameOver) return;
    setState(() {
      while (_calculateHandValue(dealerHand) < 17) {
        dealerHand.add(deck.removeLast());
      }
      int playerValue = _calculateHandValue(playerHand);
      int dealerValue = _calculateHandValue(dealerHand);
      if (dealerValue > 21 || playerValue > dealerValue) {
        result = "Você ganhou!";
      } else if (playerValue < dealerValue) {
        result = "Dealer ganhou!";
      } else {
        result = "Empate!";
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
            "Dealer: ${_calculateHandValue(dealerHand)}",
            style: TextStyle(color: Colors.white),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: dealerHand.map((c) => _buildCardWidget(c)).toList(),
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
}

class SlotMachineGame extends StatefulWidget {
  @override
  _SlotMachineGameState createState() => _SlotMachineGameState();
}

class _SlotMachineGameState extends State<SlotMachineGame> {
  List<String> symbols = ['🍒', '🍋', '🍊', '🍇', '💎'];
  List<String> reels = ['🍒', '🍒', '🍒'];
  String result = "Gire para jogar!";
  bool spinning = false;

  void _spin() {
    if (spinning) return;
    setState(() {
      spinning = true;
      result = "Girando...";
    });
    Future.delayed(Duration(seconds: 2), () {
      setState(() {
        reels = [
          symbols[Random().nextInt(symbols.length)],
          symbols[Random().nextInt(symbols.length)],
          symbols[Random().nextInt(symbols.length)],
        ];
        if (reels[0] == reels[1] && reels[1] == reels[2]) {
          result = "Jackpot! Você ganhou!";
        } else {
          result = "Tente novamente!";
        }
        spinning = false;
      });
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
                  (s) => Container(
                    margin: EdgeInsets.all(10),
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(s, style: TextStyle(fontSize: 40)),
                  ),
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
