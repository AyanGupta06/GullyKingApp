import 'dart:math';
import 'package:flutter/material.dart';
import 'package:gully_king/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gully_king/pages/Friends/friends_teams_page.dart';
import 'package:gully_king/pages/Previous%20Games/Previous%20Unranked%20Games/previous_games_page.dart';

import '../home_page.dart';
import '../New Game/new_game_page.dart';
import '../new_profile_page.dart';

class TeamManagementPage extends StatefulWidget {
  const TeamManagementPage({super.key});

  @override
  State<TeamManagementPage> createState() => _TeamManagementPageState();
}

class _TeamManagementPageState extends State<TeamManagementPage> {
  final User? user = FirebaseAuth.instance.currentUser;
  final TextEditingController _teamNameController = TextEditingController();
  final TextEditingController _inviteEmailController = TextEditingController();
  String? _selectedTeamId;
  bool _showCreateTeam = true;
  bool _showOutgoingInvites = true;
  int _selectedIndex = 3;

  Future<void> _createTeam() async {
    if (user == null || _teamNameController.text.trim().isEmpty) return;

    String teamId = _generateUniqueCode();
    String teamName = _teamNameController.text.trim();
    DocumentReference teamRef = FirebaseFirestore.instance.collection('teams').doc(teamId);

    await teamRef.set({
      'teamId': teamId,
      'teamName': _teamNameController.text.trim(),
      'players': [
        {'email': user!.email}
      ],
    });

    setState(() {
      _selectedTeamId = teamId;
      _teamNameController.clear();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Team '$teamName' created successfully!"),
        backgroundColor: Colors.green,
      ),
    );
  }

