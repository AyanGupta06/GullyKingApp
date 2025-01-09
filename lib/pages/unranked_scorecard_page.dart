
import 'package:flutter/material.dart';
import 'package:gully_king/pages/new_batsman_dialog.dart';
import 'package:gully_king/pages/new_innings_setup_dialog.dart';
import 'package:gully_king/pages/new_unranked_game_page.dart';
import 'package:gully_king/pages/unranked_scorecard_page_2.dart';

class UnrankedScorecardPage extends StatefulWidget {
  final String? battingFirstTeam;
  final Player? batsmanOnStrike;
  final Player? batsmanOnNonStrike;
  final Player? bowler;
  final int maxOvers;
  final List<Player> battingTeam;
  final List<Player> bowlingTeam;

  const UnrankedScorecardPage({
    super.key,
    required this.battingFirstTeam,
    required this.batsmanOnStrike,
    required this.batsmanOnNonStrike,
    required this.bowler,
    required this.maxOvers, required this.battingTeam, required this.bowlingTeam,
  });

  @override
  State<UnrankedScorecardPage> createState() => _UnrankedScorecardPageState();
}

class _UnrankedScorecardPageState extends State<UnrankedScorecardPage> {
  Player? batsmanOnStrike;
  Player? batsmanOnNonStrike;
  Player? bowler;
  List<Player> battingTeam = [];
  List<Player> bowlingTeam = [];
  int teamScore = 0;
  int totalOvers = 0;
  int totalBalls = 0;
  int currentWickets = 0;
  bool isSecondInnings = false;

  @override
  void initState() {
    super.initState();
    batsmanOnStrike = widget.batsmanOnStrike;
    print("Test12");
    batsmanOnNonStrike = widget.batsmanOnNonStrike;
    bowler = widget.bowler;
    battingTeam = widget.battingTeam;
    bowlingTeam = widget.bowlingTeam;
    batsmanOnStrike?.setHasBatted(true);
    batsmanOnNonStrike?.setHasBatted(true);
  }

  void _updateScore(int runs) {
    setState(() {
      batsmanOnStrike?.runs += runs;
      batsmanOnStrike?.ballsFaced++;
      bowler?.runsOnBalls += runs;
      teamScore += runs;

      totalBalls++;
      if (totalBalls % 6 == 0) {
        totalOvers++;
      }

      if (totalOvers >= widget.maxOvers) {
        _endInnings();
      }

      if (runs % 2 != 0) {
        _changeStrike();
      }
    });
  }

  // void _recordWicket() {
  //   setState(() {
  //     currentWickets++;
  //     bowler?.wicketsTaken++;

  //     if (currentWickets == battingTeam.length - 1) {
  //       _endInnings();
  //     } else {
  //       List<Player> availableBatsmen = battingTeam
  //           .where((player) => !player.hasBatted) 
  //           .toList();
  //       _showNewBatsmanDialog(availableBatsmen);
  //     }
  //   });
  // }
  void _recordWicket() {
    setState(() {
      batsmanOnStrike?.ballsFaced++;
      currentWickets++;
      bowler?.wicketsTaken++;
      totalBalls++;
      batsmanOnStrike?.setHasBatted(true);
      batsmanOnNonStrike?.setHasBatted(true);
      print(batsmanOnStrike?.hasBatted);
      

      print("Length " + battingTeam.length.toString());

      if (currentWickets == battingTeam.length - 1) {
        _endInnings();
      } else {
        List<Player> availableBatsmen = battingTeam
            .where((player) => !player.hasBatted) 
            .toList();

        // List<Player> availableTest = [];
        // for(int i = 0; i < battingTeam.length; i++) {
        //   print(battingTeam[i].hasBatted);
        // }
        print("Length" + battingTeam.length.toString());

        _showNewBatsmanDialog(availableBatsmen);
      }
    });
  }



