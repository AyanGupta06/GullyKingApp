import 'package:flutter/material.dart';
import 'package:gully_king/auth.dart';
import 'package:gully_king/pages/friends_teams_page.dart';
import 'package:gully_king/pages/home_page.dart';
import 'package:gully_king/pages/new_game_page.dart';
import 'package:gully_king/pages/new_profile_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PreviousGamesPage extends StatefulWidget {
  const PreviousGamesPage({super.key});

  @override
  State<PreviousGamesPage> createState() => _PreviousGamesPageState();
}

class _PreviousGamesPageState extends State<PreviousGamesPage> {
  int _selectedIndex = 1; 
  final User? user = Auth().currentUser;

  String username = "";
  String position = "";

  Future<void> _fetchUserData() async {
    if (user == null) return;

    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('matches')
          .doc(user!.uid)
          .get();

      setState(() {
        // username = userDoc['username'] ?? "N/A";
        position = userDoc['result'] ?? "N/A";
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


  Widget _title() {
    return const Text(
      "GullyKing",
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 42,
        fontWeight: FontWeight.bold,
        color: Colors.blueAccent,
      ),
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


  Widget build(BuildContext context) {
    return Scaffold(
    
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 30), 
            _title(),
            const SizedBox(height: 20), 
            // _infoRow(label: "Username:", value: username),
            _infoRow(label: "Position:", value: position),
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