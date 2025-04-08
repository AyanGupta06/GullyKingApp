import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gully_king/pages/Previous%20Games/Previous%20Ranked%20Games/ranked_team1_scorecard_page.dart';
import 'package:gully_king/pages/Previous%20Games/Previous%20Ranked%20Games/ranked_team2_scorecard_page.dart';
import 'package:gully_king/pages/Previous%20Games/all_previous_games_page.dart';
import 'package:gully_king/pages/Friends/friends_teams_page.dart';
import 'package:gully_king/pages/home_page.dart';
import 'package:gully_king/pages/New%20Game/new_game_page.dart';
import 'package:gully_king/pages/new_profile_page.dart';


class ScorecardPreviousRankedGamesPage extends StatefulWidget {
  final String timestamp;

  const ScorecardPreviousRankedGamesPage({
    Key? key,
    required this.timestamp,
  }) : super(key: key);

  @override
  State<ScorecardPreviousRankedGamesPage> createState() => _ScorecardPreviousRankedGamesPageState();
}

class _ScorecardPreviousRankedGamesPageState extends State<ScorecardPreviousRankedGamesPage> {
  int _selectedIndex = 1;
  int _isSelected = 0;

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
        .collection('ranked_matches')
        .where('timestamp', isEqualTo: Timestamp.fromDate(DateTime.parse(widget.timestamp)))
        .get();

    if (snapshot.docs.isEmpty) {
      throw Exception("No match data found.");
    }

    return snapshot.docs.first.data();
  }

  Map<String, dynamic> _getBestBatsman(List<dynamic> players) {
    return players.reduce((curr, next) => (curr['runs'] ?? 0) > (next['runs'] ?? 0) ? curr : next);
  }

  Map<String, dynamic> _getBestBowler(List<dynamic> players) {
    List<dynamic> players1 = [];
    for(int i = 0; i < players.length; i++) {
      if(players[i]['ballsBowled'] != 0) {
        players1.add(players[i]);
      }
    }
    return players1.reduce((curr, next) => (curr['wicketsTaken'] ?? 0) > (next['wicketsTaken'] ?? 0) || ((curr['runsOnBalls'] ?? 0)/(curr['ballsBowled'] ?? 0)) < ((curr['runsOnBalls'] ?? 0)/(curr['ballsBowled'] ?? 0)) ? curr : next);
  }




  void _openTeam1ScoreCard(Map<String, dynamic> matchData) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RankedTeam1ScorecardPage(
          timestamp: matchData['timestamp'].toDate().toIso8601String(),
        ),
      ),
    );
  }

  void _openTeam2ScoreCard(Map<String, dynamic> matchData) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RankedTeam2ScorecardPage(
          timestamp: matchData['timestamp'].toDate().toIso8601String(),
        ),
      ),
    );
  }

  Future<String> getNameFromEmail(String email) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: email)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      return snapshot.docs.first['username'] ?? email;
    } else {
      return email; 
    }
  }



  @override
  Widget build(BuildContext context) {
    const List<String> toggleButtonNames = ["Summary", "Team 1 Scorecard", "Team 2 Scorecard"];;
    return Scaffold(
      appBar: AppBar(
        leading: Transform.rotate(
          angle: 0,
          child: Tooltip(
            message: "Match Scorecard",
            child: IconButton(
              icon: const Icon(Icons.file_present_sharp),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AllPreviousGamesPage()),
                );
              },
            ),
          ),
        ),
        title: const Text(
            "Match Scorecard",
            style: TextStyle(fontSize: 22, fontWeight:FontWeight.normal, color: Colors.black)
        ),
        backgroundColor: const Color.fromRGBO(53, 150, 207, 1),
        elevation: 0,
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

          final bestBatsman1 = _getBestBatsman(team1Players);
          final bestBatsman2 = _getBestBatsman(team2Players);
          final bestBowler1 = _getBestBowler(team1Players);
          final bestBowler2 = _getBestBowler(team2Players);
          // _algorithim();



          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 16),

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
                      index ==1 ? _openTeam1ScoreCard(matchData): _openTeam2ScoreCard(matchData);
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

                const SizedBox(height: 16),
                const Text("First Innings", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FutureBuilder<String>(
                          future: getNameFromEmail(bestBatsman1['email']),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const Text("Loading...");
                            } else if (snapshot.hasError) {
                              return Text("Error: ${snapshot.error}");
                            } else {
                              return Text(
                                snapshot.data ?? bestBatsman1['email'],
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              );
                            }
                          },
                        ),

                        Text("${bestBatsman1['runs']} (${bestBatsman1['ballsFaced']})"),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        FutureBuilder<String>(
                          future: getNameFromEmail(bestBowler2['email']),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const Text("Loading...");
                            } else if (snapshot.hasError) {
                              return Text("Error: ${snapshot.error}");
                            } else {
                              return Text(
                                snapshot.data ?? bestBatsman1['email'],
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              );
                            }
                          },
                        ),
                        Text("${bestBowler2['wicketsTaken']}/${bestBowler2['runsOnBalls']} (${(bestBowler2['ballsBowled']~/6).round()}.${bestBowler2['ballsBowled'] == 6? 0: bestBowler2['ballsBowled']})")
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text("Second Innings", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FutureBuilder<String>(
                          future: getNameFromEmail(bestBatsman2['email']),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const Text("Loading...");
                            } else if (snapshot.hasError) {
                              return Text("Error: ${snapshot.error}");
                            } else {
                              return Text(
                                snapshot.data ?? bestBatsman1['email'],
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              );
                            }
                          },
                        ),
                        Text("${bestBatsman2['runs']} (${bestBatsman2['ballsFaced']})"),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        FutureBuilder<String>(
                          future: getNameFromEmail(bestBowler1['email']),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const Text("Loading...");
                            } else if (snapshot.hasError) {
                              return Text("Error: ${snapshot.error}");
                            } else {
                              return Text(
                                snapshot.data ?? bestBatsman1['email'],
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              );
                            }
                          },
                        ),
                        Text("${bestBowler1['wicketsTaken']}/${bestBowler1['runsOnBalls']} (${(bestBowler1['ballsBowled']~/6).round()}.${bestBowler1['ballsBowled'] == 6 ? 0: bestBowler1['ballsBowled']})")
                      ],
                    ),
                  ],
                ),

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

  double truncateToDecimalPlaces(num value, int fractionalDigits) => (value * pow(10,
      fractionalDigits)).truncate() / pow(10, fractionalDigits);

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
}