  void _endInnings() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("End of Innings"),
          content: Text(
            !isSecondInnings
                ? "The innings is over. Please select the batsmen and bowler for the next innings."
                : "The game is over.",
          ),
          actions: [
            TextButton(
              child: const Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
                if (!isSecondInnings) {
                  _setupSecondInnings(battingTeam, bowlingTeam);
                }
              },
            ),
          ],
        );
      },
    );
  }





  void _setupSecondInnings(List<Player> battingTeam, List<Player> bowlingTeam) {
    setState(() {
      this.battingTeam = bowlingTeam; 
      this.bowlingTeam = battingTeam; 
      batsmanOnStrike = null;
      batsmanOnNonStrike = null;
      bowler = null;
      totalOvers = 0;
      totalBalls = 0;
      teamScore = 0;
      currentWickets = 0;
      isSecondInnings = true;
    });

    _showNewInningsSetupDialog(bowlingTeam, battingTeam);
  }





  // void _showNewInningsSetupDialog(List<Player> battingTeam, List<Player> bowlingTeam) {
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return NewInningsSetupDialog(
  //         availableBatsmen: battingTeam, 
  //         availableBowlers: bowlingTeam, 
  //         onBatsmenAndBowlerSelected: (Player newStrike, Player newNonStrike, Player newBowler) {
  //           setState(() {
  //             batsmanOnStrike = newStrike;
  //             batsmanOnNonStrike = newNonStrike;
  //             bowler = newBowler;
  //           });
  //         },
  //       );
  //     },
  //   );
  // }

  void _showNewInningsSetupDialog(List<Player> battingTeam, List<Player> bowlingTeam) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return NewInningsSetupDialog(
          availableBatsmen: battingTeam, 
          availableBowlers: bowlingTeam, 
          onBatsmenAndBowlerSelected: (Player newStrike, Player newNonStrike, Player newBowler) {
            setState(() {
              batsmanOnStrike = newStrike;
              batsmanOnNonStrike = newNonStrike;
              bowler = newBowler;
            });
            // Navigator.push(
            //   context,
            //   MaterialPageRoute(
            //     builder: (context) => UnrankedScorecardPage2(
            //       bowler: bowler,
            //       batsmanOnStrike: batsmanOnStrike,
            //       batsmanOnNonStrike: batsmanOnNonStrike,
            //       maxOvers: totalOvers,
            //       battingTeam: battingTeam,
            //       bowlingTeam: bowlingTeam, 

            //     ),
            //   ),
            // );
          },
        );
      },
    );
  }

   void _showNewBatsmanDialog(List<Player> availableBatsmen) {
    // print(availableBatsmen.toString());
    // availableBatsmen.add(new Player(name: "James"));

    // test to see why dialog box was returning as empty
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Select a New Batsman"),
          content: DropdownButton<Player>(
            hint: const Text("Select Batsman"),
            items: availableBatsmen.map((Player player) {
              return DropdownMenuItem<Player>(
                value: player,
                child: Text(player.name),
              );
            }).toList(),
            onChanged: (Player? selectedPlayer) {
              if (selectedPlayer != null) {
                 onBatsmanSelected(selectedPlayer);
                Navigator.pop(context);
              }
            },
          ),
        );
      },
    );
  }

  void onBatsmanSelected(Player player) {
    print(player.name);
    setState(() {
      batsmanOnStrike = player;
    });
  }






  void _changeStrike() {
    setState(() {
      final temp = batsmanOnStrike;
      batsmanOnStrike = batsmanOnNonStrike;
      batsmanOnNonStrike = temp;
    });
  }

  Widget _batsmanCard(Player batsman, bool isOnStrike) {
    return Card(
      color: isOnStrike ? Colors.blue[100] : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              batsman.name,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              "${batsman.runs} (${batsman.ballsFaced})",
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bowlerCard(Player bowler) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              bowler.name,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              "${bowler.wicketsTaken}/${bowler.runsOnBalls}",
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _scoreInputRow() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (int i = 0; i <= 6; i++) ...[
          ElevatedButton(
            onPressed: () {
              _updateScore(i);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: i == 4 || i == 6 ? Colors.green : Colors.blue,
              minimumSize: const Size(50, 50),
            ),
            child: Text("$i"),
          ),
        ],
        ElevatedButton(
          onPressed: _recordWicket,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            minimumSize: const Size(50, 50),
          ),
          child: const Text("W"),
        ),
        ElevatedButton(
          onPressed: _changeStrike,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            minimumSize: const Size(50, 50),
          ),
          child: const Text("Change Strike"),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "${widget.battingFirstTeam} Scorecard",
          style: const TextStyle(color: Colors.black),
        ),
        backgroundColor: const Color.fromRGBO(53, 150, 207, 1),
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/bg4.png'),
            fit: BoxFit.cover,
          ),
        ),
        height: double.infinity,
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Team Score: $teamScore",
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              "Overs: $totalOvers.${totalBalls % 6}",
              style: const TextStyle(
                fontSize: 18,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 20),
            // _batsmanCard(batsmanOnStrike!, true),
            // _batsmanCard(batsmanOnNonStrike!, false),
            if (batsmanOnStrike != null) _batsmanCard(batsmanOnStrike!, true),
            if (batsmanOnNonStrike != null) _batsmanCard(batsmanOnNonStrike!, false),

            const SizedBox(height: 20),
            const Text(
              "Bowler:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            // _bowlerCard(bowler!),
            if (bowler != null) _bowlerCard(bowler!),

            const Spacer(),
            _scoreInputRow(),
          ],
        ),
      ),
    );
  }
}

