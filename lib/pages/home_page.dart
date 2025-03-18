// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:gully_king/auth.dart';
// import 'package:gully_king/pages/Previous%20Games/all_previous_games_page.dart';
// import 'package:gully_king/pages/new_profile_page.dart';
// import 'package:gully_king/pages/Previous%20Games/Previous%20Unranked%20Games/previous_games_page.dart';
// import 'New Game/new_game_page.dart'; 
// import 'Friends/friends_teams_page.dart';

// class HomePage extends StatefulWidget {
//   @override
//   _HomePageState createState() => _HomePageState();
// }

// class _HomePageState extends State<HomePage> {
//   final User? user = Auth().currentUser;
//   int _selectedIndex = 2; //default homeIndez
//   String username = "";

//   @override
//   void initState() {
//     super.initState();
//     _fetchUserData();
//   }

//   Future<void> signOut() async {
//     await Auth().signOut();
//   }

//   Future<void> _fetchUserData() async {
//     // if (user == null) return;

//     try {
//       DocumentSnapshot userDoc = await FirebaseFirestore.instance
//           .collection('users')
//           .doc(user!.uid)
//           .get();

//       setState(() {
//         username = userDoc['username'] ?? "N/A";
        
//       });
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text("Error fetching user data: $e"),
//           backgroundColor: Colors.red,
//         ),
//       );
//     }
//   }


//   Widget _userId() {
//     return Text(
//       user?.email ?? "User Email",
//       style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//     );
//   }
//     Widget _signOutClick() {
//     return ElevatedButton(
//       onPressed: signOut,
//       child: const Text("Sign Out"),
//     );
//   }

  

//   void _navigateToPage(int index) {
//     setState(() {
//       _selectedIndex = index;
//     });

//     switch (index) {
//       case 0: //new game
//         Navigator.push(
//           context,
//           MaterialPageRoute(builder: (context) => const NewGamePage()),
//         );
//         break;
//       case 1: //old games
//       Navigator.push(
//           context,
//           MaterialPageRoute(builder: (context) => const AllPreviousGamesPage()),
//         );
//         break;
//       case 2: //home
//         break;
//       case 3: //friends
//       Navigator.push(
//           context,
//           MaterialPageRoute(builder: (context) => const FriendsTeamsPage()),
//         );
//         break;
//       case 4: //profile
//       Navigator.push(
//           context,
//           MaterialPageRoute(builder: (context) => const NewProfilePage()),
//         );
//         break;

//       default:
//       //idk
//         break;
//     }
//   }

  

//   Widget _welcome() {
//     return Text (
//       "Welcome, $username",
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         leading: Transform.rotate(
//           angle: 0, 
//           child: Tooltip(
//             message: 'Home',
//             child: IconButton(
//               icon: const Icon(Icons.home_sharp),
//               onPressed: () {
//               },
//             ),
//           ),
//         ),
//         title: const Text(
//           'Home', 
//           style: TextStyle(fontSize: 22, fontWeight:FontWeight.normal, color: Colors.black)
//         ),
//         backgroundColor: const Color.fromRGBO(53, 150, 207, 1),
//         elevation: 0,
//       ),
//       body: Container(
//         decoration: const BoxDecoration(
//           image: DecorationImage(
//             image: AssetImage('assets/bg4.png'),
//             fit: BoxFit.cover,
//           ),
//         ),
//         height: double.infinity,
//         width: double.infinity,
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.center,
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             _userId(),
//             _welcome(),
//             _signOutClick(),
//           ],
//         ),
//       ),
//       bottomNavigationBar: BottomAppBar(
//         color: const Color.fromRGBO(53, 150, 207, 1),
//         height: 70,
//         child: Row(
//           mainAxisSize: MainAxisSize.max,
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             _buildBottomBarIcon(
//               icon: Icons.add_box_rounded,
//               index: 0,
//               label: 'New Game',
//             ),
//             _buildBottomBarIcon(
//               icon: Icons.file_present_sharp,
//               index: 1,
//               label: 'Records',
//             ),
//             _buildBottomBarIcon(
//               icon: Icons.home_sharp,
//               index: 2,
//               label: 'Home',
//             ),
//             _buildBottomBarIcon(
//               icon: Icons.people_alt_sharp,
//               index: 3,
//               label: 'Friends',
//             ),
//             _buildBottomBarIcon(
//               icon: Icons.person,
//               index: 4,
//               label: 'Account',
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// //fyi tooltip is what gives the user the hint on what the button is
//   Widget _buildBottomBarIcon({required IconData icon, required int index, required String label}) {
//     return Tooltip(
//       message: label,
//       child: IconButton(
//         icon: Icon(icon),
//         color: _selectedIndex == index ? Colors.white : Colors.black,
//         onPressed: () => _navigateToPage(index),
//         iconSize: 30,
//       ),
//     );
//   }
// }
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gully_king/auth.dart';
import 'package:gully_king/pages/Friends/chat_page.dart';
import 'package:gully_king/pages/Friends/team_chat_page.dart';
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

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    _fetchRecentContacts();
  }

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
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
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
            const SizedBox(height: 10),
            contact != null
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(contact, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 10),
                      Center(
                        child: ElevatedButton(
                          onPressed: onTap,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text("Chat", style: TextStyle(color: Colors.white)),
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
            const SizedBox(height: 10),
            contact != null
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(contact, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 10),
                      Center(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChatPage(friendEmail: recentDM, friendName: recentDMName),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text("Chat", style: TextStyle(color: Colors.white)),
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
            _welcome(),
            // _recentlyContactedCard("Recently Contacted DMs", recentDM, () {
            //   if (recentDM != null && recentDMName != null) {
            //     Navigator.push(
            //       context,
            //       MaterialPageRoute(
            //         builder: (context) => ChatPage(friendEmail: recentDM, friendName: recentDMName),
            //       ),
            //     );
            //   }
            // }),
            _recentlyContactedCardFriend("Recently Contacted DMs", recentDM),

            _recentlyContactedCard("Recently Contacted Teams", recentTeam, () {
              if (recentTeam != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TeamChatPage(teamId: recentTeamID!, teamName: recentTeam!),
                  ),
                );
              }
            }),
            const Spacer(),
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
