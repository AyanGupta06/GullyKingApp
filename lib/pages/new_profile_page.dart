import 'package:flutter/material.dart';
import 'package:gully_king/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gully_king/pages/Previous%20Games/all_previous_games_page.dart';
import 'package:intl/intl.dart';
import 'home_page.dart';
import 'New Game/new_game_page.dart';
import 'Friends/friends_teams_page.dart';
import 'dart:math' as math;

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
  String email = "";
  bool isEditingUsername = false;
  bool isEditingPosition = false;
  TextEditingController usernameController = TextEditingController();
  TextEditingController positionController = TextEditingController();

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
        email = userDoc['email'] ?? "N/A";
        usernameController.text = username;
        positionController.text = position;
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
    if (usernameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Username cannot be empty")),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('users').doc(user!.uid).update({
        'username': usernameController.text.trim(),
      });

      setState(() {
        username = usernameController.text.trim();
        isEditingUsername = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Username updated successfully!"), backgroundColor: Colors.green),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error updating username: $e"), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _updatePosition() async {
    if (positionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Position cannot be empty")),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('users').doc(user!.uid).update({
        'position': positionController.text.trim(),
      });

      setState(() {
        position = positionController.text.trim();
        isEditingPosition = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Position updated successfully!"), backgroundColor: Colors.green),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error updating position: $e"), backgroundColor: Colors.red),
      );
    }
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
            // Username Row
            isEditingUsername
                ? TextField(
                    controller: usernameController,
                    decoration: InputDecoration(
                      hintText: "Enter new username",
                      suffixIcon: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.check, color: Colors.green),
                            onPressed: _updateUsername,
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.red),
                            onPressed: () {
                              setState(() {
                                isEditingUsername = false;
                                usernameController.text = username;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  )
                : Row(
                    children: [
                      const Icon(Icons.person, color: Colors.blue),
                      const SizedBox(width: 10),
                      const Text("Username:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const Spacer(),
                      Text(username, style: const TextStyle(fontSize: 18)),
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
            // Email Row (non-editable)
            Row(
              children: [
                const Icon(Icons.email, color: Colors.blue),
                const SizedBox(width: 10),
                const Text("Email:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const Spacer(),
                Text(email, style: const TextStyle(fontSize: 18)),
              ],
            ),
            const Divider(),
            // Position Row
            isEditingPosition
                ? TextField(
                    controller: positionController,
                    decoration: InputDecoration(
                      hintText: "Enter your cricket position",
                      suffixIcon: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.check, color: Colors.green),
                            onPressed: _updatePosition,
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.red),
                            onPressed: () {
                              setState(() {
                                isEditingPosition = false;
                                positionController.text = position;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  )
                : Row(
                    children: [
                      Transform.rotate(
                        angle: 180 * math.pi / 180,
                        child: const Icon(Icons.sports_cricket, color: Colors.blue),
                      ),
                      const SizedBox(width: 10),
                      const Text("Position:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const Spacer(),
                      Text(position, style: const TextStyle(fontSize: 18)),
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {
                          setState(() {
                            isEditingPosition = true;
                          });
                        },
                      ),
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
      case 0:
        Navigator.push(context, MaterialPageRoute(builder: (context) => const NewGamePage()));
        break;
      case 1:
        Navigator.push(context, MaterialPageRoute(builder: (context) => const AllPreviousGamesPage()));
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
              "Profile Settings",
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Colors.black,
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
