// // import 'package:flutter/material.dart';
// // import 'package:gully_king/player.dart';

// // class UnrankedScorecardPage extends StatefulWidget {
// //   final String? battingFirstTeam;
// //   final String? bowler;
// //   final String? batsmanOnStrike;
// //   final String? batsmanOnNonStrike;

// //   const UnrankedScorecardPage({
// //     super.key,
// //     required this.battingFirstTeam,
// //     required this.bowler,
// //     required this.batsmanOnStrike,
// //     required this.batsmanOnNonStrike,
    
// //   });

// //   @override
// //   _UnrankedScorecardPageState createState() => _UnrankedScorecardPageState();  

// // }

// // class _UnrankedScorecardPageState extends State<UnrankedScorecardPage> {
// //   String? selectedWicket;
// //   String? selectedRuns;
// //   int currentBall = 1;
// //   Map<int, String> ballActions = {};


// //   String batsmanOnStrikeScore = '0/0';
// //   String batsmanOnNonStrikeScore = '0/0'; 
// //   String bowlerStats = '0/0'; 

// //   late String batsmanOnStrike;
// //   late String batsmanOnNonStrike;
// //   late String bowler;
  
  

// //   @override
// //   void initState() {
// //     super.initState();
// //     batsmanOnStrike = widget.batsmanOnStrike!;
// //     batsmanOnNonStrike = widget.batsmanOnNonStrike!;
// //     var player1 = Player(name: batsmanOnStrike);
// //     print(player1.name);
// //     var player2 = Player(name: batsmanOnNonStrike);
// //     print(player2.name);
// //   } 
    


// //   void updateAction() {
// //     setState(() {
// //       ballActions[currentBall] = 'Runs: $selectedRuns';

// //       int runs = int.parse(selectedRuns!);
// //       List<String> strikeStats = batsmanOnStrikeScore.split('/');
// //       int currentBalls = int.parse(strikeStats[1]) + 1;
// //       batsmanOnStrikeScore = '${int.parse(strikeStats[0]) + runs} / $currentBalls';

// //       List<String> bowlerStatsList = bowlerStats.split('/');
// //       bowlerStats = '${int.parse(bowlerStatsList[0])} / ${int.parse(bowlerStatsList[1]) + runs}';

// //       if (runs % 2 != 0) {
// //         if (batsmanOnStrike == widget.batsmanOnStrike) {
// //           batsmanOnStrike = widget.batsmanOnNonStrike!;
// //           batsmanOnNonStrike = widget.batsmanOnStrike!;
// //         } else {
// //           batsmanOnStrike = widget.batsmanOnStrike!;
// //           batsmanOnNonStrike = widget.batsmanOnNonStrike!;
// //         }
// //       }

// //       currentBall = (currentBall % 6) + 1;
// //     });
// //   }
// //    Widget _ballCircle(int ballNumber) {
// //     return Container(
// //       width: 50,
// //       height: 50,
// //       decoration: BoxDecoration(
// //         shape: BoxShape.circle,
// //         color: Colors.blueAccent,
// //       ),
// //       child: Center(
// //         child: Text(
// //           ballActions[ballNumber] ?? '',
// //           style: const TextStyle(color: Colors.white),
// //         ),
// //       ),
// //     );
// //   }

// //   Widget _team1() {
// //     return const Text(
// //       "Team 1",
// //       style: TextStyle(fontSize: 20, fontWeight:FontWeight.bold, color: Colors.blueAccent)
// //     ); 
// //   }

// //   Widget _team2() {
// //     return const Text(
// //       "Team 2",
// //       style: TextStyle(fontSize: 20, fontWeight:FontWeight.bold, color: Colors.blueAccent)
// //     ); 
// //   }
  

// //   @override
// //   Widget build(BuildContext context) {
// //     batsmanOnStrike = widget.batsmanOnStrike!;
// //     batsmanOnNonStrike = widget.batsmanOnNonStrike!;
// //     bowler = widget.bowler!;
// //     var playerBowler = Player(name: bowler);
// //     var player1 = Player(name: batsmanOnStrike);

