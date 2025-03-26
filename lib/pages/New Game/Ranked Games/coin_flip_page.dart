import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CoinFlipPage extends StatefulWidget {
  final List<String> yourTeam;
  final List<String> opponentTeam;
  final String yourTeamID;
  final String opponentTeamID;

  const CoinFlipPage({
    Key? key,
    required this.yourTeam,
    required this.opponentTeam,
    required this.yourTeamID,
    required this.opponentTeamID,
  }) : super(key: key);

  @override
  _CoinFlipPageState createState() => _CoinFlipPageState();
}

class _CoinFlipPageState extends State<CoinFlipPage> {
  String? flippingTeam;
  String? call;
  String? flipResult;
  String? winner;
  String? finalDecision;

  bool isFlipping = false;
  double rotationAngle = 0;

  void _flipCoin() {
    if (call == null || flippingTeam == null) return;

    setState(() {
      isFlipping = true;
      rotationAngle = 0;
    });

    Future.delayed(const Duration(milliseconds: 1500), () {
      final Random random = Random();
      bool isHeads = random.nextBool();
      flipResult = isHeads ? 'Heads' : 'Tails';

      winner = flipResult == call
          ? flippingTeam
          : (flippingTeam == widget.yourTeamID
              ? widget.opponentTeamID
              : widget.yourTeamID);

      setState(() {
        isFlipping = false;
      });
    });

    for (int i = 0; i < 5; i++) {
      Future.delayed(Duration(milliseconds: i * 30), () {
        setState(() {
          rotationAngle += pi / 2;
        });
      });
    }
  }

  Future<void> _startGame() async {
    try {
      await FirebaseFirestore.instance.collection('started_ranked_games').add({
        'opponentTeamID': widget.opponentTeamID,
        'teamId': widget.yourTeamID,
        'selectedTeamPlayers': widget.yourTeam,
        'selectedOpponentTeamPlayers': widget.opponentTeam,
        'coinflipResult': flipResult,
        'finalDecision': "$winner chose to $finalDecision first",
        'timeStamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Game started successfully")));

      Navigator.pop(context);  // fix later
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error starting game: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Coin Flip"),
        backgroundColor: Colors.blue,
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(image: AssetImage('assets/bg4.png'), fit: BoxFit.cover),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 20),
            const Text("Choose Team That Flips Coin", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () => setState(() => flippingTeam = widget.yourTeamID),
                  style: ElevatedButton.styleFrom(backgroundColor: flippingTeam == widget.yourTeamID ? Colors.green : Colors.blue),
                  child: Text("Your Team"),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () => setState(() => flippingTeam = widget.opponentTeamID),
                  style: ElevatedButton.styleFrom(backgroundColor: flippingTeam == widget.opponentTeamID ? Colors.green : Colors.blue),
                  child: Text("Opponent Team"),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text("Call Heads or Tails", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            DropdownButton<String>(
              value: call,
              hint: const Text("Select"),
              items: ["Heads", "Tails"].map((choice) => DropdownMenuItem(value: choice, child: Text(choice))).toList(),
              onChanged: (value) => setState(() => call = value),
            ),
            const SizedBox(height: 20),

            if (flipResult == null || isFlipping)
              TweenAnimationBuilder(
                tween: Tween<double>(begin: 0, end: rotationAngle),
                duration: const Duration(seconds: 1),
                builder: (context, angle, child) {
                  return Transform(
                    transform: Matrix4.rotationY(angle),
                    alignment: Alignment.center,
                    child: Image.asset(
                      'assets/coin_heads1.png',
                      width: 100,
                    ),
                  );
                },
              ),
            if (!isFlipping && flipResult != null)
              Image.asset(
                flipResult == 'Heads' ? 'assets/coin_heads1.png' : 'assets/coin_tails1.png',
                width: 100,
              ),

            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: call != null ? _flipCoin : null,
              child: const Text("Flip"),
            ),

            if (flipResult != null) ...[
              const SizedBox(height: 20),
              Text("$winner won.", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              DropdownButton<String>(
                value: finalDecision,
                hint: const Text("Choose Bat or Field"),
                items: ["Batting", "Fielding"].map((choice) => DropdownMenuItem(value: choice, child: Text(choice))).toList(),
                onChanged: (value) => setState(() => finalDecision = value),
              ),
              if (finalDecision != null)
                Text(
                  "$winner chose to ${finalDecision == 'Batting' ? 'bat first' : 'field first'}.",
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
            ],

            const SizedBox(height: 20),
            if (finalDecision != null)
              Center(
                child: ElevatedButton(
                  onPressed: _startGame,
                  child: const Text("Start Game"),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
