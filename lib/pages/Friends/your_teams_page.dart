import 'package:flutter/material.dart';
import 'package:gully_king/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gully_king/pages/Friends/friends_profile_page.dart';

import '../home_page.dart';
import '../New Game/new_game_page.dart';
import '../new_profile_page.dart';
import '../Friends/friends_teams_page.dart';

class TeamsProfilePage extends StatefulWidget {
  final String teamId;
  final String teamName;

  const TeamsProfilePage({super.key, required this.teamId, required this.teamName});

  @override
  State<TeamsProfilePage> createState() => _TeamsProfilePageState();
}

class _TeamsProfilePageState extends State<TeamsProfilePage> {
  final User? user = Auth().currentUser;
  List<dynamic> players = [];
  bool isCreator = false;
  int _selectedIndex = 3;
  String username = "";

  @override
  void initState() {
    super.initState();
    _fetchTeamPlayers();
  }

  

  Future<void> _fetchTeamPlayers() async {
    DocumentSnapshot teamSnapshot = await FirebaseFirestore.instance.collection('teams').doc(widget.teamId).get();

    if (teamSnapshot.exists) {
      Map<String, dynamic> teamData = teamSnapshot.data() as Map<String, dynamic>? ?? {};
      List<dynamic> teamPlayers = teamData.containsKey('players') ? List.from(teamData['players']) : [];

      setState(() {
        players = teamPlayers;
        isCreator = teamPlayers.isNotEmpty && teamPlayers.first['email'] == user!.email;
      });
    }
  }


  Future<void> _removePlayer(String playerEmail) async {
    DocumentReference teamRef = FirebaseFirestore.instance.collection('teams').doc(widget.teamId);

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      DocumentSnapshot teamSnapshot = await transaction.get(teamRef);

      if (!teamSnapshot.exists) return;

      List<dynamic> teamPlayers = List.from(teamSnapshot['players']);
      teamPlayers.removeWhere((player) => player['email'] == playerEmail);

      transaction.update(teamRef, {'players': teamPlayers});

      QuerySnapshot userQuery = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: playerEmail)
          .limit(1)
          .get();

      if (userQuery.docs.isNotEmpty) {
        DocumentReference userRef = userQuery.docs.first.reference;
        transaction.update(userRef, {
          'teams': FieldValue.arrayRemove([widget.teamId])
        });
      }
    });

    _fetchTeamPlayers(); 

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Player removed successfully!"), backgroundColor: Colors.red),
    );
  }

  Widget _teamPlayersList() {
    return players.isEmpty
        ? const Center(child: Text("No players in this team.", style: TextStyle(fontSize: 16, color: Colors.grey)))
        : ListView.builder(
            itemCount: players.length,
            shrinkWrap: true,
            itemBuilder: (context, index) {
              String playerEmail = players[index]['email'];

              return FutureBuilder<QuerySnapshot>(
                future: FirebaseFirestore.instance
                    .collection('users')
                    .where('email', isEqualTo: playerEmail)
                    .limit(1)
                    .get(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Card(
                      elevation: 3,
                      margin: const EdgeInsets.symmetric(vertical: 5),
                      child: ListTile(
                        title: const Text("Unknown"),
                        subtitle: Text(playerEmail, style: const TextStyle(fontSize: 14, color: Colors.grey)),
                      ),
                    );
                  }

                  var userData = snapshot.data!.docs.first.data() as Map<String, dynamic>;
                  String playerName = userData['username'] ?? "Unknown";

                  return Card(
                    elevation: 3,
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    child: ListTile(
                      title: Text(playerName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      subtitle: Text(playerEmail, style: const TextStyle(fontSize: 14, color: Colors.grey)),
                      leading: isCreator && playerEmail != user!.email
                          ? IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _removePlayer(playerEmail),
                            )
                          : null,
                      trailing: playerEmail != user!.email
                          ? IconButton(
                              icon: const Icon(Icons.arrow_forward_ios, color: Colors.black),
                              onPressed: () {
                                //add functionality here
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => FriendsProfilePage(friendEmail: playerEmail)),
                                );
                              },
                            )
                          : null,
                      
                    ),
                  );
                },
              );
            },
          );
  }

  



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.teamName),
        backgroundColor: const Color.fromRGBO(53, 150, 207, 1),
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(image: AssetImage('assets/bg4.png'), fit: BoxFit.cover),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          children: [
            const SizedBox(height: 20),
            const Text("Team Players", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Expanded(child: _teamPlayersList()),
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

  void _navigateToPage(int index) {
    switch (index) {
      case 0:
        Navigator.push(context, MaterialPageRoute(builder: (context) => const NewGamePage()));
        break;
      case 1:
        Navigator.push(context, MaterialPageRoute(builder: (context) => const NewProfilePage()));
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
    }
  }
}