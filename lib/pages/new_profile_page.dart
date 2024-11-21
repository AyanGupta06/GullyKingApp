import 'package:flutter/material.dart';
import 'package:gully_king/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'home_page.dart';
import 'new_game_page.dart';

class NewProfilePage extends StatefulWidget {
  const NewProfilePage({super.key});

  @override
  State<NewProfilePage> createState() => _LoginPageState();
}

class _LoginPageState extends State<NewProfilePage> {
  int _selectedIndex = 4; //default homeIndex



  final TextEditingController _controllerUsername = TextEditingController();


  Widget _title() {
    return const Text(
      "GullyKing",
      style: TextStyle(
        fontSize: 42,
        fontWeight: FontWeight.bold,
        color: Colors.blueAccent,
      ),
    );
  }

  Widget _usernameEntry (String hintText, TextEditingController controller) {
    return TextField(
      controller: controller,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(color: Colors.blueAccent),
          filled: true,
          fillColor: const Color.fromRGBO(245, 245, 245, 0.6),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20.0),
            borderSide: BorderSide.none,
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
        break;
      case 2: //home
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
        break;
      case 3: //friends
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


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);

            // Navigator.push(
            //   context,
            //   MaterialPageRoute(builder: (context) => HomePage()),
            // );
          },
        ),
        backgroundColor: const Color.fromRGBO(53, 150, 207, 1),
        title: const Text('Create a New Game'),
      ),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 150),
            _title(),
            const SizedBox(height: 20),
            _usernameEntry("Enter your username", _controllerUsername),

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
