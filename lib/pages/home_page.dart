import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gully_king/auth.dart';

class HomePage extends StatelessWidget {
  HomePage (Key? key): super(key: key);

  final User? user = Auth().currentUser;

  Future<void> signOut() async {
    await Auth().signOut();
  }
  Widget _title() {
    return const Text("Gully King");
  }

  Widget _userId() {
    return Text(user?.email ?? "User Email");
  }

  Widget _signOutClick() {
    return ElevatedButton(
      onPressed: signOut,
      child: const Text("SignOut"),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: _title(),
        ),
      body: Container (
        height: double.infinity,
        padding: const EdgeInsets.all(20),
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _userId(),
            _signOutClick(),
          ],
        )
      )
    );
  }
}