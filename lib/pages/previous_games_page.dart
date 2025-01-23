import 'package:flutter/material.dart';
import 'package:gully_king/auth.dart';
import 'package:gully_king/pages/all_previous_games_page.dart';
import 'package:gully_king/pages/friends_teams_page.dart';
import 'package:gully_king/pages/home_page.dart';
import 'package:gully_king/pages/new_game_page.dart';
import 'package:gully_king/pages/new_profile_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gully_king/pages/scorecard_previous_unranked_games_page.dart';
import 'package:intl/intl.dart';

class PreviousGamesPage extends StatefulWidget {
  const PreviousGamesPage({super.key});

  @override
  State<PreviousGamesPage> createState() => _PreviousGamesPageState();
}

class _PreviousGamesPageState extends State<PreviousGamesPage> {
  int _selectedIndex = 1;
  final User? user = FirebaseAuth.instance.currentUser;
  List<QueryDocumentSnapshot<Map<String, dynamic>>> matches = [];

  Future<void> _fetchMatches() async {
    if (user == null) return;

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('matches')
          .where('email', isEqualTo: user!.email)
          .orderBy('timestamp', descending: true)
          .get();

      setState(() {
        matches = snapshot.docs;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error fetching matches: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchMatches();
  }
  void _navigateToPage(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0: //new game
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const NewGamePage()),
        );
        break;
      case 1: //old games
      Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AllPreviousGamesPage()),
        );
        break;
      case 2: //home
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
        break;
      case 3: //friends
      Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const FriendsTeamsPage()),
        );
        break;
      case 4: //profile
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const NewProfilePage()),
        );
        break;

      default:
      //idk
        break;
    }
  }

  Widget _buildMatchCard(Map<String, dynamic> matchData) {
    final date = DateTime.fromMillisecondsSinceEpoch(matchData['timestamp'].seconds * 1000);
    final formattedDate = DateFormat("MMMM d'th', y").format(date);
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Date: $formattedDate",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              "Team 1: ${matchData['team1Score']}",
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              "Team 2: ${matchData['team2Score']}",
              style: const TextStyle(fontSize: 16),
            ),
            // const SizedBox(height: 8),
            Row(
              children: [
                Text(
                matchData['result'],
                  style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_forward),
                    onPressed: () {
                      //navigate to full scorecard to be added
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ScorecardPreviousUnrankedGamesPage()),
                      );
                    },
                  ),
                ),
              ]
              
            ),
            
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Transform.rotate(
          angle: 0, 
          child: Tooltip(
            message: 'Logout',
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
        title: const Text("Previous Unranked Matches"),
        backgroundColor: const Color.fromRGBO(53, 150, 207, 1),
      ),
      body: matches.isEmpty
          ? const Center(
              child: Text(
                "No Matches Found",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            )
          : ListView.builder(
              itemCount: matches.length,
              itemBuilder: (context, index) {
                final matchData = matches[index].data();
                return _buildMatchCard(matchData);
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

  Widget _buildBottomBarIcon(
      {required IconData icon, required int index, required String label}) {
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
