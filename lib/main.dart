import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:smartwait/splash_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'login_screen.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_database/firebase_database.dart';

import 'model/Camera.dart';
import 'model/Place.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Splash(),
    );
  }
}

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  Future<FirebaseApp> _initializeFirebase() async {
    FirebaseApp firebaseApp = await Firebase.initializeApp();
    return firebaseApp;
  }

  final auth = FirebaseAuth.instance;
  final ref = FirebaseDatabase.instance.ref('places');
  final searchController = TextEditingController();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    ref.limitToLast(1).onValue;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color.fromARGB(255, 209, 209, 209),
        appBar: AppBar(
          backgroundColor: Color.fromARGB(255, 209, 209, 209),
          elevation: 0.0,
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
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
            const Padding(
              padding: EdgeInsets.all(12),
              child: Text(
                "Select a place",
                style: TextStyle(
                    color: Color.fromARGB(255, 53, 53, 53),
                    fontSize: 22.0,
                    fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 1.0),
            Padding(
              padding: EdgeInsets.all(15),
              child: SizedBox(
                  width: 350.0,
                  child: TextField(
                      controller: searchController,
                      onChanged: (String value) {
                        setState(() {});
                      },
                      style: TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.orange,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: BorderSide.none,
                        ),
                        hintText: "Administration/ Bank",
                        prefixIcon: Icon(Icons.search),
                        prefixIconColor: Color.fromARGB(255, 206, 205, 207),
                      ))),
            ),
            const SizedBox(
              height: 20.0,
            ),
            Expanded(
                child: FirebaseAnimatedList(
              query: ref,
              defaultChild: Text('Loading'),
              itemBuilder: (context, snapshot, animation, index) {
                final place = snapshot.child('place_name').value.toString();
                if (searchController.text.isEmpty) {
                  return ListTile(
                    title: Text(
                      snapshot.child('place_name').value.toString(),
                      style: const TextStyle(
                        color: Color.fromARGB(255, 10, 10, 10),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      snapshot.child('adresse').value.toString(),
                      style: const TextStyle(
                        color: Color.fromARGB(153, 46, 46, 46),
                      ),
                    ),
                    trailing:
                        Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
                      Text(
                          snapshot
                              .child('Camera')
                              .child('total_person')
                              .value
                              .toString(),
                          style: const TextStyle(
                              color: Colors.orange,
                              fontWeight: FontWeight.bold,
                              fontSize: 19.0)),
                      IconButton(
                        icon:
                            const Icon(Icons.location_pin, color: Colors.blue),
                        onPressed: () async {
                          // Get the destination address from the text field
                          String destination =
                              snapshot.child('adresse').value.toString();
                          print(destination);
                          // Launch the URL
                          Future<void> _launch(Uri url) async {
                            await canLaunchUrl(url)
                                ? await launchUrl(url)
                                : print('Could not launch $url');
                          }

                          String query = Uri.encodeComponent(destination);
                          // Create the Google Maps URL
                          Uri url = Uri.parse(
                              'https://www.google.com/maps/search/?api=1&query=$query');
                          _launch(url);
                        },
                      ),
                      IconButton(
                        icon:
                            const Icon(Icons.schedule_send, color: Colors.blue),
                        onPressed: () async {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Login(),
                            ),
                          );
                        },
                      )
                    ]),
                  );
                } else if (place
                    .toLowerCase()
                    .contains(searchController.text.toLowerCase())) {
                  return ListTile(
                    title: Text(
                      snapshot.child('place_name').value.toString(),
                      style: const TextStyle(
                        color: Color.fromARGB(255, 10, 10, 10),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      snapshot.child('adresse').value.toString(),
                      style: const TextStyle(
                        color: Color.fromARGB(153, 46, 46, 46),
                      ),
                    ),
                    trailing:
                        Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
                      Text(
                          snapshot
                              .child('Camera')
                              .child('total_person')
                              .value
                              .toString(),
                          style: const TextStyle(
                              color: Colors.orange,
                              fontWeight: FontWeight.bold,
                              fontSize: 19.0)),
                      IconButton(
                        icon:
                            const Icon(Icons.location_pin, color: Colors.blue),
                        onPressed: () async {
                          // Get the destination address from the text field
                          String destination =
                              snapshot.child('adresse').value.toString();
                          // Launch the URL
                          Future<void> _launch(Uri url) async {
                            await canLaunchUrl(url)
                                ? await launchUrl(url)
                                : print('Could not launch $url');
                          }

                          String query = Uri.encodeComponent(destination);
                          // Create the Google Maps URL
                          Uri url = Uri.parse(
                              'https://www.google.com/maps/search/?api=1&query=$query');
                          _launch(url);
                        },
                      ),
                      IconButton(
                        icon:
                            const Icon(Icons.schedule_send, color: Colors.blue),
                        onPressed: () async {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Login(),
                            ),
                          );
                        },
                      )
                    ]),
                  );
                } else {
                  return Container();
                }
              },
            )),
          ],
        ));
  }
}
