import 'dart:math';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gully_king/pages/Friends/friends_teams_page.dart';
import 'package:gully_king/pages/Friends/league_details_page.dart';
import 'package:gully_king/pages/Previous%20Games/Previous%20Unranked%20Games/previous_games_page.dart';
import '../home_page.dart';
import '../New Game/new_game_page.dart';
import '../new_profile_page.dart';

class LeaguePage extends StatefulWidget {
  const LeaguePage({super.key});

  @override
  State<LeaguePage> createState() => _LeaguePageState();
}

class _LeaguePageState extends State<LeaguePage> {
  final User? user = FirebaseAuth.instance.currentUser;
  final TextEditingController _leagueNameController = TextEditingController();
  final TextEditingController _leagueOversController = TextEditingController();
  final TextEditingController _inviteTeamController = TextEditingController();
  String? _selectedLeagueId;
  bool _showCreateLeague = true;
  bool _showOutgoingInvites = true;
  int _selectedIndex = 3;

  Future<void> _createLeague() async {
    if (user == null || _leagueNameController.text.trim().isEmpty) return;

    String leagueID = _generateUniqueCode();
    String leagueName = _leagueNameController.text.trim();

    await FirebaseFirestore.instance.collection('leagues').doc(leagueID).set({
      'leagueID': leagueID,
      'leagueName': leagueName,
      'leagueOvers': _leagueOversController.text.trim(),
      'players': [user!.email],
      'creator': user!.email,
      'teams': [],
      'createdAt': FieldValue.serverTimestamp(),
    });

    setState(() {
      _leagueNameController.clear();
      _leagueOversController.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("League created successfully!"), backgroundColor: Colors.green),
    );
  }

  String _generateUniqueCode() {
    Random random = Random();
    return (100000 + random.nextInt(900000)).toString();
  }

  Future<void> _inviteTeam() async {
    if (_selectedLeagueId == null || _inviteTeamController.text.trim().isEmpty) return;

    String teamName = _inviteTeamController.text.trim();

    var teamQuery = await FirebaseFirestore.instance
        .collection('teams')
        .where('teamName', isEqualTo: teamName)
        .limit(1)
        .get();

    if (teamQuery.docs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Team does not exist!"), backgroundColor: Colors.red),
      );
      return;
    }

    var teamDoc = teamQuery.docs.first;
    String teamId = teamDoc.id;

    var inviteQuery = await FirebaseFirestore.instance
        .collection('league_invites')
        .where('leagueId', isEqualTo: _selectedLeagueId)
        .where('teamId', isEqualTo: teamId)
        .where('status', isEqualTo: 'pending')
        .limit(1)
        .get();

