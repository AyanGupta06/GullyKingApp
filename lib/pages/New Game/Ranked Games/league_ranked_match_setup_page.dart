import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gully_king/pages/New%20Game/Ranked%20Games/coin_flip_page.dart';

class LeagueRankedMatchSetupPage extends StatefulWidget {
  final String? team1Id;
  final String? team2Id;
  final String? leagueId;
    final String? matchId; 

  const LeagueRankedMatchSetupPage({
    Key? key,
    this.team1Id,
    this.team2Id,
    this.leagueId,
    this.matchId,
  }) : super(key: key);

  @override
  _LeagueRankedMatchSetupPageState createState() => _LeagueRankedMatchSetupPageState();
}

class _LeagueRankedMatchSetupPageState extends State<LeagueRankedMatchSetupPage> {
  final User? user = FirebaseAuth.instance.currentUser;
  final TextEditingController opponentTeamCodeController = TextEditingController();
  final TextEditingController oversController = TextEditingController();

  bool isPreselected = false;
  List<String> userTeams = [];
  String? selectedTeamId;
  String? opponentTeamId;
  Map<String, String> teamPlayers = {};
  Map<String, String> opponentPlayers = {};
  List<String> selectedPlayers = [];
  List<String> selectedOpponentPlayers = [];

  @override
  void initState() {
    super.initState();
    isPreselected = widget.team1Id != null && widget.team2Id != null;
    if (isPreselected) {
      _initializePreselectedTeams();
    } else {
      _fetchUserTeams();
    }
  }

  Future<void> _initializePreselectedTeams() async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .get();
      
      List<String> userTeams = List<String>.from(userDoc['teams'] ?? []);

      if (userTeams.contains(widget.team1Id)) {
        selectedTeamId = widget.team1Id;
        opponentTeamId = widget.team2Id;
      } else {
        selectedTeamId = widget.team2Id;
        opponentTeamId = widget.team1Id;
      }