// //     print(player1.name);
// //     var player2 = Player(name: batsmanOnNonStrike);
// //     print(player2.name);
// //     int teamRuns = player1.runs + player2.runs;
// //     String teamRunsString = teamRuns.toString();
// //     int teamBallsFaced = player1.ballsFaced + player2.ballsFaced;
// //     String teamBallsFacedString = teamBallsFaced.toString();
// //     return Scaffold(
// //       body: Container(
// //         width: double.infinity,
// //         height: double.infinity,
// //         decoration: const BoxDecoration(
// //           image: DecorationImage(
// //             image: AssetImage('assets/bg4.png'),
// //             fit: BoxFit.cover,
// //           ),
// //         ),
// //         child: Column(
// //           mainAxisAlignment: MainAxisAlignment.start,
// //           crossAxisAlignment: CrossAxisAlignment.center,
// //           children: [
// //             const SizedBox(height: 40),
// //             Row(
// //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //               children: [
// //                 Padding(
// //                   padding: const EdgeInsets.only(left: 20),
// //                   child: Column(
// //                     crossAxisAlignment: CrossAxisAlignment.start,
// //                     children: [
// //                       const Text(
// //                         "Team 1 Runs",
// //                         style: TextStyle(
// //                           fontSize: 18,
// //                           fontWeight: FontWeight.bold,
// //                           color: Colors.black,
// //                         ),
// //                       ),
// //                       Text(
// //                         teamRunsString+ "/" + teamBallsFacedString,
// //                         style: const TextStyle(
// //                           fontSize: 16,
// //                           color: Colors.black,
// //                         ),
// //                       ),
// //                       const SizedBox(height: 20, width: 40),
// //                       Text(
// //                         player1.name + " - " + player1.runs.toString() + "/" + player1.ballsFaced.toString(),
// //                         style: TextStyle (
// //                           color: Colors.black,
// //                           fontSize: 16,
// //                         )
// //                       ),
// //                       Text(
// //                         player2.name + " - " + player2.runs.toString() + "/" + player2.ballsFaced.toString(),
// //                         style: TextStyle (
// //                           color: Colors.black,
// //                           fontSize: 16,
// //                         )
// //                       ),
// //                     ],
// //                   ),
// //                 ),
// //                 Padding(
// //                   padding: const EdgeInsets.only(right: 20),
// //                   child: Column(
// //                     crossAxisAlignment: CrossAxisAlignment.end,
// //                     children: [
// //                       const Text(
// //                         "Team 2 Runs",
// //                         style: TextStyle(
// //                           fontSize: 18,
// //                           fontWeight: FontWeight.bold,
// //                           color: Colors.black,
// //                         ),
// //                       ),
// //                       const Text(
// //                         "Yet to Bat",
// //                         style: TextStyle(
// //                           fontSize: 16,
// //                           color: Colors.black,
// //                         ),
// //                       ),
// //                       Text(
// //                         playerBowler.name,
// //                         style: const TextStyle(
// //                           fontSize: 16,
// //                           color: Colors.black,
// //                         ),
// //                       ),
// //                     ],
// //                   ),
// //                 ),
// //               ]
// //             ),
              
// //              const SizedBox(height: 40),
// //             Wrap(
// //               alignment: WrapAlignment.center,
// //               spacing: 10,
// //               runSpacing: 10,
// //               children: List.generate(
// //                 6,
// //                 (index) => _ballCircle(index + 1),
// //               ),
// //             ),

// //           ],
// //         ),
// //       ),
// //     );
// //   }

 
// // }
// import 'package:flutter/material.dart';
// import 'package:gully_king/pages/new_unranked_game_page.dart';

// class UnrankedScorecardPage extends StatefulWidget {
//   final String? battingFirstTeam;
//   final Player? batsmanOnStrike;
//   final Player? batsmanOnNonStrike;
//   final Player? bowler;

//   const UnrankedScorecardPage({
//     super.key,
//     required this.battingFirstTeam,
//     required this.batsmanOnStrike,
//     required this.batsmanOnNonStrike,
//     required this.bowler,
//   });

//   @override
//   State<UnrankedScorecardPage> createState() => _UnrankedScorecardPageState();
// }

// class _UnrankedScorecardPageState extends State<UnrankedScorecardPage> {
//   Player? batsmanOnStrike;
//   Player? batsmanOnNonStrike;
//   Player? bowler;
//   int teamScore = 0;
//   int totalOvers = 0;
//   int totalBalls = 0;

//   @override
//   void initState() {
//     super.initState();
//     batsmanOnStrike = widget.batsmanOnStrike;
//     batsmanOnNonStrike = widget.batsmanOnNonStrike;
//     bowler = widget.bowler;
//   }

//   void _updateScore(int runs) {
//     setState(() {
//       // Update batsman on strike
//       batsmanOnStrike?.runs += runs;
//       batsmanOnStrike?.ballsFaced++;

//       // Update bowler's stats
//       bowler?.runsOnBalls += runs;

//       // Update team score
//       teamScore += runs;

//       // Update overs and balls
//       totalBalls++;
//       if (totalBalls % 6 == 0) {
//         totalOvers++;
//       }
//     });
//   }

//   void _changeStrike() {
//     setState(() {
//       final temp = batsmanOnStrike;
//       batsmanOnStrike = batsmanOnNonStrike;
//       batsmanOnNonStrike = temp;
//     });
//   }

