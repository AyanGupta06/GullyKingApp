import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gully_king/pages/Previous%20Games/Previous%20Unranked%20Games/previous_games_page.dart';
import 'package:intl/intl.dart';
import 'package:gully_king/main.dart'; 
import 'package:gully_king/pages/Friends/friends_teams_page.dart';
import 'package:gully_king/pages/New%20Game/new_game_page.dart';
import 'package:gully_king/pages/Previous%20Games/all_previous_games_page.dart';
import 'package:gully_king/pages/home_page.dart';
import 'package:gully_king/pages/new_profile_page.dart';

class LeagueDetailsPage extends StatefulWidget {
  final String leagueId;
  final String leagueName;

  const LeagueDetailsPage({
    super.key,
    required this.leagueId,
    required this.leagueName,
  });

  @override
  State<LeagueDetailsPage> createState() => _LeagueDetailsPageState();
}

class _LeagueDetailsPageState extends State<LeagueDetailsPage> {
  String? _selectedTeam1;
  String? _selectedTeam2;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  int _selectedIndex = 3;  

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(DateTime.now().year + 1),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _scheduleMatch() async {
    if (_selectedTeam1 == null || _selectedTeam2 == null || _selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select both teams, date and time")),
      );
      return;
    }

    if (_selectedTeam1 == _selectedTeam2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select two different teams")),
      );
      return;
    }

    final scheduledDateTime = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );

    try {
      await FirebaseFirestore.instance.collection('scheduled_matches').add({
        'leagueId': widget.leagueId,
        'leagueName': widget.leagueName,
        'team1': _selectedTeam1,
        'team2': _selectedTeam2,
        'scheduledDateTime': scheduledDateTime,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Match scheduled successfully!"), backgroundColor: Colors.green),
      );

      setState(() {
        _selectedTeam1 = null;
        _selectedTeam2 = null;
        _selectedDate = null;
        _selectedTime = null;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error scheduling match: ${e.toString()}")),
      );
    }
  }

  Widget _buildTeamDropdown(bool isFirstTeam) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('leagues')
          .doc(widget.leagueId)
          .snapshots(),
      builder: (context, leagueSnapshot) {
        if (!leagueSnapshot.hasData) return const CircularProgressIndicator();

        List<dynamic> teamIds = leagueSnapshot.data!['teams'] ?? [];

        if (teamIds.isEmpty) {
          return const Text("No teams in this league yet");
        }

        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('teams')
              .where(FieldPath.documentId, whereIn: teamIds)
              .snapshots(),
          builder: (context, teamsSnapshot) {
            if (!teamsSnapshot.hasData) return const CircularProgressIndicator();

            var teams = teamsSnapshot.data!.docs;

            return DropdownButton<String>(
              value: isFirstTeam ? _selectedTeam1 : _selectedTeam2,
              hint: Text(isFirstTeam ? "Select Team 1" : "Select Team 2"),
              isExpanded: true,
              items: teams.map((doc) {
                return DropdownMenuItem<String>(
                  value: doc.id,
                  child: Text(doc['teamName']),
                );
              }).toList(),
              onChanged: (String? value) {
                setState(() {
                  if (isFirstTeam) {
                    _selectedTeam1 = value;
                  } else {
                    _selectedTeam2 = value;
                  }
                });
              },
            );
          },
        );
      },
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.leagueName),
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
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Schedule a Match",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 30),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    children: [
                      _buildTeamDropdown(true),
                      const SizedBox(height: 20),
                      _buildTeamDropdown(false),
                      const SizedBox(height: 25),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton.icon(
                            icon: const Icon(Icons.calendar_today),
                            label: Text(
                              _selectedDate == null
                                  ? "Pick Date"
                                  : DateFormat('MMM dd').format(_selectedDate!),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueAccent,
                              foregroundColor: Colors.white,
                            ),
                            onPressed: () => _selectDate(context),
                          ),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.access_time),
                            label: Text(
                              _selectedTime == null
                                  ? "Pick Time"
                                  : _selectedTime!.format(context),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueAccent,
                              foregroundColor: Colors.white,
                            ),
                            onPressed: () => _selectTime(context),
                          ),
                        ],
                      ),
                      const SizedBox(height: 25),
                      if (_selectedDate != null && _selectedTime != null)
                        Text(
                          "Scheduled for ${DateFormat('MMM dd, yyyy').format(_selectedDate!)} at ${_selectedTime!.format(context)}",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      const SizedBox(height: 30),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: _scheduleMatch,
                          child: const Text(
                            "CONFIRM MATCH",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
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
}