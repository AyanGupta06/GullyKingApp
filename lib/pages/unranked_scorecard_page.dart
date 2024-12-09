// import 'package:flutter/material.dart';

// class UnrankedScorecardPage extends StatefulWidget {
//   final String? battingFirstTeam;
//   final String? bowler;
//   final String? batsmanOnStrike;
//   final String? batsmanOnNonStrike;

//   const UnrankedScorecardPage({
//     super.key,
//     required this.battingFirstTeam,
//     required this.bowler,
//     required this.batsmanOnStrike,
//     required this.batsmanOnNonStrike,
//   });

//   @override
//   _UnrankedScorecardPageState createState() => _UnrankedScorecardPageState();
// }

// class _UnrankedScorecardPageState extends State<UnrankedScorecardPage> {
//   String? selectedWicket;
//   String? selectedRuns;
//   int currentBall = 1;
//   Map<int, String> ballActions = {};

//   String batsmanOnStrikeScore = '0/0';
//   String batsmanOnNonStrikeScore = '0/0'; 
//   String bowlerStats = '0/0'; 

//   late String batsmanOnStrike;
//   late String batsmanOnNonStrike;

//   @override
//   void initState() {
//     super.initState();
//     batsmanOnStrike = widget.batsmanOnStrike!;
//     batsmanOnNonStrike = widget.batsmanOnNonStrike!;
//   }

//   void updateAction() {
//     setState(() {
//       ballActions[currentBall] = 'Runs: $selectedRuns';

//       int runs = int.parse(selectedRuns!);
//       List<String> strikeStats = batsmanOnStrikeScore.split('/');
//       int currentBalls = int.parse(strikeStats[1]) + 1;
//       batsmanOnStrikeScore = '${int.parse(strikeStats[0]) + runs} / $currentBalls';

//       List<String> bowlerStatsList = bowlerStats.split('/');
//       bowlerStats = '${int.parse(bowlerStatsList[0])} / ${int.parse(bowlerStatsList[1]) + runs}';

//       if (runs % 2 != 0) {
//         if (batsmanOnStrike == widget.batsmanOnStrike) {
//           batsmanOnStrike = widget.batsmanOnNonStrike!;
//           batsmanOnNonStrike = widget.batsmanOnStrike!;
//         } else {
//           batsmanOnStrike = widget.batsmanOnStrike!;
//           batsmanOnNonStrike = widget.batsmanOnNonStrike!;
//         }
//       }

