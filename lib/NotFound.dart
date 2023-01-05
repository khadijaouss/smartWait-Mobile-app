import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class NotFound extends StatefulWidget {
  const NotFound({Key? key}) : super(key: key);

  @override
  _NotFoundState createState() => _NotFoundState();
}

class _NotFoundState extends State<NotFound> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: const Center(
            child: Text("Oops!This email doesn't have an account")));
  }
}
