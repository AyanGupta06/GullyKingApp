import 'package:flutter/material.dart';
import 'package:gully_king/pages/friends_teams_page.dart';
import 'package:gully_king/pages/home_page.dart';
import 'package:gully_king/pages/new_game_page.dart';
import 'package:gully_king/pages/new_profile_page.dart';
import 'package:gully_king/pages/new_unranked_game_page.dart';
import 'package:gully_king/pages/unranked_scorecard_page.dart';

class StartedNewUnrankedGamePage extends StatefulWidget {
  final String numberOfOvers;
  final List<Player> team1Players;
  final List<Player> team2Players;

  const StartedNewUnrankedGamePage({
    super.key,
    required this.numberOfOvers,
    required this.team1Players,
    required this.team2Players,
  });

  @override
  State<StartedNewUnrankedGamePage> createState() =>
      _StartedNewUnrankedGamePageState();
}

class _StartedNewUnrankedGamePageState extends State<StartedNewUnrankedGamePage> {
  int _selectedIndex = 0;
  String? battingFirstTeam;
  Player? batsmanOnStrike;
  Player? batsmanOnNonStrike;
  Player? bowler;
  List<Player> battingFirstPlayers = [];
  List<Player> bowlingFirstPlayers = [];

  void _navigateToPage(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0: // new game
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const NewGamePage()),
        );
        break;
      case 1: // old games
        break;
      case 2: // home
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
        break;
      case 3: // friends
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const FriendsTeamsPage()),
        );
        break;
      case 4: // profile
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const NewProfilePage()),
        );
        break;

      default:
        break;
    }
  }

  Widget _selectBattingTeam() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Select Batting Team:",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            _teamButton("Team 1", widget.team1Players),
            const SizedBox(width: 20),
            _teamButton("Team 2", widget.team2Players),
          ],
        ),
      ],
    );
  }

  Widget _teamButton(String teamName, List<Player> players) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: battingFirstTeam == teamName
            ? Colors.blueAccent
            : Colors.grey.shade300,
      ),
      onPressed: () {
        setState(() {
          battingFirstTeam = teamName;
          batsmanOnStrike = null;
          batsmanOnNonStrike = null;
          bowler = null;
        });
      },
      child: Text(
        teamName,
        style: const TextStyle(color: Colors.black),
      ),
    );
  }

  Widget _selectOpeners() {
    final players = battingFirstTeam == "Team 1"
        ? widget.team1Players
        : widget.team2Players;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Select Openers:",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        DropdownButton<Player>(
          value: batsmanOnStrike,
          hint: const Text("Batsman on Strike"),
          items: players.map((player) {
            return DropdownMenuItem(value: player, child: Text(player.name));
          }).toList(),
          onChanged: (value) {
            setState(() {
              batsmanOnStrike = value;
            });
          },
        ),
        DropdownButton<Player>(
          value: batsmanOnNonStrike,
          hint: const Text("Batsman on Non-Strike"),
          items: players.map((player) {
            return DropdownMenuItem(value: player, child: Text(player.name));
          }).toList(),
          onChanged: (value) {
            setState(() {
              batsmanOnNonStrike = value;
            });
          },
        ),
      ],
    );
  }

  Widget _selectBowler() {
    final bowlers = battingFirstTeam == "Team 1"
        ? widget.team2Players
        : widget.team1Players;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Select Bowler:",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        DropdownButton<Player>(
          value: bowler,
          hint: const Text("Select Bowler"),
          items: bowlers.map((player) {
            return DropdownMenuItem(value: player, child: Text(player.name));
          }).toList(),
          onChanged: (value) {
            setState(() {
              bowler = value;
            });
          },
        ),
      ],
    );
  }

  Widget _startGameButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blueAccent,
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
      ),
      onPressed: _validateAndNavigate,
      child: const Text(
        "Start Game",
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  void _validateAndNavigate() {
    if (battingFirstTeam == null) {
      _showErrorDialog("Please select which team is batting first.");
      return;
    }

    if (batsmanOnStrike == null || batsmanOnNonStrike == null) {
      _showErrorDialog("Please select the two opening batsmen.");
      return;
    }

    if (bowler == null) {
      _showErrorDialog("Please select the first bowler.");
      return;
    }

    if(battingFirstTeam == "Team 1") {
      battingFirstPlayers = widget.team1Players;
      bowlingFirstPlayers = widget.team2Players;
    } else if (battingFirstTeam == "Team 2") {
      battingFirstPlayers = widget.team2Players;
      bowlingFirstPlayers = widget.team1Players;
    } 

    print("Batting Test " + battingFirstPlayers[0].name);
    print(bowlingFirstPlayers);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UnrankedScorecardPage(
          battingFirstTeam: battingFirstTeam,
          bowler: bowler,
          batsmanOnStrike: batsmanOnStrike,
          batsmanOnNonStrike: batsmanOnNonStrike,
          maxOvers: int.parse(widget.numberOfOvers),
          battingTeam: battingFirstPlayers,
          bowlingTeam: bowlingFirstPlayers, 

        ),
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Error"),
          content: Text(message),
          actions: [
            TextButton(
              child: const Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Unranked Game Setup',
          style: TextStyle(color: Colors.black),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Overs: ${widget.numberOfOvers}",
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 20),
            _selectBattingTeam(),
            const SizedBox(height: 20),
            if (battingFirstTeam != null) _selectOpeners(),
            const SizedBox(height: 20),
            if (batsmanOnStrike != null && batsmanOnNonStrike != null)
              _selectBowler(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (batsmanOnStrike != null && batsmanOnNonStrike != null && bowler != null)
                  const SizedBox(height: 30),
                _startGameButton(),
              ],
            ),
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

  Widget _buildBottomBarIcon(
      {required IconData icon, required int index, required String label}) {
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
