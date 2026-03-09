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

// Controle de abas para alternar entre os jogos
class CasinoTabs extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        bottomNavigationBar: const TabBar(
          tabs: [
            Tab(icon: Icon(Icons.style), text: "Blackjack"),
            Tab(icon: Icon(Icons.casino), text: "Slots"),
          ],
          indicatorColor: Colors.yellow,
        ),
        body: TabBarView(
          children: [
            BlackjackGame(),
            SlotMachineGame(),
          ],
        ),
      ),
    );
  }
}

// --- MÓDULO SLOT MACHINE (NOVO) ---
class SlotMachineGame extends StatefulWidget {
  @override
  _SlotMachineGameState createState() => _SlotMachineGameState();
}

class _SlotMachineGameState extends State<SlotMachineGame> {
  final List<String> symbols = ['🍒', '🍋', '🔔', '💎', '7️⃣', '🍇', '🍉'];
  final List<FixedExtentScrollController> _controllers = 
      List.generate(3, (_) => FixedExtentScrollController());
  
  String resultMessage = "Tente a sorte!";
  bool isSpinning = false;

  void spin() async {
    if (isSpinning) return;
    
    setState(() {
      isSpinning = true;
      resultMessage = "Girando...";
    });

    // Sorteia índices aleatórios para os 3 rolos
    final random = Random();
    List<int> targets = List.generate(3, (_) => random.nextInt(symbols.length) + (symbols.length * 5));

    // Anima cada rolo com um pequeno atraso entre eles
    for (int i = 0; i < 3; i++) {
      _controllers[i].animateToItem(
        targets[i],
        duration: Duration(seconds: 1 + i),
        curve: Curves.decelerate,
      );
    }

    await Future.delayed(const Duration(seconds: 3));

    setState(() {
      isSpinning = false;
      // Verifica se todos os símbolos são iguais (usando mod para o índice real)
      if (targets[0] % symbols.length == targets[1] % symbols.length &&
          targets[1] % symbols.length == targets[2] % symbols.length) {
        resultMessage = "JACKPOT! 🏆";
      } else {
        resultMessage = "Tente novamente!";
      }
    });
  }

  Widget _buildReel(FixedExtentScrollController controller) {
    return Container(
      width: 80,
      height: 150,
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border.all(color: Colors.yellow, width: 2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListWheelScrollView.useDelegate(
        controller: controller,
        itemExtent: 80,
        physics: const FixedExtentScrollPhysics(),
        childDelegate: ListWheelChildLoopingListDelegate(
          children: symbols.map((s) => Center(
            child: Text(s, style: const TextStyle(fontSize: 40)),
          )).toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF420000), Color(0xFF1a0000)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text("SLOT MACHINE", style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.yellow)),
          const SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildReel(_controllers[0]),
              const SizedBox(width: 10),
              _buildReel(_controllers[1]),
              const SizedBox(width: 10),
              _buildReel(_controllers[2]),
            ],
          ),
          const SizedBox(height: 40),
          Text(resultMessage, style: const TextStyle(fontSize: 24, color: Colors.white)),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: isSpinning ? null : spin,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
            ),
            child: const Text("GIRAR", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

// --- MÓDULO BLACKJACK (SEU CÓDIGO) ---
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
  List<CardModel> deck = [];
  List<CardModel> playerHand = [];
  List<CardModel> dealerHand = [];
  String message = "Bem-vindo ao Cassino!";
  bool gameOver = false;

  @override
  void initState() {
    super.initState();
    _startNewGame();
  }

  void _startNewGame() {
    setState(() {
      deck = _generateDeck();
      deck.shuffle();
      playerHand = [deck.removeLast(), deck.removeLast()];
      dealerHand = [deck.removeLast(), deck.removeLast()];
      message = "Sua vez! Pedir ou Parar?";
      gameOver = false;
    });
  }

  List<CardModel> _generateDeck() {
    List<String> suits = ['♥️', '♠️', '♦️', '♣️'];
    List<String> ranks = ['2', '3', '4', '5', '6', '7', '8', '9', '10', 'J', 'Q', 'K', 'A'];
    List<CardModel> tempDeck = [];
    for (var suit in suits) {
      for (var rank in ranks) {
        int val;
        if (rank == 'A') val = 11;
        else if (['J', 'Q', 'K'].contains(rank)) val = 10;
        else val = int.parse(rank);
        tempDeck.add(CardModel(suit: suit, rank: rank, value: val));
      }
    }
    return tempDeck;
  }

  int _calculateScore(List<CardModel> hand) {
    int total = hand.fold(0, (sum, card) => sum + card.value);
    int aces = hand.where((card) => card.rank == 'A').length;
    while (total > 21 && aces > 0) {
      total -= 10;
      aces--;
    }
    return total;
  }

  void _hit() {
    if (gameOver) return;
    setState(() {
      playerHand.add(deck.removeLast());
      if (_calculateScore(playerHand) > 21) {
        message = "ESTOUROU! Você perdeu.";
        gameOver = true;
      }
    });
  }

  void _stand() {
    if (gameOver) return;
    setState(() {
      while (_calculateScore(dealerHand) < 17) {
        dealerHand.add(deck.removeLast());
      }
      int pScore = _calculateScore(playerHand);
      int dScore = _calculateScore(dealerHand);
      if (dScore > 21 || pScore > dScore) message = "VOCÊ GANHOU!";
      else if (dScore > pScore) message = "DEALER GANHOU!";
      else message = "EMPATE!";
      gameOver = true;
    });
  }

  Widget _buildCardWidget(CardModel card) {
    bool isRed = card.suit == '♥️' || card.suit == '♦️';
    return Container(
      margin: const EdgeInsets.all(4),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
      ),
      width: 60, height: 90,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Align(alignment: Alignment.topLeft, child: Text(card.rank, style: TextStyle(color: isRed ? Colors.red : Colors.black, fontWeight: FontWeight.bold))),
          Text(card.suit, style: TextStyle(fontSize: 24, color: isRed ? Colors.red : Colors.black)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1B5E20),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          const SizedBox(height: 20),
          Text("Dealer: ${gameOver ? _calculateScore(dealerHand) : '?'}", style: const TextStyle(fontSize: 18)),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: dealerHand.asMap().entries.map((e) {
              if (!gameOver && e.key == 0) return _buildHiddenCard();
              return _buildCardWidget(e.value);
            }).toList(),
          ),
          const Divider(color: Colors.white54, thickness: 2, indent: 50, endIndent: 50),
          Text(message, style: const TextStyle(color: Colors.yellow, fontSize: 22, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: playerHand.map((c) => _buildCardWidget(c)).toList(),
          ),
          Text("Sua Pontuação: ${_calculateScore(playerHand)}", style: const TextStyle(fontSize: 18)),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(onPressed: gameOver ? null : _hit, child: const Text("HIT")),
              const SizedBox(width: 20),
              ElevatedButton(onPressed: gameOver ? null : _stand, style: ElevatedButton.styleFrom(backgroundColor: Colors.orange), child: const Text("STAND")),
            ],
          ),
          if (gameOver) ElevatedButton(onPressed: _startNewGame, child: const Text("Nova Partida")),
        ],
      ),
    );
  }

  Widget _buildHiddenCard() {
    return Container(
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: Colors.blueGrey, borderRadius: BorderRadius.circular(8)),
      width: 60, height: 90,
      child: const Center(child: Icon(Icons.help_outline, color: Colors.white)),
    );
  }
}