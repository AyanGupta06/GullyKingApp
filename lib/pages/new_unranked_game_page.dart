import 'package:flutter/material.dart';
import 'package:gully_king/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gully_king/pages/new_profile_page.dart';
import 'package:gully_king/pages/started_new_unranked_game_page.dart';
import 'package:gully_king/pages/your_teams_page.dart';

import 'home_page.dart';
import 'new_game_page.dart';
import 'friends_teams_page.dart';

// Player class
class Player {
  String name;
  int runs;
  int ballsFaced;
  int runsOnBalls;
  int ballsBowled;
  int wicketsTaken;
  bool hasBatted;

  Player({
    required this.name,
    this.runs = 0,
    this.ballsFaced = 0,
    this.runsOnBalls = 0,
    this.ballsBowled = 0,
    this.wicketsTaken = 0,
    this.hasBatted = false,
  });

  void setHasBatted(bool test) {
    hasBatted = test;
  }
}

class NewUnrankedGamePage extends StatefulWidget {
  const NewUnrankedGamePage({super.key});

  @override
  State<NewUnrankedGamePage> createState() => _NewUnrankedGamePageState();
}

class _NewUnrankedGamePageState extends State<NewUnrankedGamePage> {
  int _selectedIndex = 0;
  final TextEditingController _overSelectValue = TextEditingController();
  final TextEditingController _controllerTeam1 = TextEditingController();
  final TextEditingController _controllerTeam2 = TextEditingController();

  final User? user = Auth().currentUser;
  String? errorMessage = '';

  List<Player> team1Players = []; // List of Player objects for Team 1
  List<Player> team2Players = []; // List of Player objects for Team 2

  String username = "";
  String position = "";

  Future<void> _fetchUserData() async {
    if (user == null) return;

    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .get();

      setState(() {
        username = userDoc['username'] ?? "N/A";
        position = userDoc['position'] ?? "N/A";
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error fetching user data: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  void _navigateToPage(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const NewGamePage()),
        );
        break;
      case 1:
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
        break;
      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const FriendsTeamsPage()),
        );
        break;
      case 4:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const NewProfilePage()),
        );
        break;
      default:
        break;
    }
  }

  Widget _entryField(String hintText, TextEditingController controller) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.blueAccent),
        filled: true,
        fillColor: Colors.grey[100],
        prefixIcon: const Icon(
          Icons.sports_cricket_sharp,
          color: Colors.blueAccent,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20.0),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _entryFieldTeam(String hintText, TextEditingController controller) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.blueAccent),
        filled: true,
        fillColor: Colors.grey[100],
        prefixIcon: const Icon(
          Icons.people_alt_sharp,
          color: Colors.blueAccent,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20.0),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _addToTeam1Button() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blueAccent,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
      ),
      onPressed: _addToTeam1,
      child: const Text("Add to Team 1"),
    );
  }

  void _addToTeam1() {
    final playerName = _controllerTeam1.text.trim();
    if (playerName.isNotEmpty) {
      setState(() {
        team1Players.add(Player(name: playerName)); 
        _controllerTeam1.clear();
      });
    }
  }

  Widget _addToTeam2Button() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blueAccent,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
      ),
      onPressed: _addToTeam2,
      child: const Text("Add to Team 2"),
    );
  }

  void _addToTeam2() {
    final playerName = _controllerTeam2.text.trim();
    if (playerName.isNotEmpty) {
      setState(() {
        team2Players.add(Player(name: playerName)); 
        _controllerTeam2.clear();
      });
    }
  }

  Widget _teamSection(String teamName, List<Player> players) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          teamName,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 10),
        players.isEmpty
            ? const Text(
                "No players added yet",
                style: TextStyle(color: Colors.white70),
              )
            : Column(
                children: players.map((player) {
                  return ListTile(
                    leading: const Icon(Icons.person, color: Colors.blueAccent),
                    title: Text(
                      player.name, // Display Player name
                      style: const TextStyle(color: Colors.white),
                    ),
                  );
                }).toList(),
              ),
      ],
    );
  }

  Widget _errorMessage() {
    return Text(
      errorMessage == '' ? '' : 'Error: $errorMessage',
      style: const TextStyle(color: Colors.white),
      textAlign: TextAlign.left,
    );
  }

  Widget _startButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blueAccent,
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
      ),
      onPressed: _validateAndStart,
      child: const Text("Start Game"),
    );
  }

  void _validateAndStart() {
    setState(() {
      errorMessage = '';
    });

    if (_overSelectValue.text.isEmpty) {
      setState(() {
        errorMessage = 'Please fill this field: Number of Overs';
      });
      return;
    } else if (team1Players.isEmpty) {
      setState(() {
        errorMessage = 'Please add People to Team 1';
      });
      return;
    } else if (team2Players.isEmpty) {
      setState(() {
        errorMessage = 'Please add People to Team 2';
      });
      return;
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => StartedNewUnrankedGamePage(
            numberOfOvers: _overSelectValue.text,
            team1Players: team1Players,
            team2Players: team2Players,
          ),
        ),
      );
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Unranked Game',
          style: TextStyle(
              fontSize: 22, fontWeight: FontWeight.normal, color: Colors.black),
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
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 15),
            _entryField("Select Number of Overs", _overSelectValue),
            const SizedBox(height: 20),
            _entryFieldTeam("Add Team 1 Player", _controllerTeam1),
            const SizedBox(height: 10),
            _addToTeam1Button(),
            const SizedBox(height: 10),
            _entryFieldTeam("Add Team 2 Player", _controllerTeam2),
            const SizedBox(height: 10),
            _addToTeam2Button(),
            const SizedBox(height: 10),
            _errorMessage(),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Expanded(
                    child: _teamSection("Team 1", team1Players),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: _teamSection("Team 2", team2Players),
                  ),
                ],
              ),
            ),
            _startButton(),
          ],
        ),
      ),
    );
  }
}