import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gully_king/pages/all_previous_games_page.dart';
import 'package:gully_king/pages/friends_teams_page.dart';
import 'package:gully_king/pages/home_page.dart';
import 'package:gully_king/pages/new_game_page.dart';
import 'package:gully_king/pages/new_profile_page.dart';

class ScorecardPreviousUnrankedGamesPage extends StatefulWidget {
  final String timestamp;

  const ScorecardPreviousUnrankedGamesPage({
    Key? key,
    required this.timestamp,
  }) : super(key: key);

  @override
  State<ScorecardPreviousUnrankedGamesPage> createState() => _ScorecardPreviousUnrankedGamesPageState();
}

class _ScorecardPreviousUnrankedGamesPageState extends State<ScorecardPreviousUnrankedGamesPage> {
  int _selectedIndex = 1; // Default to 'Records' index

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Match Scorecard"),
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    matchData['team1Score'],
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
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
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text("Team 1 Players"),
                        content: SingleChildScrollView(
                          child: Column(
                            children: team1Players.isNotEmpty
                                ? team1Players.map<Widget>((player) {
                                    final playerName = player['name'] ?? 'Unknown';
                                    final runs = player['runs'] ?? 'N/A';
                                    final balls = player['ballsFaced'] ?? 'N/A';
                                    final dismissal = player['outMessage'] ?? 'Not Out';

                                    return ListTile(
                                      title: Text(playerName),
                                      subtitle: Text(
                                        "Runs: $runs\nBalls: $balls\nDismissal: $dismissal",
                                      ),
                                    );
                                  }).toList()
                                : [
                                    const Text("No players found for Team 1."),
                                  ],
                          ),
                        ),
                      );
                    },
                  );
                },
                child: const Text("View Team 1 Players", style: TextStyle(color: Colors.blue)),
              ),

              const SizedBox(height: 16),
              GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text("Team 2 Players"),
                        content: SingleChildScrollView(
                          child: Column(
                            children: team2Players.isNotEmpty
                                ? team2Players.map<Widget>((player) {
                                    final playerName = player['name'] ?? 'Unknown';
                                    final runs = player['runs'] ?? 'N/A';
                                    final balls = player['ballsFaced'] ?? 'N/A';
                                    final dismissal = player['outMessage'] ?? 'Not Out';

                                    return ListTile(
                                      title: Text(playerName),
                                      subtitle: Text(
                                        "Runs: $runs\nBalls: $balls\nDismissal: $dismissal",
                                      ),
                                    );
                                  }).toList()
                                : [
                                    const Text("No players found for Team 2."),
                                  ],
                          ),
                        ),
                      );
                    },
                  );
                },
                child: const Text("View Team 2 Players", style: TextStyle(color: Colors.blue)),
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