  String _generateUniqueCode() {
    Random random = Random();
    return (100000 + random.nextInt(900000)).toString();
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
          MaterialPageRoute(builder: (context) => const PreviousGamesPage()),
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


  Future<void> _invitePlayer() async {
    if (_selectedTeamId == null || _inviteEmailController.text.trim().isEmpty) return;

    String inviteEmail = _inviteEmailController.text.trim();

    var userQuery = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: inviteEmail)
        .limit(1)
        .get();

    if (userQuery.docs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("User does not exist!"),
          backgroundColor: Colors.red,
        ),
      );
      return; 
    }

    DocumentSnapshot teamSnapshot =
        await FirebaseFirestore.instance.collection('teams').doc(_selectedTeamId).get();
    String teamName = teamSnapshot['teamName'];

    await FirebaseFirestore.instance.collection('team_invites').add({
      'from': user!.email,
      'to': _inviteEmailController.text.trim(),
      'teamId': _selectedTeamId,
      'teamName': teamName,
      'status': 'pending',
    });

    _inviteEmailController.clear();
  }

  Widget _toggleView() {
    return Center(
      child: ToggleButtons(
        isSelected: [_showCreateTeam, !_showCreateTeam],
        onPressed: (index) {
          setState(() {
            _showCreateTeam = index == 0;
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
            child: Text("Create Team", style: TextStyle(fontSize: 16)),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text("Invite Players", style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }

  Widget _teamCreationSection() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 20),
        _entryFieldTeam("Enter Team Name", _teamNameController),
        const SizedBox(height: 10),
        _submitButtonCreateTeams(),
        
      ],
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

  Widget _submitButtonCreateTeams() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blueAccent,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
      ),
      onPressed: _createTeam,
      child: const Text("Create Team"),
    );
  }

  Widget _teamSelection() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('teams').where('players', arrayContains: {'email': user!.email}).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const CircularProgressIndicator();
        var teams = snapshot.data!.docs;

        return DropdownButton<String>(
          value: _selectedTeamId,
          hint: const Text("Select a Team"),
          isExpanded: false,
          items: teams.map((doc) {
            return DropdownMenuItem<String>(
              value: doc.id,
              child: Text(doc['teamName']),
            );
          }).toList(),
          onChanged: (String? teamId) {
            setState(() {
              _selectedTeamId = teamId;
            });
          },
        );
      },
    );
  }

  Future<void> _acceptInvite(DocumentSnapshot inviteDoc) async {
    String teamId = inviteDoc['teamId'];
    String teamName = inviteDoc['teamName'];

    DocumentReference teamRef = FirebaseFirestore.instance.collection('teams').doc(teamId);
    DocumentSnapshot teamSnapshot = await teamRef.get();
    List<dynamic> players = teamSnapshot['players'] ?? [];

    players.add({'email': user!.email});

    await teamRef.update({'players': players});
    
    // await inviteDoc.reference.delete();

    // DocumentReference userRef = FirebaseFirestore.instance.collection('users').doc(user!.uid);
    // DocumentSnapshot userSnapshot = await userRef.get();
    // List<dynamic> teams = userSnapshot['teams'] ?? [];

    // teams.add({'teamNames': teamName});

    // await userRef.update({'teams': teams});
    await inviteDoc.reference.delete();
  }




  Widget _teamInviteSection() {
    return Column(
      children: [
        const SizedBox(height: 20),
        _teamSelection(),
        const SizedBox(height: 10),
        _entryFieldTeam("Enter Player Email", _inviteEmailController),
        const SizedBox(height: 10),
        _submitButton(),
        const SizedBox(height: 10),
        _toggleInviteView(),
        const SizedBox(height: 10),
        _inviteListSection(),
      ],
    );
  }

  Widget _submitButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blueAccent,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
      ),
      onPressed: _invitePlayer,
      child: const Text("Send Invite"),
    );
  }

  Widget _toggleInviteView() {
    return ToggleButtons(
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
    );
  }

  Widget _inviteListSection() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('team_invites')
          .where(_showOutgoingInvites ? 'from' : 'to', isEqualTo: user!.email)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Text(
            "No invites found",
            style: TextStyle(fontSize: 16, color: Colors.red),
            textAlign: TextAlign.center,
          );
        }

        var invites = snapshot.data!.docs;

        return Column(
          children: invites.map((doc) {
            String teamName = doc['teamName'];
            String invitee = doc['to']; 
            String inviter = doc['from']; 

            return Card(
              elevation: 3,
              margin: const EdgeInsets.symmetric(vertical: 5),
              child: ListTile(
                title: Text(teamName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                subtitle: Text(
                  _showOutgoingInvites ? "Invite for $invitee" : "Invited by $inviter",
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
                trailing: _showOutgoingInvites
                    ? IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          await doc.reference.delete();
                        },
                      )
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.check, color: Colors.green),
                            onPressed: () async {
                              await _acceptInvite(doc);
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.red),
                            onPressed: () async {
                              await doc.reference.delete();
                            },
                          ),
                        ],
                      ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _title() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Text(
        "Team Management",
        style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.black),
      ),
    );
  }

  Widget _teamsList() {
    return Expanded(
      child: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('users').doc(user!.uid).get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          Map<String, dynamic> userData = snapshot.data!.data() as Map<String, dynamic>? ?? {};
          List<dynamic> friends = userData.containsKey('friends') ? List.from(userData['friends']) : [];

          if (friends.isEmpty) {
            return const Center(
              child: Text(
                "You have no friends yet.",
                style: TextStyle(fontSize: 18, color: Colors.black),
              ),
            );
          }

          return ListView.builder(
            itemCount: friends.length,
            itemBuilder: (context, index) {
              String friendEmail = friends[index];

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance.collection('users').where('email', isEqualTo: friendEmail).limit(1).get().then((query) => query.docs.first),
                builder: (context, friendSnapshot) {
                  if (!friendSnapshot.hasData) return const SizedBox();

                  String friendName = friendSnapshot.data!['username'] ?? "Unknown";

                  return Card(
                    elevation: 3,
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    child: ListTile(
                      leading: const Icon(Icons.person, color: Colors.blue),
                      title: Text(friendName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      subtitle: Text(friendEmail, style: const TextStyle(fontSize: 14, color: Colors.grey)),
                      trailing: const Icon(Icons.arrow_forward_ios, color: Colors.black),
                      onTap: () {
                        //add functionality here
                       
                      },
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }


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
          "Team Management", 
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
            // const SizedBox(height: 40),
            // _title(),
            // const SizedBox(height: 40),
            _toggleView(),
            _showCreateTeam ? _teamCreationSection() : Column(
              children: [
                _teamInviteSection()]),
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
    
