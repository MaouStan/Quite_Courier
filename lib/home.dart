import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  void initState() {
    super.initState();
    // var db = FirebaseFirestore.instance;

    // var data = {
    //   'name': 'nameCtl.text',
    //   'message': 'messageCtl.text',
    //   'createAt': DateTime.timestamp()
    // };

    // db.collection('inbox').doc('Room1234').set(data);
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Home'),
      ),
    );
  }
}
