import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gully_king/auth.dart';

class HomePage extends StatelessWidget {
  HomePage({Key? key}) : super(key: key);

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
        ),
        bottomNavigationBar: BottomAppBar(
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                  icon: Icon(Icons.add_box_rounded),
                  color: Colors.black,

                  onPressed: () {
                    print("NewGamePressed");
                  }),
              IconButton(
                  icon: Icon(Icons.file_present_sharp),
                  color: Colors.black,
                  onPressed: () {
                    print("RecordsPressed");
                  }),
              IconButton(
                  icon: Icon(Icons.home_sharp),
                  color: Colors.black,
                  onPressed: () {
                    print("HomePressed");
                  }),
              IconButton(
                  icon: Icon(Icons.people_alt_sharp),
                  color: Colors.black,
                  onPressed: () {
                    print("FriendsPressed");
                  }),
              IconButton(
                  icon: Icon(Icons.person),
                  color: Colors.black,
                  onPressed: () {
                    print("AccountPressed");
                  }),
            ],
          ),

          color: Color.fromRGBO(53, 150, 207, 1),
          // color: Colors.blue
          height: 70,
        ));
  }
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //       appBar: AppBar(
  //         title: _title(),
  //       ),
  //     body: Container (
  //       height: double.infinity,
  //       padding: const EdgeInsets.all(20),
  //       width: double.infinity,
  //       child: Column(
  //         crossAxisAlignment: CrossAxisAlignment.center,
  //         mainAxisAlignment: MainAxisAlignment.center,
  //         children: <Widget>[
  //           _userId(),
  //           _signOutClick(),
  //         ],
  //       )
  //     )
  //   );
  // }
}
