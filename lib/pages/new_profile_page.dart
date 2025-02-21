import 'package:flutter/material.dart';
import 'package:gully_king/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gully_king/pages/Previous%20Games/all_previous_games_page.dart';

import 'home_page.dart';
import 'New Game/new_game_page.dart';
import 'Friends/friends_teams_page.dart';

class NewProfilePage extends StatefulWidget {
  const NewProfilePage({super.key});

  @override
  State<NewProfilePage> createState() => _NewProfilePageState();
}

class _NewProfilePageState extends State<NewProfilePage> {
  int _selectedIndex = 4;
  final User? user = Auth().currentUser;
  String username = "";
  String position = "";
  bool isEditingUsername = false;
  TextEditingController usernameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

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
        usernameController.text = username;
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

  Future<void> _updateUsername() async {
    await FirebaseFirestore.instance.collection('users').doc(user!.uid).update({
      'username': usernameController.text.trim(),
    });

    setState(() {
      username = usernameController.text.trim();
      isEditingUsername = false;
    });
  }

  Widget _infoCard() {
    return Card(
      elevation: 5,
      margin: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            isEditingUsername
                ? TextField(
                    controller: usernameController,
                    decoration: InputDecoration(
                      hintText: "Enter new username",
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.check, color: Colors.green),
                        onPressed: _updateUsername,
                      ),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Username: $username",
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {
                          setState(() {
                            isEditingUsername = true;
                          });
                        },
                      ),
                    ],
                  ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Position:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text(position, style: const TextStyle(fontSize: 18)),
              ],
            ),
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
        title: const Text(
          "Profile Settings",
          style: TextStyle(fontSize: 22, color: Colors.black),
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
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            const Text(
              "GullyKing",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
            ),
            const SizedBox(height: 20),
            _infoCard(),
            const Spacer(),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: const Color.fromRGBO(53, 150, 207, 1),
        height: 70,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildBottomBarIcon(Icons.add_box_rounded, 0, 'New Game'),
            _buildBottomBarIcon(Icons.file_present_sharp, 1, 'Records'),
            _buildBottomBarIcon(Icons.home_sharp, 2, 'Home'),
            _buildBottomBarIcon(Icons.people_alt_sharp, 3, 'Friends'),
            _buildBottomBarIcon(Icons.person, 4, 'Account'),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBarIcon(IconData icon, int index, String label) {
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