    if (inviteQuery.docs.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("This team has already been invited to the league."), backgroundColor: Colors.orange),
      );
      return;
    }

    var leagueDoc = await FirebaseFirestore.instance.collection('leagues').doc(_selectedLeagueId).get();
    String leagueName = leagueDoc['leagueName'];

    await FirebaseFirestore.instance.collection('league_invites').add({
      'leagueId': _selectedLeagueId,
      'leagueName': leagueName,
      'teamId': teamId,
      'teamName': teamName,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
      'inviterEmail': user!.email,
    });

    _inviteTeamController.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Invite sent successfully!"), backgroundColor: Colors.green),
    );
  }

  Future<void> _acceptInvite(DocumentSnapshot inviteDoc) async {
    String leagueId = inviteDoc['leagueId'];
    String leagueName = inviteDoc['leagueName'];
    String teamId = inviteDoc['teamId'];

    DocumentSnapshot teamDoc = await FirebaseFirestore.instance
        .collection('teams')
        .doc(teamId)
        .get();

    if (!teamDoc.exists) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Team no longer exists!"), backgroundColor: Colors.red),
      );
      await inviteDoc.reference.delete();
      return;
    }

    List<dynamic> teamPlayers = teamDoc['players'] ?? [];
    List<String> playerEmails = teamPlayers
        .where((player) => player['email'] != null)
        .map((player) => player['email'].toString())
        .toList();

    if (playerEmails.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Team has no players!"), backgroundColor: Colors.red),
      );
      return;
    }

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      DocumentSnapshot leagueSnapshot = await transaction.get(
        FirebaseFirestore.instance.collection('leagues').doc(leagueId),
      );

      List<dynamic> currentTeams = leagueSnapshot['teams'] ?? [];
      List<dynamic> currentPlayers = leagueSnapshot['players'] ?? [];

      if (!currentTeams.contains(teamId)) {
        currentTeams.add(teamId);
      }

      for (String email in playerEmails) {
        if (!currentPlayers.contains(email)) {
          currentPlayers.add(email);
        }
      }

      transaction.update(
        FirebaseFirestore.instance.collection('leagues').doc(leagueId),
        {
          'teams': currentTeams,
          'players': currentPlayers,
        },
      );
    });

    await inviteDoc.reference.delete();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Team and all players added to $leagueName!"), backgroundColor: Colors.green),
    );
  }

  Widget _leagueSelection() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('leagues')
          .where('players', arrayContains: user!.email)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const CircularProgressIndicator();
        var leagues = snapshot.data!.docs;

        return DropdownButton<String>(
          value: _selectedLeagueId,
          hint: const Text("Select a League"),
          isExpanded: true,
          items: leagues.map((doc) {
            return DropdownMenuItem<String>(
              value: doc['leagueID'],
              child: Text(doc['leagueName']),
            );
          }).toList(),
          onChanged: (String? leagueId) {
            setState(() {
              _selectedLeagueId = leagueId;
            });
          },
        );
      },
    );
  }

  Widget _inviteListSection() {
    if (_showOutgoingInvites) {
      return StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('league_invites')
            .where('inviterEmail', isEqualTo: user!.email)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const CircularProgressIndicator();
          if (snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text("No outgoing invites", style: TextStyle(fontSize: 16)),
            );
          }

          var invites = snapshot.data!.docs;
          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: invites.length,
            itemBuilder: (context, index) {
              var doc = invites[index];
              return Card(
                child: ListTile(
                  title: Text(doc['teamName']),
                  subtitle: Text("Invited to ${doc['leagueName']}"),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => doc.reference.delete(),
                  ),
                ),
              );
            },
          );
        },
      );
    } else {
      return StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('league_invites').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const CircularProgressIndicator();

          return FutureBuilder<List<DocumentSnapshot>>(
            future: _filterTeamInvites(snapshot.data!.docs),
            builder: (context, filteredSnapshot) {
              if (!filteredSnapshot.hasData) return const CircularProgressIndicator();
              if (filteredSnapshot.data!.isEmpty) {
                return const Center(
                  child: Text("No incoming invites", style: TextStyle(fontSize: 16)),
                );
              }

              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filteredSnapshot.data!.length,
                itemBuilder: (context, index) {
                  var doc = filteredSnapshot.data![index];
                  return Card(
                    child: ListTile(
                      title: Text("${doc['leagueName']} invites ${doc['teamName']}"),
                      subtitle: const Text("Status: Pending"),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.check, color: Colors.green),
                            onPressed: () => _acceptInvite(doc),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.red),
                            onPressed: () => doc.reference.delete(),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      );
    }
  }

  Future<List<DocumentSnapshot>> _filterTeamInvites(List<DocumentSnapshot> invites) async {
    List<DocumentSnapshot> filteredInvites = [];
    
    for (var invite in invites) {
      var teamDoc = await FirebaseFirestore.instance
          .collection('teams')
          .doc(invite['teamId'])
          .get();
      
      var players = teamDoc['players'] as List;
      if (players.isNotEmpty && players.first['email'] == user!.email) {
        filteredInvites.add(invite);
      }
    }
    
    return filteredInvites;
  }

  Widget _userTeamsList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('leagues')
          .where('players', arrayContains: user!.email)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const CircularProgressIndicator();

        var leagues = snapshot.data!.docs;
        
        if (leagues.isEmpty) {
          return const Center(
            child: Text("You are not in any leagues.", 
                style: TextStyle(fontSize: 16, color: Colors.red)),
          );
        }

        return Expanded(
          child: ListView.builder(
            shrinkWrap: true,
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: leagues.length,
            itemBuilder: (context, index) {
              var doc = leagues[index];
              return Card(
                elevation: 3,
                margin: const EdgeInsets.symmetric(vertical: 5),
                child: ListTile(
                  title: Text(doc['leagueName'], 
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  subtitle: Text("League ID: ${doc['leagueID']}", 
                      style: const TextStyle(fontSize: 14, color: Colors.grey)),
                  trailing: const Icon(Icons.arrow_forward_ios, color: Colors.black),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LeagueDetailsPage(
                          leagueId: doc['leagueID'],
                          leagueName: doc['leagueName'],
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        );
      },
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
        prefixIcon: const Icon(Icons.people_alt_sharp, color: Colors.blueAccent),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20.0),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  void _navigateToPage(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.push(context, MaterialPageRoute(builder: (context) => const NewGamePage()));
        break;
      case 1:
        Navigator.push(context, MaterialPageRoute(builder: (context) => const PreviousGamesPage()));
        break;
      case 2:
        Navigator.push(context, MaterialPageRoute(builder: (context) => HomePage()));
        break;
      case 3:
        Navigator.push(context, MaterialPageRoute(builder: (context) => const FriendsTeamsPage()));
        break;
      case 4:
        Navigator.push(context, MaterialPageRoute(builder: (context) => const NewProfilePage()));
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Transform.rotate(
          angle: 0,
          child: Tooltip(
            message: "Friends/Teams",
            child: IconButton(
              icon: const Icon(Icons.people_alt_sharp),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const FriendsTeamsPage()),
                );
              },
            ),
          ),
        ),
        title: const Text(
            "League Management",
            style: TextStyle(fontSize: 22, fontWeight:FontWeight.normal, color: Colors.black)
        ),
        backgroundColor: const Color.fromRGBO(53, 150, 207, 1),
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(image: AssetImage('assets/bg4.png'), fit: BoxFit.cover),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          children: [
            const SizedBox(height: 20),
            const Text(
              "League Management",
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.black),
            ),
            const SizedBox(height: 20),
            ToggleButtons(
              isSelected: [_showCreateLeague, !_showCreateLeague],
              onPressed: (index) {
                setState(() {
                  _showCreateLeague = index == 0;
                });
              },
              borderRadius: BorderRadius.circular(10),
              selectedColor: Colors.white,
              color: Colors.black,
              fillColor: Colors.blue,
              borderWidth: 2,
              borderColor: Colors.blue,
              selectedBorderColor: Colors.blue,
              children: const [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text("Create League", style: TextStyle(fontSize: 16)),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text("Invite Teams", style: TextStyle(fontSize: 16)),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (_showCreateLeague) ...[
              _entryFieldTeam("Enter League Name", _leagueNameController),
              const SizedBox(height: 10),
              _entryFieldTeam("Enter Number of Overs", _leagueOversController),
              const SizedBox(height: 10),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                ),
                onPressed: () {
                  if (_leagueOversController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Please enter the league overs")),
                    );
                  } 
                  else if (double.tryParse(_leagueOversController.text) == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Please enter a valid number for the overs")),
                    );
                  } else {
                    _createLeague();
                  }
                },
                child: const Text("Create League"),
              ),
              const SizedBox(height: 20),
              const Text("Your Leagues", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              _userTeamsList(),
            ] else ...[
              _leagueSelection(),
              const SizedBox(height: 10),
              _entryFieldTeam("Enter Team Name", _inviteTeamController),
              const SizedBox(height: 10),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                ),
                onPressed: _inviteTeam,
                child: const Text("Send Invite"),
              ),
              const SizedBox(height: 10),
              ToggleButtons(
                isSelected: [_showOutgoingInvites, !_showOutgoingInvites],
                onPressed: (index) {
                  setState(() {
                    _showOutgoingInvites = index == 0;
                  });
                },
                borderRadius: BorderRadius.circular(10),
                selectedColor: Colors.white,
                color: Colors.black,
                fillColor: Colors.blue,
                borderWidth: 2,
                borderColor: Colors.blue,
                selectedBorderColor: Colors.blue,
                children: const [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text("Outgoing Invites", style: TextStyle(fontSize: 16)),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text("Incoming Invites", style: TextStyle(fontSize: 16)),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Expanded(child: _inviteListSection()),
            ],
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