      await Future.wait([
        _fetchTeamPlayers(selectedTeamId!),
        _fetchOpponentPlayers(),
      ]);
    } catch (e) {
      _showError("Failed to initialize match: $e");
    }
  }

  Future<void> _fetchUserTeams() async {
    if (user == null) return;
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .get();
      
      setState(() {
        userTeams = List<String>.from(userDoc['teams'] ?? []);
        if (userTeams.isNotEmpty) {
          selectedTeamId = userTeams.first;
          _fetchTeamPlayers(selectedTeamId!);
        }
      });
    } catch (e) {
      _showError("Error fetching user teams: $e");
    }
  }

  Future<void> _fetchTeamPlayers(String teamId) async {
    try {
      DocumentSnapshot teamDoc = await FirebaseFirestore.instance
          .collection('teams')
          .doc(teamId)
          .get();

      if (teamDoc.exists) {
        List<dynamic> playersList = teamDoc['players'] ?? [];
        
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
          QuerySnapshot userQuery = await FirebaseFirestore.instance
              .collection('users')
              .where('email', isEqualTo: email)
              .limit(1)
              .get();
          if (userQuery.docs.isNotEmpty) {
            playerMap[email] = userQuery.docs.first['username'] ?? email;
          }
        }

        setState(() {
          teamPlayers = playerMap;
          if (user != null && playerMap.containsKey(user!.email)) {
            selectedPlayers = [user!.email!];
          }
        });
      }
    } catch (e) {
      _showError("Error fetching team players: $e");
    }
  }

  Future<void> _fetchOpponentPlayers() async {
    try {
      if (opponentTeamId == null) return;

      DocumentSnapshot teamDoc = await FirebaseFirestore.instance
          .collection('teams')
          .doc(opponentTeamId)
          .get();

      if (teamDoc.exists) {
        List<dynamic> playersList = teamDoc['players'] ?? [];
        
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
          QuerySnapshot userQuery = await FirebaseFirestore.instance
              .collection('users')
              .where('email', isEqualTo: email)
              .limit(1)
              .get();
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
      _showError("Failed to fetch opponent team: $e");
    }
  }

  void _togglePlayerSelection(String email, bool isOpponent) {
    setState(() {
      if (isOpponent) {
        if (selectedOpponentPlayers.contains(email)) {
          selectedOpponentPlayers.remove(email);
        } else {
          if (!selectedPlayers.contains(email)) {
            selectedOpponentPlayers.add(email);
          }
        }
      } else {
        if (selectedPlayers.contains(email)) {
          selectedPlayers.remove(email);
        } else {
          if (!selectedOpponentPlayers.contains(email)) {
            selectedPlayers.add(email);
          }
        }
      }
    });
  }

  void _validateAndProceed() {
    if (selectedPlayers.isEmpty || selectedOpponentPlayers.isEmpty) {
      _showError("Both teams must have at least 1 player.");
      return;
    }
    _showOversSelectionDialog(context);
  }

  void _showOversSelectionDialog(BuildContext context) {
    int selectedOvers = 5;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Select Number of Overs"),
          content: DropdownButton<int>(
            value: selectedOvers,
            items: [1, 2, 3, 4, 5, 10, 12, 15, 20].map((int value) {
              return DropdownMenuItem<int>(
                value: value,
                child: Text("$value Overs"),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                selectedOvers = value!;
              });
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CoinFlipPage(
                      yourTeam: selectedPlayers,
                      opponentTeam: selectedOpponentPlayers,
                      yourTeamID: selectedTeamId!,
                      opponentTeamID: opponentTeamId!,
                      overs: selectedOvers,
                      leagueMatch: true,
                    ),
                  ),
                );
              },
              child: const Text("Confirm"),
            ),
          ],
        );
      },
    );
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
          image: DecorationImage(
            image: AssetImage('assets/bg4.png'),
            fit: BoxFit.cover,
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
                          const SizedBox(height: 30),

            if (!isPreselected) ...[
              const Text("Select Your Team:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              DropdownButton<String>(
                value: selectedTeamId,
                items: userTeams.map((teamId) {
                  return DropdownMenuItem<String>(
                    value: teamId,
                    child: FutureBuilder<DocumentSnapshot>(
                      future: FirebaseFirestore.instance.collection('teams').doc(teamId).get(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return Text(snapshot.data!['teamName'] ?? teamId);
                        }
                        return Text(teamId);
                      },
                    ),
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
            ] else ...[
              FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance.collection('teams').doc(selectedTeamId).get(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Text(
                      "Your Team: ${snapshot.data!['teamName']}",
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    );
                  }
                  return const Text("Loading team...", style: TextStyle(fontSize: 18));
                },
              ),
            ],

            const Text("Select Players:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Expanded(
              child: ListView(
                children: teamPlayers.entries.map((entry) {
                  bool isCurrentUser = entry.key == user!.email;
                  return CheckboxListTile(
                    title: Text(entry.value),
                    value: selectedPlayers.contains(entry.key),
                    onChanged: isCurrentUser
                        ? null
                        : selectedOpponentPlayers.contains(entry.key)
                            ? null
                            : (bool? value) {
                                _togglePlayerSelection(entry.key, false);
                              },
                    controlAffinity: ListTileControlAffinity.leading,
                  );
                }).toList(),
              ),
            ),

            if (!isPreselected) ...[
              const Text("Enter Opponent Team Code:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              TextField(
                controller: opponentTeamCodeController,
                decoration: const InputDecoration(
                  hintText: "6-digit unique code",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  if (opponentTeamCodeController.text.length == 6) {
                    setState(() {
                      opponentTeamId = opponentTeamCodeController.text;
                    });
                    _fetchOpponentPlayers();
                  } else {
                    _showError("Team code must be 6 characters long.");
                  }
                },
                child: const Text("Fetch Opponent Team"),
              ),
            ] else ...[
              FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance.collection('teams').doc(opponentTeamId).get(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Text(
                      "Opponent Team: ${snapshot.data!['teamName']}",
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    );
                  }
                  return const Text("Loading opponent team...", style: TextStyle(fontSize: 18));
                },
              ),
            ],

            if (opponentTeamId != null) ...[
              const SizedBox(height: 10),
              Expanded(
                child: ListView(
                  children: opponentPlayers.entries.map((entry) {
                    return CheckboxListTile(
                      title: Text(entry.value),
                      value: selectedOpponentPlayers.contains(entry.key),
                      onChanged: selectedPlayers.contains(entry.key)
                          ? null
                          : (bool? value) {
                              _togglePlayerSelection(entry.key, true);
                            },
                      controlAffinity: ListTileControlAffinity.leading,
                    );
                  }).toList(),
                ),
              ),
            ],

            Center(child: ElevatedButton(onPressed: _validateAndProceed, child: const Text("Next"))),
          ],
        ),
      ),
    );
  }
}