import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gully_king/auth.dart';
import 'package:gully_king/pages/Friends/chat_page.dart';
import 'package:gully_king/pages/Friends/team_chat_page.dart';
import 'package:gully_king/pages/LoginAndRegister/login_register_page.dart';
import 'package:gully_king/pages/Previous%20Games/all_previous_games_page.dart';
import 'package:gully_king/pages/new_profile_page.dart';
import 'package:gully_king/pages/Previous%20Games/Previous%20Unranked%20Games/previous_games_page.dart';
import 'New Game/new_game_page.dart'; 
import 'Friends/friends_teams_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final User? user = Auth().currentUser;
  int _selectedIndex = 2;
  String username = "";
  String recentDM = "";
  String? recentTeam;
  String recentDMName = "";
  String? recentTeamID;
  int totalRuns = 0;
  int totalBallsFaced = 0;
  int totalWicketsTaken = 0;
  int totalBallsBowled = 0;
  int totalRunsGiven = 0;
  double strikeRate = 0;


  @override
  void initState() {
    super.initState();
    _fetchUserData();
    _fetchRecentContacts();
    _fetchRankedStats();
  }

  // Future<void> signOut() async {
  //   try{
  //   await Auth().signOut();
  //   Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginPage()));
  //   } catch (e) {
  //     print("Error logging out:  $e");
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text("Error logging out"))
  //     );
  //   }
  // }
  Future<void> signOut() async {
    await Auth().signOut();
  }

  Future<void> _fetchUserData() async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .get();

      setState(() {
        username = userDoc['username'] ?? "N/A";
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

  Future<void> _fetchRecentContacts() async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .get();

      setState(() {
        recentDM = userDoc['recent_dm'];
        recentTeam = userDoc['recent_team'];
      });

      if (recentDM != null) {
        QuerySnapshot snapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('email', isEqualTo: recentDM)
            .limit(1)
            .get();

        DocumentSnapshot<Object?>? friendDoc = snapshot.docs.isNotEmpty
            ? snapshot.docs.first as DocumentSnapshot
            : null;

        if (friendDoc != null) {
          setState(() {
            recentDMName = friendDoc['username']; 
          });
        }
      }

      if (recentTeam != null) {
        QuerySnapshot snapshot = await FirebaseFirestore.instance
            .collection('teams')
            .where('teamName', isEqualTo: recentTeam)
            .limit(1)
            .get();

        DocumentSnapshot<Object?>? teamDoc = snapshot.docs.isNotEmpty
            ? snapshot.docs.first as DocumentSnapshot
            : null;

        if (teamDoc != null) {
          setState(() {
            recentTeamID = teamDoc['teamId']; 
          });
        }
      }
    } catch (e) {
      print("Error fetching recent contacts: $e");
    }
  }




  Widget _welcome() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Text(
          "Welcome, $username",
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
          
        ),
      ),
    );
  }

  Widget _recentlyContactedCard(String title, String? contact, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(color: Colors.black26, blurRadius: 5, offset: Offset(0, 2)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Divider(),
            contact != null
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(contact, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 10),
                      Center(
                        child: 
                        ElevatedButton.icon(
                          onPressed: onTap,
                          icon: Icon(Icons.chat, color: Colors.white),
                          label: Text("Chat", style: TextStyle(color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                          ),
                        ),
                      ),
                    ],
                  )
                : const Text("No recent contact", style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _recentlyContactedCardFriend(String title, String? contact) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(color: Colors.black26, blurRadius: 5, offset: Offset(0, 2)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Divider(),
            contact != null
                ? Row (
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(contact, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 10),
                      
                        
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChatPage(friendEmail: recentDM, friendName: recentDMName),
                              ),
                            );
                          },
                          icon: Icon(Icons.chat, color: Colors.white),
                          label: Text("Chat", style: TextStyle(color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                          ),
                        ),
                      
                    ],
                  )
                : const Text("No recent contact", style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Future<void> _fetchRankedStats() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection("users")
          .doc(user!.uid)
          .collection("players_ranked_matches")
          .get();

      int runs = 0;
      int ballsFaced = 0;
      int wicketsTaken = 0;
      int ballsBowled = 0;
      int runsGiven = 0;

      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;

        runs += (data['runs'] ?? 0) as int;
        ballsFaced += (data['ballsFaced'] ?? 0) as int;
        wicketsTaken += (data['wicketsTaken'] ?? 0) as int;
        ballsBowled += (data['ballsBowled'] ?? 0) as int;
        runsGiven += (data['runsOnBalls'] ?? 0) as int;

      }

      print("Fetched stats: runs=$runs, ballsFaced=$ballsFaced, wicketsTaken=$wicketsTaken, ballsBowled=$ballsBowled");

      setState(() {
        totalRuns = runs;
        totalBallsFaced = ballsFaced;
        totalWicketsTaken = wicketsTaken;
        totalBallsBowled = ballsBowled;
        totalRunsGiven = runsGiven;
        strikeRate = ballsFaced > 0 ? truncateToDecimalPlaces((runs / ballsFaced) * 100, 1) : 0.00;

      });
    } catch (e) {
      print("Error fetching ranked stats: $e");
    }
  }

  double truncateToDecimalPlaces(num value, int fractionalDigits) => (value * pow(10, fractionalDigits)).truncate() / pow(10, fractionalDigits);


  Widget _rankedStatsCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(color: Colors.black26, blurRadius: 5, offset: Offset(0, 2)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Ranked Stats", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _statItem("Balls Faced", totalBallsFaced),
                _statItem("Runs", totalRuns),
                _statItemDouble("Avg S/R", strikeRate),
              ],
            ),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _statItem("Balls Bowled", totalBallsBowled),
                _statItem("Runs Given", totalRunsGiven),
                _statItem("Wickets Taken", totalWicketsTaken),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _statItem(String label, int value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 5),
        Text(value.toString(), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _statItemDouble(String label, double value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 5),
        Text(value.toString(), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      ],
    );
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Transform.rotate(
          angle: 0,
          child: Tooltip(
            message: 'Home',
            child: IconButton(
              icon: const Icon(Icons.home_sharp),
              onPressed: () {},
            ),
          ),
        ),
        title: const Text(
          'Home',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.normal, color: Colors.black),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const SizedBox(height: 20),
            _welcome(),
           
            _recentlyContactedCardFriend("Recently Contacted DM", recentDM),

            _recentlyContactedCard("Recently Contacted Team", recentTeam, () {
              if (recentTeam != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TeamChatPage(teamId: recentTeamID!, teamName: recentTeam!),
                  ),
                );
              }
            }),
            _rankedStatsCard(),

            const SizedBox(height: 40),
            Center(child: ElevatedButton(onPressed: signOut, child: const Text("Sign Out"))),
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
            _buildBottomBarIcon(icon: Icons.add_box_rounded, index: 0, label: 'New Game'),
            _buildBottomBarIcon(icon: Icons.file_present_sharp, index: 1, label: 'Records'),
            _buildBottomBarIcon(icon: Icons.home_sharp, index: 2, label: 'Home'),
            _buildBottomBarIcon(icon: Icons.people_alt_sharp, index: 3, label: 'Friends'),
            _buildBottomBarIcon(icon: Icons.person, index: 4, label: 'Account'),
          ],
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
        Navigator.push(context, MaterialPageRoute(builder: (context) => const AllPreviousGamesPage()));
        break;
      case 2:
        break;
      case 3:
        Navigator.push(context, MaterialPageRoute(builder: (context) => const FriendsTeamsPage()));
        break;
      case 4:
        Navigator.push(context, MaterialPageRoute(builder: (context) => const NewProfilePage()));
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
}