//   Widget _batsmanCard(Player batsman, bool isOnStrike) {
//     return Card(
//       color: isOnStrike ? Colors.blue[100] : Colors.white,
//       child: Padding(
//         padding: const EdgeInsets.all(10.0),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Text(
//               batsman.name,
//               style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//             ),
//             Text(
//               "${batsman.runs} (${batsman.ballsFaced})",
//               style: const TextStyle(fontSize: 16),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _bowlerCard(Player bowler) {
//     return Card(
//       child: Padding(
//         padding: const EdgeInsets.all(10.0),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Text(
//               bowler.name,
//               style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//             ),
//             Text(
//               "Runs Conceded: ${bowler.runsOnBalls}",
//               style: const TextStyle(fontSize: 16),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _scoreInputRow() {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//       children: [
//         for (int i = 0; i <= 6; i++) ...[
//           ElevatedButton(
//             onPressed: () {
//               _updateScore(i);
//               if (i % 2 != 0) {
//                 _changeStrike();
//               }
//             },
//             style: ElevatedButton.styleFrom(
//               backgroundColor: i == 4 || i == 6 ? Colors.green : Colors.blue,
//             ),
//             child: Text("$i"),
//           ),
//         ],
//         ElevatedButton(
//           onPressed: _changeStrike,
//           style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
//           child: const Text("Change Strike"),
//         ),
//       ],
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           "${widget.battingFirstTeam} Scorecard",
//           style: const TextStyle(color: Colors.black),
//         ),
//         backgroundColor: const Color.fromRGBO(53, 150, 207, 1),
//         elevation: 0,
//       ),
//       body: Container(
//         decoration: const BoxDecoration(
//           image: DecorationImage(
//             image: AssetImage('assets/bg4.png'),
//             fit: BoxFit.cover,
//           ),
//         ),
//         height: double.infinity,
//         width: double.infinity,
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               "Team Score: $teamScore",
//               style: const TextStyle(
//                 fontSize: 24,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             Text(
//               "Overs: $totalOvers.${totalBalls % 6}",
//               style: const TextStyle(
//                 fontSize: 18,
//                 color: Colors.black54,
//               ),
//             ),
//             const SizedBox(height: 20),
//             _batsmanCard(batsmanOnStrike!, true),
//             _batsmanCard(batsmanOnNonStrike!, false),
//             const SizedBox(height: 20),
//             const Text(
//               "Bowler:",
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//             ),
//             _bowlerCard(bowler!),
//             const SizedBox(height: 40),
//             _scoreInputRow(),
//           ],
//         ),
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:gully_king/pages/new_batsman_dialog.dart';
import 'package:gully_king/pages/new_innings_setup_dialog.dart';
import 'package:gully_king/pages/new_unranked_game_page.dart';

class UnrankedScorecardPage extends StatefulWidget {
  final String? battingFirstTeam;
  final Player? batsmanOnStrike;
  final Player? batsmanOnNonStrike;
  final Player? bowler;
  final int maxOvers;

  const UnrankedScorecardPage({
    super.key,
    required this.battingFirstTeam,
    required this.batsmanOnStrike,
    required this.batsmanOnNonStrike,
    required this.bowler,
    required this.maxOvers,
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

  @override
  void initState() {
    super.initState();
    batsmanOnStrike = widget.batsmanOnStrike;
    batsmanOnNonStrike = widget.batsmanOnNonStrike;
    bowler = widget.bowler;
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
  //       _showNewBatsmanDialog();
  //     }
  //   });
  // }
  void _recordWicket() {
    setState(() {
      currentWickets++;
      bowler?.wicketsTaken++;

      if (currentWickets == battingTeam.length - 1) {
        _endInnings();
      } else {
        List<Player> availableBatsmen = battingTeam
            .where((player) => !player.hasBatted) 
            .toList();

        List<Player> availableTest = [];
        for(int i = 0; i < battingTeam.length; i++) {
          print(battingTeam[i].hasBatted);
        }
        print(battingTeam.length);

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
              "The innings is over. Please select the batsmen and bowler for the next innings."),
          actions: [
            TextButton(
              child: const Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
                _setupSecondInnings(battingTeam, bowlingTeam); 
              },
            ),
          ],
        );
      },
    );
  }




  void _setupSecondInnings(List<Player> battingTeam, List<Player> bowlingTeam) {
    setState(() {
      this.battingTeam = battingTeam; 
      this.bowlingTeam = bowlingTeam; 
      batsmanOnStrike = null;
      batsmanOnNonStrike = null;
      bowler = null;
      totalOvers = 0;
      totalBalls = 0;
      teamScore = 0;
      currentWickets = 0;
    });

    _showNewInningsSetupDialog(battingTeam, bowlingTeam);
  }





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
                // onBatsmanSelected(selectedPlayer);
                Navigator.pop(context);
              }
            },
          ),
        );
      },
    );
  }



  // void _showNewBatsmanDialog(List<Player> availableBatsmen) {
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return NewBatsmanDialog(
  //         availableBatsmen: availableBatsmen, 
  //         onBatsmanSelected: (Player newBatsman) {
  //           setState(() {
  //             batsmanOnStrike = newBatsman;
  //             batsmanOnStrike!.hasBatted = true; 
  //           });
  //         },
  //       );
  //     },
  //   );
  // }


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


