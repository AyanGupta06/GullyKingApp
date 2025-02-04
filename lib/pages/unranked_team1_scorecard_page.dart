import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gully_king/pages/all_previous_games_page.dart';
import 'package:gully_king/pages/friends_teams_page.dart';
import 'package:gully_king/pages/home_page.dart';
import 'package:gully_king/pages/new_game_page.dart';
import 'package:gully_king/pages/new_profile_page.dart';
import 'package:gully_king/pages/scorecard_previous_unranked_games_page.dart';
import 'package:gully_king/pages/started_new_unranked_game_page.dart';
import 'package:gully_king/pages/unranked_team2_scorecard_page.dart';



class UnrankedTeam1ScoreCardPage extends StatefulWidget {
  final String timestamp;

  const UnrankedTeam1ScoreCardPage({
    Key? key,
    required this.timestamp,
  }) : super(key: key);

  @override
  State<UnrankedTeam1ScoreCardPage> createState() => _UnrankedTeam1ScoreCardPageState();
}

class _UnrankedTeam1ScoreCardPageState extends State<UnrankedTeam1ScoreCardPage> {
  int _selectedIndex = 1;
  int _isSelected = 1;

  void _navigateToPage(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0: // New Game
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const NewGamePage()),
        );
        break;
      case 1: // Records
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AllPreviousGamesPage()),
        );
        break;
      case 2: // Home
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
        break;
      case 3: // Friends
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const FriendsTeamsPage()),
        );
        break;
      case 4: // Profile
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const NewProfilePage()),
        );
        break;
      default:
        break;
    }
  }

  Future<Map<String, dynamic>> _fetchMatchData() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('matches')
        .where('timestamp', isEqualTo: Timestamp.fromDate(DateTime.parse(widget.timestamp)))
        .get();

    if (snapshot.docs.isEmpty) {
      throw Exception("No match data found.");
    }

    return snapshot.docs.first.data();
  }

  void _openSummaryPage(Map<String, dynamic> matchData) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ScorecardPreviousUnrankedGamesPage(
          timestamp: matchData['timestamp'].toDate().toIso8601String(),
        ),
      ),
    );
  }

  void _openTeam2ScoreCard(Map<String, dynamic> matchData) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UnrankedTeam2ScoreCardPage(
          timestamp: matchData['timestamp'].toDate().toIso8601String(),
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Match Scorecard"),
        backgroundColor: const Color.fromRGBO(53, 150, 207, 1),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _fetchMatchData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No match data available."));
          }

          final matchData = snapshot.data!;
          final team1Players = matchData['team1Players'] ?? [];
          final team2Players = matchData['team2Players'] ?? [];


          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.people_alt_sharp),
                      onPressed: () {
                        
                      },
                    ),
                    const Text(
                      "v.s."
                    ),
              
                    IconButton(
                      icon: const Icon(Icons.people_outline_sharp),
                      onPressed: () {
                        
                      },
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      matchData['team1Score'],
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "                                           "
                    ),
                    Text(
                      matchData['team2Score'],
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      matchData['team1Overs'],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    Text(
                      "                                                "
                    ),
                    Text(
                      matchData['team2Overs'],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      matchData['result'],
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 16),

                ToggleButtons(
                  isSelected: [_isSelected == 0, _isSelected == 1, _isSelected == 2],
                  onPressed: (int index) {
                    setState(() {
                      _isSelected = index;
                    });
                    index == 0 ? _openSummaryPage(matchData): index == 1? Text("hiifigrjj"): _openTeam2ScoreCard(matchData);
                  },
                  borderWidth: 0,
                  borderColor: Colors.transparent,
                  selectedBorderColor: Colors.transparent,
                  
                  fillColor: Color.fromRGBO(219, 227, 236, 0.49),
                  highlightColor: Color.fromRGBO(110, 127, 175, 0.8),
                  children: const<Widget> [
                    
                    Text("    Summary    ", style: TextStyle(color: Colors.black),),
                    Text("   Team 1 Scorecard   "),
                    Text("   Team 2 Scorecard   "),
                    
                  ]
                ),
                
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Expanded(flex: 3, child: Text("Batting", style: TextStyle(fontWeight: FontWeight.bold))),
                    Expanded(child: Text("R", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold))),
                    Expanded(child: Text("B", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold))),
                    Expanded(child: Text("S/R", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold))),
                  ],
                ),
                const Divider(),
                ...team1Players.map<Widget>((player) {
                  final playerName = player['name'] ?? 'Unknown';
                  final runs = player['runs'] ?? 0;
                  final balls = player['ballsFaced'] ?? 0;
                  final dismissal = player['outMessage'] ?? 'Not Out';
                  final strikeRate = balls > 0 ? truncateToDecimalPlaces((runs / balls) * 100, 2) : 0.00;

                

                 
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(playerName, style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text("  $dismissal", style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Expanded(flex: 3, child: SizedBox()),
                          Expanded(child: Text("$runs", textAlign: TextAlign.center)),
                          Expanded(child: Text("$balls", textAlign: TextAlign.center)),
                          Expanded(child: Text("$strikeRate", textAlign: TextAlign.center)),
                        ],
                      ),
                      const Divider(),
                    ],
                  );



                  
                }).toList(),
                const SizedBox(height: 16),
                const Text(
                  "Bowling",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Expanded(flex: 3, child: Text("Bowler", style: TextStyle(fontWeight: FontWeight.bold))),
                    Expanded(child: Text("O", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold))),
                    Expanded(child: Text("R", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold))),
                    Expanded(child: Text("W", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold))),
                    Expanded(child: Text("Econ", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold))),
                  ],
                ),
                const Divider(),
                ...team2Players.map<Widget>((player) {
                  final bowlerName = player['name'] ?? 'Unknown';
                  final overs = player['oversBowled'] ?? 0;
                  final runs = player['runsConceded'] ?? 0;
                  final wickets = player['wicketsTaken'] ?? 0;
                  final econ = overs > 0 ? truncateToDecimalPlaces(runs / overs, 2) : 0.00;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(flex: 3, child: Text(bowlerName, style: const TextStyle(fontWeight: FontWeight.bold))),
                          Expanded(child: Text("$overs", textAlign: TextAlign.center)),
                          Expanded(child: Text("$runs", textAlign: TextAlign.center)),
                          Expanded(child: Text("$wickets", textAlign: TextAlign.center)),
                          Expanded(child: Text("$econ", textAlign: TextAlign.center)),
                        ],
                      ),
                      const Divider(),
                    ],
                  );
                }).toList(),

              ],
            ),
          );
        },
      ),
      bottomNavigationBar: BottomAppBar(
        color: const Color.fromRGBO(53, 150, 207, 1),
        height: 70,
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildBottomBarIcon(
              icon: Icons.add_box_rounded,
              index: 0,
              label: 'New Game',
            ),
            _buildBottomBarIcon(
              icon: Icons.file_present_sharp,
              index: 1,
              label: 'Records',
            ),
            _buildBottomBarIcon(
              icon: Icons.home_sharp,
              index: 2,
              label: 'Home',
            ),
            _buildBottomBarIcon(
              icon: Icons.people_alt_sharp,
              index: 3,
              label: 'Friends',
            ),
            _buildBottomBarIcon(
              icon: Icons.person,
              index: 4,
              label: 'Account',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBarIcon({required IconData icon, required int index, required String label}) {
    return Tooltip(
      message: label,
      child: IconButton(
        icon: Icon(icon),
        color: _selectedIndex == index ? Colors.white : Colors.black,
        onPressed: () => _navigateToPage(index),
        iconSize: 30,
      ),
    );
  }

  double truncateToDecimalPlaces(num value, int fractionalDigits) =>
      (value * pow(10, fractionalDigits)).truncate() / pow(10, fractionalDigits);
}
