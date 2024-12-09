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

class NewUnrankedGamePage extends StatefulWidget {
  const NewUnrankedGamePage({super.key});

  @override
  State<NewUnrankedGamePage> createState() => _NewUnrankedGamePageState();
}

class _NewUnrankedGamePageState extends State<NewUnrankedGamePage> {
  int _selectedIndex = 0; // Default home index
  final TextEditingController _overSelectValue = TextEditingController();
  final TextEditingController _controllerTeam1 = TextEditingController();
  final TextEditingController _controllerTeam2 = TextEditingController();

  final User? user = Auth().currentUser;
  String? errorMessage = '';

  List<String> team1Players = [];
  List<String> team2Players = [];

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
      case 0: //new game
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const NewGamePage()),
        );
        break;
      case 1: //old games
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
    if(playerName.isNotEmpty) {
      setState(() {
        team1Players.add(playerName);
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
    if(playerName.isNotEmpty) {
      setState(() {
        team2Players.add(playerName);
        _controllerTeam2.clear(); 
      });
    }
  }

  Widget _teamSection(String teamName, List<String> players) {
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
                      player,
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

   void _validateAndStart () {
    setState(() {
      errorMessage = '';
    });

    if (_overSelectValue.text.isEmpty) {
      setState(() {
        errorMessage = 'Please fill this field: Number of Overs';
      });
      return;
    } 
     else if (team1Players.isEmpty) {
      setState(() {
        errorMessage = 'Please add People to Team 1';
      });
      return;
    }

     else if (team2Players.isEmpty) {
      setState(() {
        errorMessage = 'Please add People to Team 2';
      });
      return;
    }
    
    else {
      Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => StartedNewUnrankedGamePage(
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
          style: TextStyle(fontSize: 22, fontWeight:FontWeight.normal, color: Colors.black)
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
                _entryField("Enter Number of Overs", _overSelectValue),
                const SizedBox(height: 15),
                _entryFieldTeam("Add Players to Team 1", _controllerTeam1),
                const SizedBox(height: 15),
                _addToTeam1Button(),
                const SizedBox(height: 15),
                _entryFieldTeam("Add Players to Team 2", _controllerTeam2),
                const SizedBox(height: 15),
                _addToTeam2Button(),
                const SizedBox(height: 15),
                Expanded(
                  child: Scrollbar(
                    thumbVisibility: true, 
                    thickness: 6.0, 
                    radius: const Radius.circular(10.0), 
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _teamSection("Team 1", team1Players),
                          const SizedBox(height: 20),
                          _teamSection("Team 2", team2Players),
                        ],
                      ),
                    ),
                  ),
                ),

                _errorMessage(),
                const SizedBox(height: 15),
                _startButton(),
              ],
            ),
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