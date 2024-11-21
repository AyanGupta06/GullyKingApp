import 'package:flutter/material.dart';

class NewGamePage extends StatelessWidget {
  const NewGamePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); 
          },
        ),
        backgroundColor: const Color.fromRGBO(53, 150, 207, 1),
        title: const Text('Create a New Game'),
      ),
      body: Center(
        child: Text(
          "New Game Page",
          style: TextStyle(fontSize: 20, color: Colors.black),
        ),
      ),
    );
  }
}