//       currentBall = (currentBall % 6) + 1;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Container(
//         width: double.infinity,
//         height: double.infinity,
//         decoration: const BoxDecoration(
//           image: DecorationImage(
//             image: AssetImage('assets/bg4.png'),
//             fit: BoxFit.cover,
//           ),
//         ),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.start,
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             const SizedBox(height: 40),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Padding(
//                   padding: const EdgeInsets.only(left: 20),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: const [
//                       Text(
//                         "Team 1 Score",
//                         style: TextStyle(
//                           fontSize: 18,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.black,
//                         ),
//                       ),
//                       Text(
//                         "Team 1",
//                         style: TextStyle(
//                           fontSize: 16,
//                           color: Colors.black,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 Padding(
//                   padding: const EdgeInsets.only(right: 20),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.end,
//                     children: const [
//                       Text(
//                         "Team 2 Score",
//                         style: TextStyle(
//                           fontSize: 18,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.black,
//                         ),
//                       ),
//                       Text(
//                         "Team 2",
//                         style: TextStyle(
//                           fontSize: 16,
//                           color: Colors.black,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 40),
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 20),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   if (widget.battingFirstTeam == "Team 1") ...[
//                     Text(
//                       "$batsmanOnStrike* ($batsmanOnStrikeScore)",
//                       style: const TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.black,
//                       ),
//                     ),
//                     Text(
//                       "$batsmanOnNonStrike ($batsmanOnNonStrikeScore)",
//                       style: const TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.black,
//                       ),
//                     ),
//                   ] else ...[
//                     Text(
//                       "$batsmanOnNonStrike* ($batsmanOnStrikeScore)",
//                       style: const TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.black,
//                       ),
//                     ),
//                     Text(
//                       "$batsmanOnStrike ($batsmanOnStrikeScore)",
//                       style: const TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.black,
//                       ),
//                     ),
//                   ],
//                   const SizedBox(height: 20),
//                   Text(
//                     "${widget.bowler} - ($bowlerStats)",
//                     style: const TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.black,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 40),
//             Wrap(
//               alignment: WrapAlignment.center,
//               spacing: 10,
//               runSpacing: 10,
//               children: List.generate(
//                 6,
//                 (index) => _ballCircle(index + 1),
//               ),
//             ),
//             const SizedBox(height: 40),
//             const Text(
//               'Actions',
//               style: TextStyle(
//                 fontWeight: FontWeight.bold,
//                 color: Colors.black,
//               ),
//             ),
//             DropdownButton<String>(
//               value: selectedWicket,
//               hint: const Text('Select Wicket'),
//               items: ['LBW', 'Bowled', 'Stumped', 'Caught'].map((String value) {
//                 return DropdownMenuItem<String>(
//                   value: value,
//                   child: Text(value),
//                 );
//               }).toList(),
//               onChanged: (value) {
//                 setState(() {
//                   selectedWicket = value!;
//                 });
//               },
//             ),
//             DropdownButton<String>(
//               value: selectedRuns,
//               hint: const Text('Select Runs'),
//               items: ['1', '2', '3', '4', '5', '6'].map((String value) {
//                 return DropdownMenuItem<String>(
//                   value: value,
//                   child: Text(value),
//                 );
//               }).toList(),
//               onChanged: (value) {
//                 setState(() {
//                   selectedRuns = value!;
//                 });
//               },
//             ),
//             ElevatedButton(
//               onPressed: updateAction,
//               child: const Text('Enter Action'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _ballCircle(int ballNumber) {
//     return Container(
//       width: 50,
//       height: 50,
//       decoration: BoxDecoration(
//         shape: BoxShape.circle,
//         color: Colors.blueAccent,
//       ),
//       child: Center(
//         child: Text(
//           ballActions[ballNumber] ?? '',
//           style: const TextStyle(color: Colors.white),
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:gully_king/player.dart';

class UnrankedScorecardPage extends StatefulWidget {
  final String? battingFirstTeam;
  final String? bowler;
  final String? batsmanOnStrike;
  final String? batsmanOnNonStrike;

  const UnrankedScorecardPage({
    super.key,
    required this.battingFirstTeam,
    required this.bowler,
    required this.batsmanOnStrike,
    required this.batsmanOnNonStrike,
  });

  @override
  _UnrankedScorecardPageState createState() => _UnrankedScorecardPageState();
}

class _UnrankedScorecardPageState extends State<UnrankedScorecardPage> {
  String? selectedWicket;
  String? selectedRuns;
  int currentBall = 1;
  Map<int, String> ballActions = {};


  String batsmanOnStrikeScore = '0/0';
  String batsmanOnNonStrikeScore = '0/0'; 
  String bowlerStats = '0/0'; 

  late String batsmanOnStrike;
  late String batsmanOnNonStrike;
  

  @override
  void initState() {
    super.initState();
    batsmanOnStrike = widget.batsmanOnStrike!;
    batsmanOnNonStrike = widget.batsmanOnNonStrike!;
    var player1 = Player(name: batsmanOnStrike);
    print(player1.name);
    var player2 = Player(name: batsmanOnNonStrike);
    print(player2.name);
  }
    


  void updateAction() {
    setState(() {
      ballActions[currentBall] = 'Runs: $selectedRuns';

      int runs = int.parse(selectedRuns!);
      List<String> strikeStats = batsmanOnStrikeScore.split('/');
      int currentBalls = int.parse(strikeStats[1]) + 1;
      batsmanOnStrikeScore = '${int.parse(strikeStats[0]) + runs} / $currentBalls';

      List<String> bowlerStatsList = bowlerStats.split('/');
      bowlerStats = '${int.parse(bowlerStatsList[0])} / ${int.parse(bowlerStatsList[1]) + runs}';

      if (runs % 2 != 0) {
        if (batsmanOnStrike == widget.batsmanOnStrike) {
          batsmanOnStrike = widget.batsmanOnNonStrike!;
          batsmanOnNonStrike = widget.batsmanOnStrike!;
        } else {
          batsmanOnStrike = widget.batsmanOnStrike!;
          batsmanOnNonStrike = widget.batsmanOnNonStrike!;
        }
      }

      currentBall = (currentBall % 6) + 1;
    });
  }
   Widget _ballCircle(int ballNumber) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.blueAccent,
      ),
      child: Center(
        child: Text(
          ballActions[ballNumber] ?? '',
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Widget _team1() {
    return const Text(
      "Team 1",
      style: TextStyle(fontSize: 20, fontWeight:FontWeight.bold, color: Colors.blueAccent)
    ); 
  }
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/bg4.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
                  padding: const EdgeInsets.only(left: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children:  [
                      _team1(),
                      Text(
                        "Team 1",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
            const SizedBox(height: 140),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 10,
              runSpacing: 10,
              children: List.generate(
                6,
                (index) => _ballCircle(index + 1),
              ),
            ),

          ],
        ),
      ),
    );
  }

 
}
