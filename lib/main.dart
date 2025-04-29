import "package:gully_king/auth.dart";
import "package:gully_king/pages/home_page.dart";
import 'package:gully_king/pages/LoginAndRegister/login_register_page.dart';
import "package:flutter/material.dart";
import "package:gully_king/widget_tree.dart";
import "package:firebase_core/firebase_core.dart";

//things to fix in app - ranked match you can select same person twice to start the batting
//when you add another person to team their leagues dont get updated

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData (
        primarySwatch: Colors.lightBlue
      ),
      home: const WidgetTree(),
    );
  }
}
