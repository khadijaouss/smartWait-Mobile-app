import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class BookOnline extends StatefulWidget {
  const BookOnline({Key? key}) : super(key: key);

  @override
  _BookOnlineState createState() => _BookOnlineState();
}

class _BookOnlineState extends State<BookOnline> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: const Center(
            child: Text(
                "Welcome to smart wait! Now you can book online your tciket")));
  }
}
