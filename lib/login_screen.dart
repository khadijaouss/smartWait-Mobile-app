import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:smartwait/book_online.dart';
import 'NotFound.dart';

class Login extends StatefulWidget {
  final String place_name;
  const Login({Key? key, required this.place_name}) : super(key: key);
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  Future<FirebaseApp> _initializeFirebase() async {
    FirebaseApp firebaseApp = await Firebase.initializeApp();
    return firebaseApp;
  }

  String uid = "";

  //login function
  Future<User?> loginWithEmailAndPassword(
      {required String email,
      required String password,
      required BuildContext context}) async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user;
    try {
      UserCredential userCredential = await auth.signInWithEmailAndPassword(
          email: email, password: password);
      user = userCredential.user;
      String uid = user!.uid;
      // Passage de l'UID à la prochaine page
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                BookOnline(uid: uid, place_name: widget.place_name),
          ));
    } on FirebaseAuthException catch (e) {
      if (e.code == "user-not-found") {
        print("No user found");
      }
    }

    return user;
  }

  @override
  Widget build(BuildContext context) {
    //the text field controller
    TextEditingController _emailController = TextEditingController();
    TextEditingController _passwordController = TextEditingController();
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 209, 209, 209),
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 209, 209, 209),
        elevation: 0.0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FutureBuilder(
              future: _initializeFirebase(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return const Text('');
                } else if (snapshot.hasError) {
                  return Text("${snapshot.error}");
                }
                return CircularProgressIndicator();
              },
            ),
            //logo
            Image(
                image: AssetImage("assets/1.png"),
                width: 220,
                alignment: Alignment.topCenter),
            const Text(
              "Welcome",
              style: TextStyle(
                color: Colors.orange,
                fontSize: 38.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Text(
              "Login to smart wait",
              style: TextStyle(
                  color: Color.fromARGB(255, 61, 61, 61), fontSize: 20),
            ),
            const SizedBox(
              height: 44.0,
            ),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                hintText: "Email",
                prefixIcon: Icon(Icons.email_sharp, color: Colors.black),
              ),
            ),
            const SizedBox(
              height: 26.0,
            ),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                hintText: "Password",
                prefixIcon: Icon(Icons.lock, color: Colors.black),
              ),
            ),
            const SizedBox(
              height: 88.0,
            ),
            ElevatedButton(
              onPressed: () async {
                User? user = await loginWithEmailAndPassword(
                    email: _emailController.text,
                    password: _passwordController.text,
                    context: context);
                String uid = user!.uid;
                print(uid);
                if (user != null) {
                  Navigator.of(context).pushReplacement(MaterialPageRoute(
                      builder: (context) =>
                          BookOnline(uid: uid, place_name: widget.place_name)));
                } else {
                  Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (context) => NotFound()));
                }
              },
              child: Text('Sign In'),
            ),
          ],
        ),
      ),
    );
  }
}
