
import 'package:flutter/material.dart';
import 'package:gully_king/pages/home_page.dart';
import 'package:gully_king/pages/new_batsman_dialog.dart';
import 'package:gully_king/pages/new_bowler_dialog.dart';

import 'package:gully_king/pages/new_innings_setup_dialog.dart';
import 'package:gully_king/pages/new_unranked_game_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';


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
  int firstTeamScore = 0;
  bool isLastBallBowled = false;

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
      bowler?.ballsBowled++;

      if (firstTeamScore < teamScore && isSecondInnings) {
        _endGame();
      }

      

      totalBalls++;
      if(totalBalls ==  ((6*widget.maxOvers))) {
        isLastBallBowled = true;
        print(isLastBallBowled);
      } else {
        isLastBallBowled = false;
      }
      print(bowler?.ballsBowled);
      if (totalBalls % 6 == 0 && totalOvers != widget.maxOvers) {
        totalOvers++;
        if(isLastBallBowled) {
          _showNewBowlerDialog(battingTeam);
        } else {
          _showNewBowlerDialog(bowlingTeam);
        }
         
        _changeStrike();
      }

      if (totalOvers >= widget.maxOvers) {
        print("Total Overs" + totalOvers.toString());
        print("Max Overs" + widget.maxOvers.toString());
        if(!isSecondInnings){
          _endInnings();
        } else {
          _endGame();
        }
      }

      if (runs % 2 != 0) {
        _changeStrike();
      }
    });
  }

  void _showNewBowlerDialog(List<Player> team) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Select a New Bowler"),
          content: DropdownButton<Player>(
            hint: const Text("Select New Bowler"),
            items: team.map((Player player) {
              return DropdownMenuItem<Player>(
                value: player,
                child: Text(player.name),
              );
            }).toList(),
            
            onChanged: (Player? selectedPlayer) {
              if (selectedPlayer != bowler) {
                 onBowlerSelected(selectedPlayer!);
                Navigator.pop(context);
              } 
               else if (selectedPlayer == bowler) {
                ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Select a different bowler - this bowler just bowled.')),
              );
              }
            },
            
          ),
        );
      },
    );
  }


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
          content: const Text(
            "The innings is over. Please follow the next instructions."
          ),
          actions: [
            TextButton(
              child: const Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
                if (!isSecondInnings) {
                  _setupSecondInnings(battingTeam, bowlingTeam);
                  setState(() {
                    isSecondInnings = true;
                  });
                  // _showNewBowlerDialog();
                } else {
                  _endGame();
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _endGame() {
    String temp = "";
    if(firstTeamScore > teamScore) {
      print("Team 1 Won!");
      temp = "Team 1 Won!";
    } else if (firstTeamScore < teamScore) {
      print("Team 2 Won!");
      temp = "Team 2 Won!";
    } else {
      print("Tie Game!");
      temp = "Tie Game!";
    }

    _storeMatchData(temp);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("End of Game"),
          content: Text(
            "The game is over. " + temp,
          ),
          actions: [
            TextButton(
              child: const Text("OK"),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => HomePage()),
                );
              },
            ),
          ],
        );
      },
    );
  }

  void _storeMatchData(String result) async {
  try {
    User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception("User is not logged in.");
    }

    String userEmail = user.email ?? "unknown";

    await FirebaseFirestore.instance.collection('matches').add({
      'email': userEmail,
      'team1Score': "Team 1 Score - $firstTeamScore",
      'team2Score': "Team 2 Score - $teamScore",
      'result': result,
      'timestamp': FieldValue.serverTimestamp(),
    });

    print("Match data stored successfully.");
  } catch (e) {
    print("Failed to store match data: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error saving match data: $e')),
    );
  }
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
      firstTeamScore = teamScore;
      teamScore = 0;
      currentWickets = 0;
      isSecondInnings = true;
      // battingTeam = bowlingTeam;
      // bowlingTeam = battingTeam;
      
    });

    _showNewInningsSetupDialog(bowlingTeam, battingTeam);
  }



  void _showNewInningsSetupDialog(List<Player> battingTeam, List<Player> bowlingTeam) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return NewInningsSetupDialog(
          availableBatsmen: battingTeam, 
          availableBowlers: bowlingTeam, 
          onBatsmenAndBowlerSelected: (Player newStrike, Player newNonStrike) {
            setState(() {
              batsmanOnStrike = newStrike;
              batsmanOnNonStrike = newNonStrike;
            });
            

          },
        );
      },
    );
  }

   void _showNewBatsmanDialog(List<Player> availableBatsmen) {

    showDialog(
      barrierDismissible: false,
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

  void onBowlerSelected(Player player) {
   
    print(player.name);
    setState(() {
      bowler = player;
    });
    print("New Bowler Name" + bowler!.name);
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
              "${bowler.wicketsTaken}/${bowler.runsOnBalls}     (${(bowler.ballsBowled~/6).round()}.${bowler.ballsBowled % 6})",
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
          !isSecondInnings
                ?"Team 1 Scorecard"
                :"Team 2 Scorecard",
          // "${widget.battingFirstTeam} Scorecard",
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
            
            if (batsmanOnStrike != null) _batsmanCard(batsmanOnStrike!, true),
            if (batsmanOnNonStrike != null) _batsmanCard(batsmanOnNonStrike!, false),

            const SizedBox(height: 20),
            const Text(
              "Bowler:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            if (bowler != null) _bowlerCard(bowler!),

            const Spacer(),
            _scoreInputRow(),
          ],
        ),
      ),
    );
  }
}
