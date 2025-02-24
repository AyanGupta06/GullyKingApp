import 'package:flutter/material.dart';
import 'package:gully_king/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gully_king/pages/Friends/add_new_friends_page.dart';
import 'package:gully_king/pages/Friends/invite_team_page.dart';
import 'package:gully_king/pages/Previous%20Games/all_previous_games_page.dart';
import 'package:gully_king/pages/Previous%20Games/Previous%20Unranked%20Games/previous_games_page.dart';
import 'package:gully_king/pages/Friends/your_friends_page.dart';
import 'package:gully_king/pages/Friends/your_teams_page.dart';

import '../home_page.dart';
import '../New Game/new_game_page.dart';
import '../new_profile_page.dart';
import 'your_teams_page.dart';

class FriendsTeamsPage extends StatefulWidget {
  const FriendsTeamsPage({super.key});

  @override
  State<FriendsTeamsPage> createState() => _NewProfilePageState();
}

class _NewProfilePageState extends State<FriendsTeamsPage> {
  int _selectedIndex = 3; 
  final User? user = Auth().currentUser;

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

  Widget _infoRow({required String label, required String value}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: Colors.black,
              
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 25,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _addFriends() {
    return FloatingActionButton.extended(
      onPressed:() {Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AddNewFriendsPage()),
        );
      },
    
      label: const Text(
        "                                 Add Friends                                 ",
        style: TextStyle(color: Colors.black, fontSize: 18),
      )
    );
  } 
 
  Widget _yourTeams() {
    return FloatingActionButton.extended(
      onPressed:() {Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const YourTeamsPage()),
        );
      },
    
      label: const Text(
        "                                 Your Teams                                 ",
        style: TextStyle(color: Colors.black, fontSize: 18),
      )
    );
  } 

 
  Widget _yourFriends() {
    return FloatingActionButton.extended(
      // backgroundColor: const Color.fromRGBO(53, 150, 207, 1),
      onPressed:() {Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const YourFriendsPage()),
        );
      },
    
      label: const Text(
        "                                 Your Friends                                 ",
        style: TextStyle(color: Colors.black, fontSize: 18),
      )
    );
  } 

  Widget _joinTeam() {
    return FloatingActionButton.extended(
      // backgroundColor: const Color.fromRGBO(53, 150, 207, 1),
      onPressed:() {Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const InviteTeamPage()),
        );
      },
    
      label: const Text(
        "                         Invite/Join Team                         ",
        style: TextStyle(color: Colors.black, fontSize: 18),
      )
    );
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
          MaterialPageRoute(builder: (context) => const AllPreviousGamesPage()),
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


  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Transform.rotate(
          angle: 0, 
          child: Tooltip(
            message: 'Friends/Teams',
            child: IconButton(
              icon: const Icon(Icons.people_alt_sharp),
              onPressed: () {
              },
            ),
          ),
        ),
        title: const Text(
          'Friends/Team', 
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
          children: [
            
            const SizedBox(height: 20), 
            _addFriends(),
            const SizedBox(height: 20), 
            _joinTeam(),
            const SizedBox(height: 20), 
            _yourFriends(),
            const SizedBox(height: 20), 
            _yourTeams(),
          ]
          
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