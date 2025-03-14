import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gully_king/pages/Friends/friends_teams_page.dart';

class TeamChatPage extends StatefulWidget {
  final String teamId;
  final String teamName;

  const TeamChatPage({Key? key, required this.teamId, required this.teamName}) : super(key: key);

  @override
  _TeamChatPageState createState() => _TeamChatPageState();
}

class _TeamChatPageState extends State<TeamChatPage> {
  final User? user = FirebaseAuth.instance.currentUser;
  final TextEditingController _messageController = TextEditingController();
  String? userName;

  @override
  void initState() {
    super.initState();
    _fetchUserName();
  }

  Future<void> _fetchUserName() async {
    if (user == null) return;
    var userDoc = await FirebaseFirestore.instance.collection('users').doc(user!.uid).get();
    setState(() {
      userName = userDoc['username'] ?? 'Unknown';
    });
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty || userName == null) return;

    FirebaseFirestore.instance.collection('team_chats').doc(widget.teamId).collection('messages').add({
      'senderEmail': user!.email,
      'senderName': userName,
      'text': _messageController.text.trim(),
      'timestamp': FieldValue.serverTimestamp(),
    });

    _messageController.clear();
  }

  @override
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
        title: Text(
          "${widget.teamName} Chat", 
          style: const TextStyle(fontSize: 22, fontWeight:FontWeight.normal, color: Colors.black)
        ),
        backgroundColor: const Color.fromRGBO(53, 150, 207, 1),
        elevation: 0,
      ),
      body:  Container(
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
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('team_chats')
                    .doc(widget.teamId)
                    .collection('messages')
                    .orderBy('timestamp', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

                  var messages = snapshot.data!.docs;

                  return ListView.builder(
                    reverse: true,
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      var msg = messages[index];
                      bool isMe = msg['senderEmail'] == user!.email;

                      return Align(
                        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isMe ? Colors.blue[300] : Colors.grey[300],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                msg['senderName'],
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                              Text(
                                msg['text'],
                                style: TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: "Type a message...",
                      // border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                    ),
                  ),
                  ),
                  IconButton(
                    icon: Icon(Icons.send, color: Colors.blue),
                    onPressed: _sendMessage,
                  ),
                ],
              ),
            ),
          ],
        ),
      )
    );
  }
}
