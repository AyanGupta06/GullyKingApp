import 'package:flutter/material.dart';
import 'package:gully_king/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'home_page.dart';
import 'new_game_page.dart';
import 'friends_teams_page.dart';

class NewProfilePage extends StatefulWidget {
  const NewProfilePage({super.key});

  @override
  State<NewProfilePage> createState() => _NewProfilePageState();
}

class _NewProfilePageState extends State<NewProfilePage> {
  int _selectedIndex = 4; // Default home index
  final User? user = Auth().currentUser;

<<<<<<< Updated upstream
  String username = "";
  String position = "";

=======
  // Variables to hold Firestore data
  String username = "";
  String position = "";

  // Fetch user details from Firestore
>>>>>>> Stashed changes
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
<<<<<<< Updated upstream

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
=======
>>>>>>> Stashed changes

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Widget _title() {
    return const Center(
      child: Text(
        "GullyKing",
        style: TextStyle(
          fontSize: 52,
          fontWeight: FontWeight.bold,
          color: Colors.blueAccent,
        ),
      ),
    );
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
<<<<<<< Updated upstream
        ),
    );
  }


  Widget _settingsText() {
    return const Text (
      "Settings", 
      style: TextStyle(fontSize: 20, fontWeight:FontWeight.bold, color: Colors.blueAccent)

    );
  }

  Widget _profileView() {
    return const Text (
      "Profile View: ", 
      style: TextStyle(fontSize: 20, fontWeight:FontWeight.bold, color: Colors.blueAccent)
    );
  }
  Widget _colorScheme() {
    return const Text (
      "App Theme: ", 
      style: TextStyle(fontSize: 20, fontWeight:FontWeight.bold, color: Colors.blueAccent)
=======
          Text(
            value,
            style: const TextStyle(
              fontSize: 25,
              color: Colors.black,
            ),
          ),
        ],
      ),
>>>>>>> Stashed changes
    );
  }

  

  void _navigateToPage(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0: // New game
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const NewGamePage()),
        );
        break;
      case 1: // Old games
        break;
      case 2: // Home
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
        break;
<<<<<<< Updated upstream
      case 3: //friends
      Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const FriendsTeamsPage()),
        );
=======
      case 3: // Friends
>>>>>>> Stashed changes
        break;
      case 4: // Profile
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const NewProfilePage()),
        );
        break;

      default:
        break;
    }
  }

<<<<<<< Updated upstream

  Widget build(BuildContext context) {
    return Scaffold(
    
=======
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(53, 150, 207, 1),
        title: const Text('Profile Settings'),
      ),
>>>>>>> Stashed changes
      body: Container(
        decoration: BoxDecoration(
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
<<<<<<< Updated upstream
            const SizedBox(height: 30), 
            _title(),
            const SizedBox(height: 20), 
=======
            const SizedBox(height: 30), // Reduced white space above title
            _title(),
            const SizedBox(height: 20), // Reduced space below title
>>>>>>> Stashed changes
            _infoRow(label: "Username:", value: username),
            _infoRow(label: "Position:", value: position),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
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
        color: const Color.fromRGBO(53, 150, 207, 1),
        height: 70,
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
