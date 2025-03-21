import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RankedMatchSetupPage extends StatefulWidget {
  @override
  _RankedMatchSetupPageState createState() => _RankedMatchSetupPageState();
}

class _RankedMatchSetupPageState extends State<RankedMatchSetupPage> {
  final User? user = FirebaseAuth.instance.currentUser;
  List<String> userTeams = [];
  String? selectedTeamId;
  Map<String, String> teamPlayers = {}; // email -> username
  List<String> selectedPlayers = [];

  String? opponentTeamId;
  Map<String, String> opponentPlayers = {};
  List<String> selectedOpponentPlayers = [];

  final TextEditingController opponentTeamCodeController = TextEditingController();
  final TextEditingController oversController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchUserTeams();
  }

  Future<void> _fetchUserTeams() async {
    if (user == null) return;
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(user!.uid).get();
      List<dynamic> teams = userDoc['teams'] ?? [];

      setState(() {
        userTeams = List<String>.from(teams);
        if (userTeams.isNotEmpty) {
          selectedTeamId = userTeams.first;
          _fetchTeamPlayers(selectedTeamId!);
        }
      });
    } catch (e) {
      print("Error fetching user teams: $e");
    }
  }

  Future<void> _fetchTeamPlayers(String teamId) async {
    try {
      DocumentSnapshot teamDoc = await FirebaseFirestore.instance.collection('teams').doc(teamId).get();

      if (teamDoc.exists) {
        List<dynamic> playersList = teamDoc['players'] ?? [];
        
        // Extract only emails (if stored as maps)
        List<String> playerEmails = [];
        for (var player in playersList) {
          if (player is String) {
            playerEmails.add(player);
          } else if (player is Map<String, dynamic> && player.containsKey('email')) {
            playerEmails.add(player['email']);
          }
        }

        Map<String, String> playerMap = {};
        for (String email in playerEmails) {
          QuerySnapshot userQuery = await FirebaseFirestore.instance.collection('users').where('email', isEqualTo: email).limit(1).get();
          if (userQuery.docs.isNotEmpty) {
            playerMap[email] = userQuery.docs.first['username'] ?? email;
          }
        }

        setState(() {
          teamPlayers = playerMap;
          selectedPlayers = [user!.email!]; // Auto-select the user
        });
      }
    } catch (e) {
      print("Error fetching team players: $e");
    }
  }


  Future<void> _fetchOpponentPlayers() async {
    try {
      if (opponentTeamId == null) return;

      DocumentSnapshot teamDoc = await FirebaseFirestore.instance.collection('teams').doc(opponentTeamId).get();

      if (teamDoc.exists) {
        List<dynamic> playersList = teamDoc['players'] ?? [];
        
        // Extract only emails (if stored as maps)
        List<String> playerEmails = [];
        for (var player in playersList) {
          if (player is String) {
            playerEmails.add(player);
          } else if (player is Map<String, dynamic> && player.containsKey('email')) {
            playerEmails.add(player['email']);
          }
        }

        Map<String, String> playerMap = {};
        for (String email in playerEmails) {
          QuerySnapshot userQuery = await FirebaseFirestore.instance.collection('users').where('email', isEqualTo: email).limit(1).get();
          if (userQuery.docs.isNotEmpty) {
            playerMap[email] = userQuery.docs.first['username'] ?? email;
          }
        }

        setState(() {
          opponentPlayers = playerMap;
          selectedOpponentPlayers.clear();
        });
      } else {
        _showError("Opponent team not found.");
      }
    } catch (e) {
      print("Error fetching opponent players: $e");
      _showError("Failed to fetch opponent team.");
    }
  }


  void _togglePlayerSelection(String player, bool isOpponent) {
    setState(() {
      if (isOpponent) {
        if (selectedPlayers.contains(player)) return; // Prevent duplicate selection
        selectedOpponentPlayers.contains(player)
            ? selectedOpponentPlayers.remove(player)
            : selectedOpponentPlayers.add(player);
      } else {
        selectedPlayers.contains(player)
            ? selectedPlayers.remove(player)
            : selectedPlayers.add(player);
      }
    });
  }

  void _validateAndProceed() {
    if (selectedPlayers.length < 2 || selectedOpponentPlayers.length < 2) {
      _showError("Both teams must have at least 2 players.");
      return;
    }
    if (selectedPlayers.length != selectedOpponentPlayers.length) {
      _showError("Both teams must have the same number of players.");
      return;
    }
    _showOversSelectionDialog();
  }

  void _showOversSelectionDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Enter Overs per Innings"),
          content: TextField(
            controller: oversController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(hintText: "Enter number of overs"),
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (oversController.text.isEmpty || int.tryParse(oversController.text) == null) {
                  _showError("Please enter a valid number of overs.");
                  return;
                }
                Navigator.pop(context);
                _startRankedMatch();
              },
              child: const Text("Confirm"),
            ),
          ],
        );
      },
    );
  }

  void _startRankedMatch() {
    print("Ranked Match Started!");
    print("Team 1: $selectedPlayers");
    print("Team 2: $selectedOpponentPlayers");
    print("Overs: ${oversController.text}");
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Ranked Match Setup"),
        backgroundColor: Colors.blue,
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(image: AssetImage('assets/bg4.png'), fit: BoxFit.cover),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Select Your Team:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            DropdownButton<String>(
              value: selectedTeamId,
              items: userTeams.map((teamId) {
                return DropdownMenuItem<String>(
                  value: teamId,
                  child: Text(teamId),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    selectedTeamId = value;
                  });
                  _fetchTeamPlayers(value);
                }
              },
            ),
            const SizedBox(height: 10),
            const Text("Select Players:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Expanded(
              child: ListView(
                children: teamPlayers.entries.map((entry) {
                  return CheckboxListTile(
                    title: Text(entry.value), // Show username instead of email
                    value: selectedPlayers.contains(entry.key),
                    onChanged: entry.key == user!.email ? null : (bool? value) {
                      _togglePlayerSelection(entry.key, false);
                    },
                  );
                }).toList(),
              ),
            ),

            const Text("Enter Opponent Team Code:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            TextField(
              controller: opponentTeamCodeController,
              decoration: const InputDecoration(hintText: "6-digit unique code"),
            ),
            ElevatedButton(
              onPressed: () {
                if (opponentTeamCodeController.text.length == 6) {
                  setState(() {
                    opponentTeamId = opponentTeamCodeController.text;
                  });
                  _fetchOpponentPlayers();
                } else {
                  _showError("Invalid team code.");
                }
              },
              child: const Text("Fetch Opponent Team"),
            ),
            Expanded(
              child: ListView(
                children: opponentPlayers.entries.map((entry) {
                  return CheckboxListTile(
                    title: Text(entry.value), // Show username instead of email
                    value: selectedOpponentPlayers.contains(entry.key),
                    onChanged: (bool? value) {
                      _togglePlayerSelection(entry.key, true);
                    },
                  );
                }).toList(),
              ),
            ),

            Center(child: ElevatedButton(onPressed: _validateAndProceed, child: const Text("Next"))),
          ],
        ),
      ),
    );
  }
}
