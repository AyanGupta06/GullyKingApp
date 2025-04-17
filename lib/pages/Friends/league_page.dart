import 'dart:math';
import 'package:flutter/material.dart';
import 'package:gully_king/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gully_king/pages/Friends/friends_teams_page.dart';
import 'package:gully_king/pages/Friends/your_teams_page.dart';
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
  final TextEditingController _teamNameController = TextEditingController();
  final TextEditingController _inviteEmailController = TextEditingController();
  String? _selectedTeamId;
  bool _showCreateTeam = true;
  bool _showOutgoingInvites = true;
  int _selectedIndex = 3;

  Future<void> _createLeague() async {
    if (user == null || _teamNameController.text.trim().isEmpty) return;

    String leagueID = _generateUniqueCode();
    String leagueName = _teamNameController.text.trim();

    await FirebaseFirestore.instance.collection('teams').doc(leagueID).set({
      'leagueID': leagueID,
      'leagueName': _teamNameController.text.trim(),
      'players': [
        {'email': user!.email}
      ],
    });

    DocumentReference userRef = FirebaseFirestore.instance.collection('users').doc(user!.uid);
    await userRef.update({
      'teams': FieldValue.arrayUnion([leagueID]),
    });

    setState(() {
      _selectedTeamId = leagueID;
      _teamNameController.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("League created successfully!"), backgroundColor: Colors.green),
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
        const SnackBar(content: Text("User does not exist!"), backgroundColor: Colors.red),
      );
      return;
    }

    var inviteQuery = await FirebaseFirestore.instance
        .collection('team_invites')
        .where('to', isEqualTo: inviteEmail)
        .where('teamId', isEqualTo: _selectedTeamId)
        .where('status', whereIn: ['pending', 'accepted'])
        .limit(1)
        .get();

    if (inviteQuery.docs.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("This user has already been invited to the team."), backgroundColor: Colors.orange),
      );
      return;
    }

    DocumentSnapshot teamSnapshot =
    await FirebaseFirestore.instance.collection('teams').doc(_selectedTeamId).get();
    String teamName = teamSnapshot['teamName'];




    await FirebaseFirestore.instance.collection('team_invites').add({
      'from': user!.email,
      'to': inviteEmail,
      'teamId': _selectedTeamId,
      'teamName': teamName,
      'status': 'pending',
    });

    _inviteEmailController.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Invite sent successfully!"), backgroundColor: Colors.green),
    );
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
            child: Text("Create League", style: TextStyle(fontSize: 16)),
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
        _entryFieldTeam("Enter League Name", _teamNameController),
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
      onPressed: _createLeague,
      child: const Text("Create League"),
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
    String userEmail = user!.email!;

    DocumentReference teamRef = FirebaseFirestore.instance.collection('teams').doc(teamId);
    DocumentReference userRef = FirebaseFirestore.instance.collection('users').doc(user!.uid);

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      DocumentSnapshot teamSnapshot = await transaction.get(teamRef);
      DocumentSnapshot userSnapshot = await transaction.get(userRef);

      Map<String, dynamic> teamData = teamSnapshot.data() as Map<String, dynamic>? ?? {};
      Map<String, dynamic> userData = userSnapshot.data() as Map<String, dynamic>? ?? {};

      List<dynamic> teamPlayers = teamData['players'] != null ? List.from(teamData['players']) : [];

      List<dynamic> userTeams = userData['teams'] != null ? List.from(userData['teams']) : [];

      if (!teamPlayers.any((player) => player['email'] == userEmail)) {
        teamPlayers.add({'email': userEmail});
      }

      if (!userTeams.contains(teamId)) {
        userTeams.add(teamId);
      }

      transaction.update(teamRef, {'players': teamPlayers});
      transaction.update(userRef, {'teams': userTeams});

      await inviteDoc.reference.delete();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("You joined $teamName!"), backgroundColor: Colors.green),
    );
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
        "League Management",
        style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.black),
      ),
    );
  }

  Widget _userTeamsList() {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('users').doc(user!.uid).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const CircularProgressIndicator();

        List<dynamic> userTeams = snapshot.data!.get('teams') ?? [];

        if (userTeams.isEmpty) {
          return const Center(
            child: Text("You are not in any teams.", style: TextStyle(fontSize: 16, color: Colors.red)),
          );
        }

        return FutureBuilder<QuerySnapshot>(
          future: FirebaseFirestore.instance.collection('teams').where('teamId', whereIn: userTeams).get(),
          builder: (context, teamSnapshot) {
            if (!teamSnapshot.hasData) return const CircularProgressIndicator();

            var teams = teamSnapshot.data!.docs;

            return Column(
              children: teams.map((doc) {
                return Card(
                  elevation: 3,
                  margin: const EdgeInsets.symmetric(vertical: 5),
                  child: ListTile(
                    title: Text(doc['teamName'], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    subtitle: Text("Team ID: ${doc['teamId']}", style: const TextStyle(fontSize: 14, color: Colors.grey)),
                    trailing: const Icon(Icons.arrow_forward_ios, color: Colors.black),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TeamsProfilePage(
                            teamId: doc['teamId'],
                            teamName: doc['teamName'],
                          ),
                        ),
                      );
                    },
                  ),
                );
              }).toList(),
            );
          },
        );
      },
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
            _title(),
            const SizedBox(height: 20),
            _toggleView(),
            if (_showCreateTeam) ...[
              _teamCreationSection(),
              const SizedBox(height: 20),
              const Text("Your Leagues", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              _userTeamsList(),
            ] else ...[
              _teamInviteSection(),
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

