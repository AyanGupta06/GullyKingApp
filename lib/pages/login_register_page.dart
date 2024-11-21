import 'package:flutter/material.dart';
import 'package:gully_king/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sign_in_button/sign_in_button.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? _user;

  @override
  void initState() {
    super.initState();
    _auth.authStateChanges().listen((event){
      setState(() {
        _user = event;
      });
    });
  }

  String? errorMessage = '';
  bool isLogin = true;
  bool _obscureText = true;

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  final TextEditingController _controllerEmail = TextEditingController();
  final TextEditingController _controllerPassword = TextEditingController();
  final TextEditingController _controllerConfirmPassword =
      TextEditingController();

  Future<void> signInWithEmailAndPassword() async {
    try {
      await Auth().signInWithEmailAndPassword(
        email: _controllerEmail.text,
        password: _controllerPassword.text,
      );
      setState(() {
        errorMessage = '';
      });
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = e.message;
      });
    }
  }

  Future<void> createUserWithEmailAndPassword() async {
    if (_controllerPassword.text != _controllerConfirmPassword.text) {
      setState(() {
        errorMessage = "Passwords do not match!";
      });
      return;
    }

    try {
      await Auth().createUserWithEmailAndPassword(
        email: _controllerEmail.text,
        password: _controllerPassword.text,
      );
      setState(() {
        errorMessage = '';
      });
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = e.message;
      });
    }
  }

  Widget _title() {
    return const Text(
      "Gully King",
      style: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: Colors.blueAccent,
      ),
    );
  }

  Widget _entryField(String hintText, TextEditingController controller,{bool isPassword = false}) {
    return TextField(
      controller: controller,
      obscureText: isPassword ? _obscureText : false,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.blueAccent),
        filled: true,
        fillColor: Colors.grey[100],
        prefixIcon: Icon(
          isPassword ? Icons.lock : Icons.email,
          color: Colors.blueAccent,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20.0),
          borderSide: BorderSide.none,
        ),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  _obscureText ? Icons.visibility_off : Icons.visibility,
                  color: Colors.grey,
                ),
                onPressed: _togglePasswordVisibility,
              )
            : null,
      ),
    );
  }

  Widget _errorMessage() {
    return Text(
      errorMessage == '' ? '' : 'Error: $errorMessage',
      style: const TextStyle(color: Colors.white),
    );
  }

  Widget _submitButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blueAccent,
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
      ),
      onPressed: _validateAndSubmit,
    child: Text(isLogin ? 'Login' : 'Register'),
    );
  }

  Future<void> _validateAndSubmit() async {
  setState(() {
    errorMessage = ''; 
  });

  if (_controllerEmail.text.isEmpty) {
    setState(() {
      errorMessage = 'Please fill this field: Email';
    });
    return;
  }

  if (_controllerPassword.text.isEmpty) {
    setState(() {
      errorMessage = 'Please fill this field: Password';
    });
    return;
  }

  if (!isLogin && _controllerConfirmPassword.text.isEmpty) {
    setState(() {
      errorMessage = 'Please fill this field: Confirm Password';
    });
    return;
  }

  if (!isLogin && _controllerPassword.text != _controllerConfirmPassword.text) {
    setState(() {
      errorMessage = 'Passwords do not match!';
    });
    return;
  }
  //final
  if (isLogin) {
    await signInWithEmailAndPassword();
  } else {
    await createUserWithEmailAndPassword();
  }
}


  Widget _loginOrRegister() {
    return TextButton(
      onPressed: () {
        setState(() {
          isLogin = !isLogin;
          _controllerEmail.clear();
          _controllerPassword.clear();
          _controllerConfirmPassword.clear();
          errorMessage = '';
        });
      },
      child: Text(
        isLogin ? "Don't have an account? Create" : "Already have an account? Sign in",
        style: const TextStyle(color: Colors.blueAccent),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _user != null
      ? _userInfo()
      : Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/bg2_enhanced.jpg'),
          fit: BoxFit.cover, 
        ),
      ),
        child: SingleChildScrollView(
          child: Container(
            height: MediaQuery.of(context).size.height, //MediaQuery.of(context).size.height - if given error try this.
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 150),
                _title(),
                const SizedBox(height: 20),
                
                _entryField("Email", _controllerEmail),
                const SizedBox(height: 10),
                _entryField("Password", _controllerPassword, isPassword: true),
                const SizedBox(height: 10),
                if (!isLogin) 
                  _entryField("Confirm Password", _controllerConfirmPassword,
                      isPassword: true),
                      const SizedBox(height: 10),
                _errorMessage(),
                const SizedBox(height: 20),
                _submitButton(),
                const SizedBox(height: 20),
                _loginOrRegister(),
                const SizedBox(height: 20),
                _googleSignInButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _googleSignInButton(){
    return Center(child: SizedBox(
      height: 50,
      child: SignInButton(Buttons.google, text: "Sign Up with Google", onPressed: (){},
        ),
      ),
    );
  }
  Widget _userInfo(){
    return SizedBox();
  }

  void _handleGoogleSignIn(){
    try {
      GoogleAuthProvider _googleAuthProvider = GoogleAuthProvider();
      _auth.signInWithProvider(_googleAuthProvider);
    } catch (error){
      print(error);
    }
  }

}
