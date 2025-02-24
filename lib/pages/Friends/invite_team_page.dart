import 'package:flutter/material.dart';
import 'package:gully_king/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gully_king/pages/Friends/add_new_friends_page.dart';
import 'package:gully_king/pages/Previous%20Games/all_previous_games_page.dart';
import 'package:gully_king/pages/Friends/friends_teams_page.dart';
import 'package:gully_king/pages/Previous%20Games/Previous%20Unranked%20Games/previous_games_page.dart';
import 'package:gully_king/pages/Friends/your_friends_page.dart';
import 'package:gully_king/pages/Friends/your_teams_page.dart';

import '../home_page.dart';
import '../New Game/new_game_page.dart';
import '../new_profile_page.dart';
import 'your_teams_page.dart';

class InviteTeamPage extends StatefulWidget {
  const InviteTeamPage({super.key});

  @override
  State<InviteTeamPage> createState() => _InviteTeamPageState();
}

class _InviteTeamPageState extends State<InviteTeamPage> {
  final User? user = Auth().currentUser;
  final TextEditingController _friendEmailController = TextEditingController();
  bool _showOutgoingRequests = true;
  int _selectedIndex = 3;

  String username = "";
  String position = "";

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

  Future<void> _sendFriendRequest() async {
    String friendEmail = _friendEmailController.text.trim();
    if (friendEmail.isEmpty) return;

    try {
      QuerySnapshot query = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: friendEmail)
          .get();

      if (query.docs.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("User not found"), backgroundColor: Colors.red),
        );
        return;
      }

      String friendId = query.docs.first.id;

      await FirebaseFirestore.instance
          .collection('friend_requests')
          .add({'from': user!.uid, 'fromEmail': user!.email, 'to': friendId, 'toEmail': friendEmail, 'status': 'pending'});

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Friend request sent!"), backgroundColor: Colors.green),
      );

      _friendEmailController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error sending request: $e"), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _addFriend(String friendEmail) async {
    // String friendEmail = _friendEmailController.text.trim();
    // if (friendEmail.isEmpty) return;

    try {
      QuerySnapshot query = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: friendEmail)
          .get();

      if (query.docs.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("User not found"), backgroundColor: Colors.red),
        );
        return;
      }

      String friendId = query.docs.first.id;

      await FirebaseFirestore.instance
          .collection('friends')
          .add({'friend1': user!.email, 'friend2': friendEmail});

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Friend request accepted!"), backgroundColor: Colors.green),
      );

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error accepting request: $e"), backgroundColor: Colors.red),
      );
    }
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

  Widget _title() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Text(
        "Join Team",
        style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.black),
      ),
    );
  }

  Widget _friendInput() {
    return Row(
      children: [
        Expanded(
          child: 
          // TextField(
          //   controller: _friendEmailController,
          //   decoration: const InputDecoration(
          //     labelText: "Enter friend's email",
          //     border: OutlineInputBorder(),
          //   ),
          // ),
          _entryFieldFriend("Enter Friend's Email", _friendEmailController),
        ),
        const SizedBox(width: 10),
        ElevatedButton(
          onPressed: _sendFriendRequest,
          child: const Text("Send"),
        ),
      ],
    );
  }

  Widget _addFriendSubmitButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blueAccent,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
      ),
      onPressed: _sendFriendRequest,
      child: const Text("Send Invite to Team"),
    );
  }

  Widget _entryFieldFriend(String hintText, TextEditingController controller) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.blueAccent),
        filled: true,
        fillColor: Colors.grey[100],
        prefixIcon: const Icon(
          Icons.people_alt_sharp,
          color: Colors.blueAccent,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20.0),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

 

  Widget _friendRequestsSection() {
    return Column(
      children: [
        ToggleButtons(
          isSelected: [_showOutgoingRequests, !_showOutgoingRequests],
          onPressed: (index) {
            setState(() {
              _showOutgoingRequests = index == 0;
            });
          },
          borderRadius: BorderRadius.circular(10),
          selectedColor: Colors.white,
          color: Colors.black,
          fillColor: Colors.blue,
          borderWidth: 2,
          borderColor: Colors.blue,
          selectedBorderColor: Colors.blue,
          children: const [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text("Outgoing Requests", style: TextStyle(fontSize: 16)),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text("Incoming Requests", style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
        const SizedBox(height: 10),
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('friend_requests')
              .where(_showOutgoingRequests ? 'from' : 'to', isEqualTo: user!.uid)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const CircularProgressIndicator();
            var requests = snapshot.data!.docs;

            return Column(
              children: requests.map((doc) {
                String friendId = _showOutgoingRequests ? doc['to'] : doc['from'];
                return FutureBuilder<DocumentSnapshot>(
                  future: FirebaseFirestore.instance.collection('users').doc(friendId).get(),
                  builder: (context, userSnapshot) {
                    if (!userSnapshot.hasData) return const SizedBox();
                    String friendName = userSnapshot.data!['username'] ?? "Unknown";
                    String friendEmail = userSnapshot.data!['email'] ?? "Unknown Email";

                    return ListTile(
                      title: Text(friendName),
                      subtitle: const Text("Pending"),
                      trailing: _showOutgoingRequests
                          ? IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () async {
                                await doc.reference.delete();
                              },
                            )
                          : Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.check, color: Colors.green),
                                  onPressed: () async {
                                    await _acceptFriendRequest(doc, friendEmail);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text("Friended successfully!"), backgroundColor: Colors.green),
                                    );
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.close, color: Colors.red),
                                  onPressed: () async {
                                    await doc.reference.delete();
                                  },
                                ),
                              ],
                            ),
                    );
                  },
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  Future<void> _acceptFriendRequest(DocumentSnapshot doc, String friendEmail) async {
    String userEmail = user!.email!;

    DocumentReference userRef = FirebaseFirestore.instance.collection('users').doc(user!.uid);
    DocumentReference friendRef = FirebaseFirestore.instance.collection('users').doc(doc['from']);

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      DocumentSnapshot userSnapshot = await transaction.get(userRef);
      DocumentSnapshot friendSnapshot = await transaction.get(friendRef);

      Map<String, dynamic> userData = userSnapshot.data() as Map<String, dynamic>? ?? {};
      Map<String, dynamic> friendData = friendSnapshot.data() as Map<String, dynamic>? ?? {};

      List<dynamic> userFriends = userData.containsKey('friends') ? List.from(userData['friends']) : [];
      List<dynamic> friendFriends = friendData.containsKey('friends') ? List.from(friendData['friends']) : [];

      if (!userFriends.contains(friendEmail)) {
        userFriends.add(friendEmail);
      }
      if (!friendFriends.contains(userEmail)) {
        friendFriends.add(userEmail);
      }

      transaction.update(userRef, {'friends': userFriends});
      transaction.update(friendRef, {'friends': friendFriends});

      await doc.reference.delete();
    });
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Transform.rotate(
          angle: 0, 
          child: Tooltip(
            message: "Friends/Teams",
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
          "Invite to Team/Join Team", 
          style: TextStyle(fontSize: 22, fontWeight:FontWeight.normal, color: Colors.black)
        ),
        backgroundColor: const Color.fromRGBO(53, 150, 207, 1),
        elevation: 0,
      ),
      body: Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/bg4.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 40),
            _title(),
            const SizedBox(height: 40),
            _entryFieldFriend("Enter Friend's Email to Invite", _friendEmailController),
            const SizedBox(height: 20),
            _addFriendSubmitButton(),
            const SizedBox(height: 20),
            _friendRequestsSection(),
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