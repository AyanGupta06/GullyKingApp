import 'package:flutter/material.dart';
import 'package:gully_king/pages/home_page.dart';

class NewGamePage extends StatelessWidget {
  const NewGamePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      body: Center(
        child: Text(
          "New Game Page",
          style: TextStyle(fontSize: 20, color: Colors.black),
        ),
      ),
    );
  }
}
