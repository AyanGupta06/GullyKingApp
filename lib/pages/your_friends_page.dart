import 'package:flutter/material.dart';
import 'package:gully_king/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gully_king/pages/add_new_friends_page.dart';
import 'package:gully_king/pages/all_previous_games_page.dart';
import 'package:gully_king/pages/friends_profile_page.dart';
import 'package:gully_king/pages/friends_teams_page.dart';
import 'package:gully_king/pages/previous_games_page.dart';
import 'package:gully_king/pages/your_teams_page.dart';

import 'home_page.dart';
import 'new_game_page.dart';
import 'new_profile_page.dart';
import 'your_teams_page.dart';

class YourFriendsPage extends StatefulWidget {
  const YourFriendsPage({super.key});

  @override
  State<YourFriendsPage> createState() => _YourFriendsPageState();
}

class _YourFriendsPageState extends State<YourFriendsPage> {
  int _selectedIndex = 3; // Default home index
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

  Widget _friendsList() {
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
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => FriendsProfilePage(friendEmail: friendEmail)),
                        );
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
            message: 'Friends/Teams',
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
          'Your Friends', 
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
            const Text(
              "Your Friends",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
            ),
            const SizedBox(height: 10),
            _friendsList(),
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